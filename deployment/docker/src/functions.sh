#!/bin/bash


# store configs
function store_configs() {
    echo  '{
    "database_user": "'$DATABASE_USER'",
    "database_password": "'$DATABASE_PASSWORD'",
    "database_name": "'$DATABASE_NAME'",
    "postgres_user": "'$POSTGRES_USER'",
    "postgres_password": "'$POSTGRES_PASSWORD'",
    "token_jwt_key": "'$TOKEN_JWT_KEY'",
    "secret_current_token_salt": "'$SECRET_CURRENT_TOKEN_SALT'",
    "secret_refresh_token_salt": "'$SECRET_REFRESH_TOKEN_SALT'",
    "secret_access_token_salt": "'$SECRET_ACCESS_TOKEN_SALT'",
    "cms_domain_name": "'$CMS_DOMAIN_NAME'",
    "api_domain_name": "'$API_DOMAIN_NAME'",
    "cms_port": "'$CMS_PORT'",
    "api_port": "'$API_PORT'",
    "admin_email": "'$ADMIN_EMAIL'",
    "ssl": "'$SSL'",
    "protocol": "'$PROTOCOL'"
    }' > $PWD/etc/.secret
}

# load configs
function load_configs() {
    constants=$(cat .secret | jq '.' | jq -r "to_entries|map(\"\(.key|ascii_upcase)=\(.value|tostring)\")|.[]")
    for key in ${constants}; do
        eval ${key}
    done
}


function update_config() {        
    # load configs
    load_configs

    local CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME//[ #\"-%\"]}
    local API_DOMAIN_NAME=${API_DOMAIN_NAME//[ #\"-%\"]}
    local SSL=${SSL//[ #\"-%\"]}
    local CMS_PORT=${CMS_PORT//[ #\"-%\"]}
    
    if [[ $CMS_PORT == "443" ]] && [[ ${SSL,,} =~ ^yes$ ]]; then 
        cp --force dockers/docker-compose_with_nginx.yml dockers/docker-compose.yml
        # change domains 
        sed -i 's~MISHKA_CMS_DOMAIN_NAME~'${CMS_DOMAIN_NAME}'~' ./etc/nginx/conf/conf.d/mishka_cms.conf
        sed -i 's~MISHKA_API_DOMAIN_NAME~'${API_DOMAIN_NAME}'~' ./etc/nginx/conf/conf.d/mishka_api.conf
        # change ports
        sed -i 's~MISHKA_CMS_PORT~443 ssl http2~' ./etc/nginx/conf/conf.d/mishka_cms.conf 
        sed -i 's~MISHKA_API_PORT~443 ssl http2~' ./etc/nginx/conf/conf.d/mishka_api.conf
        # enable ssl 
        sed -i 's~SITE_NAME~'$CMS_DOMAIN_NAME'~' ./etc/nginx/conf/ssl.conf
        sed -i 's~#include~include~' ./etc/nginx/conf/conf.d/mishka_api.conf 
        sed -i 's~#include~include~' ./etc/nginx/conf/conf.d/mishka_cms.conf 
    elif [[ $CMS_PORT == "80" ]]; then 
        cp --force dockers/docker-compose_with_nginx.yml dockers/docker-compose.yml
        # change domains
        sed -i 's~MISHKA_CMS_DOMAIN_NAME~'${CMS_DOMAIN_NAME}'~' ./etc/nginx/conf/conf.d/mishka_cms.conf
        sed -i 's~MISHKA_API_DOMAIN_NAME~'${API_DOMAIN_NAME}'~' ./etc/nginx/conf/conf.d/mishka_api.conf
        # change ports
        sed -i 's~MISHKA_CMS_PORT~80~' ./etc/nginx/conf/conf.d/mishka_cms.conf 
        sed -i 's~MISHKA_API_PORT~80~' ./etc/nginx/conf/conf.d/mishka_api.conf 
    else 
        cp --force dockers/docker-compose_without_nginx.yml dockers/docker-compose.yml
    fi

    # change value in docker-compose.yml
    if [ -f $PWD/etc/.secret ]; then 
        # load configs
        load_configs 

        # remove double qoutaion
        local DATABASE_USER=${DATABASE_USER//[ #\"-%\"]}
        local DATABASE_PASSWORD=${DATABASE_PASSWORD//[ #\"-%\"]}
        local DATABASE_NAME=${DATABASE_NAME//[ #\"-%\"]}
        local POSTGRES_USER=${POSTGRES_USER//[ #\"-%\"]}
        local POSTGRES_PASSWORD=${POSTGRES_PASSWORD//[ #\"-%\"]}

        sed -i 's~DATABASE_USER=mishka_user~DATABASE_USER='${DATABASE_USER}'~' dockers/docker-compose.yml 
        sed -i 's~DATABASE_PASSWORD=mishka_password~DATABASE_PASSWORD='${DATABASE_PASSWORD}'~' dockers/docker-compose.yml 
        sed -i 's~DATABASE_NAME=mishka_database~DATABASE_NAME='${DATABASE_NAME}'~' dockers/docker-compose.yml 
        sed -i 's~POSTGRES_USER=postgres~POSTGRES_USER='${POSTGRES_USER}'~' dockers/docker-compose.yml 
        sed -i 's~POSTGRES_PASSWORD=postgres~POSTGRES_PASSWORD='${POSTGRES_PASSWORD}'~' dockers/docker-compose.yml 
    else 
        echo -e "${Red}.secret file not found, Operation cenceled, Please use 'mishka.sh --build' for install app${NC}"
        exit 1
    fi
   
}


function cleanup() {
    if [ -f dockers/docker-compose.yml ] || [ -f etc/.secret ]; then 
        # Stop Services and Delete Networks
        docker-compose -f dockers/docker-compose.yml  -p mishka_cms down
        
        # Delete Images
        if [ -f etc/certbot/letsencrypt ]; then 
            docker image rm nginx:1.20.1-alpine mishak_app:latest mishkagroup/postgresql:3.14
            echo -e "${Red} mishka images deleted..${NC}"
        else 
            docker image rm mishak_app:latest mishkagroup/postgresql:3.14
            echo -e "${Red} mishka images deleted..${NC}"
        fi

        # Delete SSL certificate 
        if [ -f etc/certbot/letsencrypt ]; then 
            rm -r etc/certbot/letsencrypt
            echo -e "${Red} mishka ssl deleted..${NC}"
        fi

        # Delete temp Files
        if [ -f ../../Dockerfile ]; then
            rm dockers/docker-compose.yml ../../Dockerfile
            echo -e "${Green} mishka Temp Files deleted..${NC}"
        fi

        # Delete Volumes
        docker volume rm mishka_cms_database mishka_cms_cms
        echo -e "${Green} mishka volumes deleted..${NC}"

        # Delete Secrets
        if [ -f $PWD/etc/.secret ]; then 
            rm $PWD/etc/.secret
            echo -e "${Green} mishka secret file deleted..${NC}"
        fi 

        # Fresh nginx conf
        cp --force etc/nginx/conf/sample_conf/mishka_* etc/nginx/conf/conf.d
       
        echo -e "${Green}Clenup Process is done.${NC}"
        
    else 
        echo -e "${Red}NOTHING EXIST FOR CELAN !${NC}"
    fi
}


function ssl_generator() {
    local ADMIN_EMAIL=$1
    local CMS_DOMAIN_NAME=$2
    local API_DOMAIN_NAME=$3

    # create dhparam2048
    if [ ! -f etc/certbot/master_certificates/dhparam2048.pem ]; then 
        openssl dhparam -out etc/certbot/master_certificates/dhparam2048.pem 2048
    fi

    # remove old certs
    if [ -d etc/certbot/letsencrypt ]; then 
        rm -rf etc/certbot/letsencrypt
    fi

    # create ssl for domains
    docker run -it --rm --name certbot  \
    -p 80:80 \
    -p 443:443 \
    -v "$PWD/etc/certbot/letsencrypt:/etc/letsencrypt"  \
    certbot/certbot certonly -q \
    --standalone \
    --agree-tos \
    --must-staple  \
    --rsa-key-size 4096   \
    --email $ADMIN_EMAIL  \
    -d $CMS_DOMAIN_NAME \
    -d $API_DOMAIN_NAME

}

# check validity of domain ( test.example.com or example.com )
function domain_checker() {
    local INPUT=$1
    if [[ $INPUT =~ ^[a-z|A-Z|0-9]+\.+[a-z|A-Z]+$ ]] || [[ $INPUT =~ ^[a-z|A-Z|0-9]+\.+[a-z|A-Z|0-9]+\.[a-z|A-A]+$ ]]; then 
        return 0
    else 
        return 1
    fi 
}

# check validity of ip ( x.x.x.x )
function ip_checker() {
    local INPUT=$1
    if [[ $INPUT =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else 
        return 1
    fi  
}

# check validity of email ( test@example.com )
function email_checker() {
    local INPUT=$1
    if [[ $INPUT =~ ^[a-z|A-Z|0-9]+\@+[a-z|A-Z|0-9]+\.[a-z|A-Z]+$ ]] || [[ $INPUT =~ ^[a-z|A-Z|0-9|\.]+\@+[a-z|A-Z|0-9]+\.[a-z|A-Z]+$ ]]; then 
        return 0
    else 
        return 1
    fi  
}

# check requirments before run shell
function check_requirements() {

    # check root user
    if [[ $EUID -ne 0 ]]; then 
        echo -e "${Red}This script must be run as root${NC}"
        exit 1
    fi

    # check command git install on system
    if ! command -v git $>/dev/null; then 
        echo -e "${Red}git Command Not Found, ${Green}Please Install with 'sudo apt install git -y'${NC}"
        exit 1
    fi

    # check command git install on system
    if ! command -v jq $>/dev/null; then 
        echo -e "${Red}jq Command Not Found, ${Green}Please Install with 'sudo apt install jq -y'${NC}"
        exit 1
    fi
}


# set default value for variables
function default_values() {
    DATABASE_USER=${DATABASE_USER:-"mishka_user"}
    DATABASE_NAME=${DATABASE_NAME:-"mishka_database"}
    DATABASE_PASSWORD=${DATABASE_PASSWORD:-"mishka_password"}
    POSTGRES_USER=${POSTGRES_USER:-"postgres"}
    POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"postgres"}
    CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME:-"127.0.0.1"}
    API_DOMAIN_NAME=${API_DOMAIN_NAME:-"127.0.0.1"}
    CMS_PORT=${CMS_PORT:-"4000"}
    API_PORT=${API_PORT:-"4001"}
    ADMIN_EMAIL=${ADMIN_EMAIL:-"example@example.com"}
    PROTOCOL=${PROTOCOL:-"http"}
}


# create new token
function token_generators() {
    TOKEN_JWT_KEY=`dd if=/dev/urandom bs=32 count=1 | base64 | sed 's/+/-/g; s/\//_/g; s/=//g'`
    SECRET_CURRENT_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo` 
    SECRET_REFRESH_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo`
    SECRET_ACCESS_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo`
}



# print build output
function print_build_output() {
    echo -e "${Green}=======================================================================================================${NC}"
    if [[ ${SSL,,} =~ ^yes$ ]]; then # convert user input to lowercase then check it
    echo -e "${Green}Mishka Cms Available on    --> $SPACE https://$CMS_DOMAIN_NAME $END_SPACE ${NC}"
    echo -e "${Green}Mishka Api Available on    --> $SPACE https://$API_DOMAIN_NAME $END_SPACE ${NC}" 
    else 
    echo -e "${Green}Mishka Cms Available on    --> $SPACE http://$CMS_DOMAIN_NAME:$CMS_PORT $END_SPACE ${NC}"
    echo -e "${Green}Mishka Api Available on    --> $SPACE http://$API_DOMAIN_NAME:$API_PORT $END_SPACE ${NC}"  
    fi
    echo -e "${Green}==================================================================================================${NC}"

    echo -e
    echo -e "${Yellow}=======================================================================================================${NC}"
    echo -e "${Yellow}Your Database User is         --> $SPACE $DATABASE_USER $END_SPACE ${NC}"
    echo -e "${Yellow}Your Database Name is         --> $SPACE $DATABASE_NAME $END_SPACE ${NC}"
    echo -e "${Yellow}Your Database Password is:    --> $SPACE $DATABASE_PASSWORD $END_SPACE ${NC}"
    echo -e "${Yellow}Your Postgres User is:        --> $SPACE $POSTGRES_USER $END_SPACE ${NC}"
    echo -e "${Yellow}Your Postgres Password is:    --> $SPACE $POSTGRES_PASSWORD $END_SPACE ${NC}"
    echo -e "${Yellow}==================================================================================================${NC}"

    echo -e 
    echo -e "${Red}=======================================================================================================${NC}"
    echo -e "${Red}KEEP THIS VALUE IN SECRET, IF YOU LOSS THEM YOUR USERS CAN'T LOGIN INTO MISHKA CMS AFTER UPDATE:"     
    echo -e "${Red}token_jwt_key:                   --> $SPACE $TOKEN_JWT_KEY $END_SPACE ${NC}"                                                                              
    echo -e "${Red}secret_current_token_salt:       --> $SPACE $SECRET_CURRENT_TOKEN_SALT $END_SPACE ${NC}"                                                      
    echo -e "${Red}secret_refresh_token_salt:       --> $SPACE $SECRET_REFRESH_TOKEN_SALT $END_SPACE ${NC}"                                                       
    echo -e "${Red}secret_access_token_salt:        --> $SPACE $SECRET_ACCESS_TOKEN_SALT $END_SPACE ${NC}"                                                           
    echo -e "${Red}==================================================================================================${NC}"
}


