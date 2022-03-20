#!/bin/bash

# store configs
function store_configs() {
    echo  '{
    "database": {
        "database_user": "'$DATABASE_USER'",
        "database_password": "'$DATABASE_PASSWORD'",
        "database_name": "'$DATABASE_NAME'",
        "database_host": "mishka_db",
        "database_port": "5432",
        "postgres_user": "'$POSTGRES_USER'",
        "postgres_password": "'$POSTGRES_PASSWORD'" 
    },
    "tokens": {
        "token_jwt_key": "'$TOKEN_JWT_KEY'",
        "secret_current_token_salt": "'$SECRET_CURRENT_TOKEN_SALT'",
        "secret_refresh_token_salt": "'$SECRET_REFRESH_TOKEN_SALT'",
        "secret_access_token_salt": "'$SECRET_ACCESS_TOKEN_SALT'",
        "secret_key_base": "'$SECRET_KEY_BASE'",
        "secret_key_base_html": "'$SECRET_KEY_BASE_HTML'",
        "secret_key_base_api": "'$SECRET_KEY_BASE_API'",
        "live_view_salt": "'$LIVE_VIEW_SALT'" 
    },
    "mail": {
        "email_system": "'$EMAIL_SYSTEM'",
        "email_domain": "'$EMAIL_DOMAIN'",
        "email_port": "'$EMAIL_PORT'",
        "email_server": "'$EMAIL_SERVER'",
        "email_hostname": "'$EMAIL_HOSTNAME'",
        "email_username": "'$EMAIL_USERNAME'",
        "email_password": "'$EMAIL_PASSWORD'",
        "email_config": "'$EMAIL_CONFIG'"
    },
    "etc": {
        "cms_domain_name": "'$CMS_DOMAIN_NAME'",
        "api_domain_name": "'$API_DOMAIN_NAME'",
        "cms_port": "'$CMS_PORT'",
        "api_port": "'$API_PORT'",
        "admin_email": "'$ADMIN_EMAIL'",
        "ssl": "'$SSL'",
        "protocol": "'$PROTOCOL'",
        "env_type": "'$ENV_TYPE'",
        "web_server": "'$WEB_SERVER'"
    }
    }' > $PWD/etc/.secret
}

# load configs
function load_configs() {
    constants=$(cat $PWD/etc/.secret | jq '.[]' | jq -r "to_entries|map(\"\(.key|ascii_upcase)=\(.value|tostring)\")|.[]")
    for key in ${constants}; do
        # remove double qoutaion
        local VALUE=`echo ${key} | sed 's/"//g'`

        # set variable
        eval ${VALUE}
    done
}


# env generator
function env_generator() {
    constants=$(cat $PWD/etc/.secret | jq '.[]' | jq -r "to_entries|map(\"\(.key|ascii_upcase)=\(.value|tostring)\")|.[]")
    for key in ${constants}; do
        eval ${key}
        echo ${key} >> $PWD/etc/.mishka_cms_env
    done
}


function update_config() {        
    # load configs
    load_configs

    cp --force etc/nginx/conf/sample_conf/mishka_api.conf etc/nginx/conf/conf.d/mishka_api.conf
    cp --force etc/nginx/conf/sample_conf/mishka_cms.conf etc/nginx/conf/conf.d/mishka_cms.conf

    if [[ ${ENV_TYPE,,} =~ ^prod$ ]]; then 
        if [[ $CMS_PORT == "443" ]] && [[ ${SSL,,} =~ ^yes$ ]]; then 
            cp --force dockers/docker-compose_with_nginx.yml dockers/docker-compose.yml
            cp --force etc/nginx/conf/sample_conf/ssl_prod.conf etc/nginx/conf/ssl.conf 
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
            sed -i 's~DATABASE_USER=mishka_user~DATABASE_USER='${DATABASE_USER}'~' dockers/docker-compose.yml 
            sed -i 's~DATABASE_PASSWORD=mishka_password~DATABASE_PASSWORD='${DATABASE_PASSWORD}'~' dockers/docker-compose.yml 
            sed -i 's~DATABASE_NAME=mishka_database~DATABASE_NAME='${DATABASE_NAME}'~' dockers/docker-compose.yml 
            sed -i 's~POSTGRES_USER=postgres~POSTGRES_USER='${POSTGRES_USER}'~' dockers/docker-compose.yml 
            sed -i 's~POSTGRES_PASSWORD=postgres~POSTGRES_PASSWORD='${POSTGRES_PASSWORD}'~' dockers/docker-compose.yml 
        else 
            echo -e "${Red}.secret file not found, Operation cenceled, Please use 'mishka.sh --build' for install app${NC}"
            exit 1
        fi
    else 
        if [[ $CMS_PORT == "443" ]] && [[ ${SSL,,} =~ ^yes$ ]]; then 
            cp --force dockers/docker-compose_dev_with_nginx.yml dockers/docker-compose.yml
            cp --force etc/nginx/conf/sample_conf/ssl_dev.conf etc/nginx/conf/ssl.conf 
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
            cp --force dockers/docker-compose_dev_with_nginx.yml dockers/docker-compose.yml
            # change domains
            sed -i 's~MISHKA_CMS_DOMAIN_NAME~'${CMS_DOMAIN_NAME}'~' ./etc/nginx/conf/conf.d/mishka_cms.conf
            sed -i 's~MISHKA_API_DOMAIN_NAME~'${API_DOMAIN_NAME}'~' ./etc/nginx/conf/conf.d/mishka_api.conf
            # change ports
            sed -i 's~MISHKA_CMS_PORT~80~' ./etc/nginx/conf/conf.d/mishka_cms.conf 
            sed -i 's~MISHKA_API_PORT~80~' ./etc/nginx/conf/conf.d/mishka_api.conf 
        else 
            cp --force dockers/docker-compose_dev_without_nginx.yml dockers/docker-compose.yml
        fi

        # change value in docker-compose.yml
        if [ -f $PWD/etc/.secret ]; then 
            sed -i 's~DATABASE_USER=mishka_user~DATABASE_USER='${DATABASE_USER}'~' dockers/docker-compose.yml 
            sed -i 's~DATABASE_PASSWORD=mishka_password~DATABASE_PASSWORD='${DATABASE_PASSWORD}'~' dockers/docker-compose.yml 
            sed -i 's~DATABASE_NAME=mishka_database~DATABASE_NAME='${DATABASE_NAME}'~' dockers/docker-compose.yml 
            sed -i 's~POSTGRES_USER=postgres~POSTGRES_USER='${POSTGRES_USER}'~' dockers/docker-compose.yml 
            sed -i 's~POSTGRES_PASSWORD=postgres~POSTGRES_PASSWORD='${POSTGRES_PASSWORD}'~' dockers/docker-compose.yml 
        else 
            echo -e "${Red}.secret file not found, Operation cenceled, Please use 'mishka.sh --build' for install app${NC}"
            exit 1
        fi
    fi
   
}


function cleanup() {
    if [ -f dockers/docker-compose.yml ] || [ -f $PWD/etc/.secret ]; then 
        # load configs
        load_configs

        # Stop Services and Delete Networks
        docker-compose -f dockers/docker-compose.yml  -p mishka_cms down

        if [[ ${ENV_TYPE,,} =~ ^prod$ ]]; then
            # Delete Images
            if [ -f etc/prod/letsencrypt ]; then 
                docker image rm nginx:1.20.1-alpine mishak_app:latest mishkagroup/postgresql:3.14
                echo -e "${Green} mishka images deleted..${NC}"

                # Fresh nginx conf
                cp --force etc/nginx/conf/sample_conf/mishka_* etc/nginx/conf/conf.d
            else 
                docker image rm mishak_app:latest mishkagroup/postgresql:3.14
                echo -e "${Green} mishka images deleted..${NC}"
            fi

            # Delete SSL certificate 
            if [ -f etc/prod/letsencrypt ]; then 
                rm -r etc/prod/letsencrypt
                echo -e "${Green} mishka ssl deleted..${NC}"
            fi
        else 
            # Delete Images
            docker image rm mishkagroup/elixir_dev:1.12.3-alpine mishkagroup/postgresql:3.14
            echo -e "${Green} mishka images deleted..${NC}"

            # delete build directory
            if [ -d ../../_build ]; then 
                rm --recursive --force ../../_build
                echo -e "${Green} mishka build directory deleted..${NC}"
            fi

            # delete deps directory
            if [ -d ../../deps ]; then 
                rm --recursive --force ../../deps
                echo -e "${Green} mishka build directory deleted..${NC}"
            fi

            # delete Mnesia dicretory
            if [ -d ../../Mnesia.nonode@nohost ]; then 
                rm --recursive --force ../../Mnesia.nonode@nohost
            fi 

            # delete Mnesia dicretory
            if [ -d ../../mix.lock ]; then 
                rm --force ../../mix.lock
            fi 
               
        fi
        


        # Delete Dockerfile
        if [ -f ../../Dockerfile ]; then
            rm --force ../../Dockerfile
            echo -e "${Green} mishka Dockerfile deleted..${NC}"
        fi

        # Delete docker-compose
        if [ -f dockers/docker-compose.yml ]; then
            rm --force dockers/docker-compose.yml
            echo -e "${Green} mishka docker-compose.yml deleted..${NC}"
        fi

        # Delete Volumes
        docker volume rm mishka_cms_database mishka_cms_cms
        echo -e "${Green} mishka volumes deleted..${NC}"

        # Delete Secret file
        if [ -f $PWD/etc/.secret ]; then 
            rm $PWD/etc/.secret
            echo -e "${Green} mishka secret file deleted..${NC}"
        fi 

        # Delete Env file
        if [ -f $PWD/etc/.mishka_cms_env ]; then 
            rm $PWD/etc/.mishka_cms_env
            echo -e "${Green} mishka env file deleted..${NC}"
        fi 

        
        echo -e "${Green}Clenup Process is done.${NC}"
        
    else 
        echo -e "${Red}NOTHING EXIST FOR CELAN !${NC}"
    fi
}


function ssl_generator() {
    if [[ ${ENV_TYPE,,} =~ ^prod$ ]]; then
        local ADMIN_EMAIL=$1
        local CMS_DOMAIN_NAME=$2
        local API_DOMAIN_NAME=$3

        # create dhparam2048
        if [ ! -f etc/ssl/letsencrypt/dhparam2048.pem ]; then 
            openssl dhparam -out etc/ssl/letsencrypt/dhparam2048.pem 2048
        fi

        # remove old certs
        if [ -d etc/ssl/prod/letsencrypt ]; then 
            rm -rf etc/ssl/prod/letsencrypt
        fi

        # create ssl for domains
        docker run -it --rm --name certbot  \
        -p 80:80 \
        -p 443:443 \
        -v "$PWD/etc/ssl/prod/letsencrypt:/etc/letsencrypt"  \
        certbot/certbot certonly -q \
        --standalone \
        --agree-tos \
        --must-staple  \
        --rsa-key-size 4096   \
        --email $ADMIN_EMAIL  \
        -d $CMS_DOMAIN_NAME \
        -d $API_DOMAIN_NAME
    else 
        # create dhparam2048
        if [ ! -f etc/ssl/letsencrypt/dhparam2048.pem ]; then 
            openssl dhparam -out etc/ssl/letsencrypt/dhparam2048.pem 2048
        fi

        echo "127.0.0.1 cms.example.com api.example.com" >> /etc/hosts
    fi
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
    
    # check docker config file exists
    if [ ! -f ~/.docker/config.json ]; then 
        docker login
    fi
    
    if [[ $OSTYPE == 'linux'* ]]; then # linux
        # check command git install on system
        if ! command -v git $>/dev/null; then 
            echo -e "${Red}git Command Not Found${NC}"
            sudo apt install git -y
        fi

        # check command jq install on system
        if ! command -v jq $>/dev/null; then 
            echo -e "${Red}jq Command Not Found${NC}"
            sudo apt install jq -y
        fi

        # check command docker install on system
        if ! command -v docker $>/dev/null; then 
            echo -e "${Red}docker Command Not Found${NC}"
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
        else 
            if [[ $(systemctl is-active docker) == "inactive" ]]; then 
                sudo systemctl start docker
            fi
        fi

        # check command docker-compose install on system
        if ! command -v docker-compose $>/dev/null; then 
            echo -e "${Red}docker-compose Command Not Found${NC}"
            sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        fi
    elif [[ $OSTYPE == 'darwin'* ]]; then # MacOS
        # check command git install on system
        if ! command -v git $>/dev/null; then 
            echo -e "${Red}git Command Not Found${NC}"
            yes | brew install git
        fi

        # check command jq install on system
        if ! command -v jq $>/dev/null; then 
            echo -e "${Red}jq Command Not Found${NC}"
            yes | brew install jq
        fi

        # check command docker and docker-compose install on system
        if ! command -v docker $>/dev/null; then 
            echo -e "${Red}docker Command Not Found${NC}"
            brew install --cask docker
        else 
            if (! docker stats --no-stream ); then
                # On Mac OS this would be the terminal command to launch Docker
                open /Applications/Docker.app
                #Wait until Docker daemon is running and has completed initialisation
                while (! docker stats --no-stream ); do
                    # Docker takes a few seconds to initialize
                    echo "Waiting for Docker to launch..."
                    sleep 1
                done
            fi
        fi
    else # windows
        echo -e "${Red}Your OS is not supported${NC}"
        exit 1
    fi
}


# create tables, do migrataions and compile file for first time
function dev_operations() {
    docker exec -it mishka_cms sh -c "mix deps.get"
    docker exec -it mishka_cms sh -c "mix deps.compile"
    docker exec -it mishka_cms sh -c "mix ecto.create"
    docker exec -it mishka_cms sh -c "cd apps/mishka_database && mix mishka_installer.db.gen.migration"
    docker exec -it mishka_cms sh -c "mix ecto.migrate"
    docker exec -it mishka_cms sh -c "mix assets.deploy"
    docker exec -it mishka_cms sh -c "mix run apps/mishka_database/priv/repo/seeds.exs"
    docker exec -it mishka_cms sh -c "iex -S mix phx.server"
}


# set default value for variables
function default_values() {
    # database
    DATABASE_USER=${DATABASE_USER:-"mishka_user"}
    DATABASE_NAME=${DATABASE_NAME:-"mishka_database"}
    DATABASE_PASSWORD=${DATABASE_PASSWORD:-"mishka_password"}
    POSTGRES_USER=${POSTGRES_USER:-"postgres"}
    POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"postgres"}

    # email
    EMAIL_SYSTEM=${EMAIL_SYSTEM:-"info@example.com"}
    EMAIL_DOMAIN=${EMAIL_DOMAIN:-"example.com"}
    EMAIL_PORT=${EMAIL_PORT:-"587"}
    EMAIL_SERVER=${EMAIL_SERVER:-"mail.example.com"}
    EMAIL_HOSTNAME=${EMAIL_HOSTNAME:-"mail.example.com"}
    EMAIL_USERNAME=${EMAIL_USERNAME:-"info@example.com"}
    EMAIL_PASSWORD=${EMAIL_PASSWORD:-"SOMEPASSWORD"}

    # etc
    CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME:-"localhost"}
    API_DOMAIN_NAME=${API_DOMAIN_NAME:-"localhost"}
    CMS_PORT=${CMS_PORT:-"4000"}
    API_PORT=${API_PORT:-"4001"}
    ADMIN_EMAIL=${ADMIN_EMAIL:-"example@example.com"}
    SSL=${SSL:-"no"}
    PROTOCOL=${PROTOCOL:-"http"}
    ENV_TYPE=${ENV_TYPE:-"dev"}
    WEB_SERVER=${WEB_SERVER:-"cowboy"}
}


# create new token
function secret_generators() {
    TOKEN_JWT_KEY=`dd if=/dev/urandom bs=32 count=1 | base64 | sed 's/+/-/g; s/\//_/g; s/=//g'`
    SECRET_CURRENT_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo` 
    SECRET_REFRESH_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo`
    SECRET_ACCESS_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo`
    SECRET_KEY_BASE=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo`
    SECRET_KEY_BASE_HTML=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo`
    SECRET_KEY_BASE_API=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo`
    LIVE_VIEW_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 32 | tr -d '\n'; echo`
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

    echo -e
    if [[ "$ENV_TYPE" =~ ^dev$ ]]; then 
        echo -e "${Green}=======================================================================================================${NC}"
        echo -e "${Red}please import 'rootCA' into web browser${NC}"
        echo -e "${Green} $SPACE for google chrome: $END_SPACE ${NC}"
        echo -e "${Green} $SPACE Enter this address 'chrome://settings/certificates' into google chrome address bar $END_SPACE ${NC}"
        echo -e "${Green} $SPACE Select 'Authorities' tab $END_SPACE ${NC}"
        echo -e "${Green} $SPACE Click on 'Import' Button $END_SPACE ${NC}"
        echo -e "${Green} $SPACE Select 'rootCA_example.pem' file from $PWD/etc/ssl/dev/ $END_SPACE ${NC}"
        echo -e "${Green} $SPACE Check the first option with name 'Trust this certificate for identifying websites' $END_SPACE ${NC}"
        echo -e "${Green} $SPACE Finaly click OK $END_SPACE ${NC}"
        echo -e "${Green}=======================================================================================================${NC}"
    fi
}

# remove old dir for DBeaver
function dbeaver_data_renew() {
    if [ -d ~/.local/share/DBeaverData ]; then
        rm --recursive --force ~/.local/share/DBeaverData
    fi 
    tar xf etc/DBeaverData.tar.bz2 -C ~/.local/share
    echo -e "${Green}Database Manager Actived, for using you can run './mishka.sh db --run' command${NC}"
}


# check distribution
function dist_detector() {
    OS_FAMILY=`grep -i id_like /etc/os-release | cut -d"=" -f2`
    if [[ $OS_FAMILY =~ 'debian' ]]; then # debian family (debian, ubuntu, mint,...)
        return "0"
    else # redhat family
        return "1"
    fi
}

# check dbeaver package
function dbeaver_checker() {
    if os_detector; then # debian family (debian, ubuntu, mint,...)
        if dpkg -s dbeaver-ce 2> /dev/null 1>&2; then 
            return "0"
        else 
            return "1"
        fi 
    else # redhat family
        if yum list --installed | grep dbeaver-ce 2> /dev/null 1>&2; then 
            return "0"
        else 
            return "1"
        fi
    fi
}

# database manager for easy manage database
function db_manager() {
    if os_detector; then # debian family (debian, ubuntu, mint,...)
        if dbeaver_checker; then 
            dbeaver_data_renew
        else 
            wget --timeout=30 https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O /tmp/dbeaver-ce_latest_amd64.deb
            if [ $? == 0 ]; then 
                dpkg -i /tmp/dbeaver-ce_latest_amd64.deb
                dbeaver_data_renew
            else 
                echo -e "${Red}Download Error, Please Check Your Connection${NC}"
            fi
        fi  
    else # redhat family
        if dbeaver_checker; then 
            dbeaver_data_renew
        else 
            wget --timeout=30 https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm -O /tmp/dbeaver-ce-latest-stable.x86_64.rpm
            if [ $? == 0 ]; then 
                rpm -i /tmp/dbeaver-ce-latest-stable.x86_64.rpm
                dbeaver_data_renew
            else 
                echo -e "${Red}Download Error, Please Check Your Connection${NC}"
            fi
        fi  
    fi                
}


# get email config from user and enable email system
function email_system() {
    while true; do 
        read -p $'\e[32mEnter Your Email Name [like \'info@example.com\']\e[0m: ' EMAIL_SYSTEM
        read -p $'\e[32mEnter Your Email Domain [like \'example.com\']\e[0m: ' EMAIL_DOMAIN
        read -p $'\e[32mEnter Your Email Port (587 or 25) [Default is \'587\']\e[0m: ' EMAIL_PORT
        EMAIL_PORT=${EMAIL_PORT:-"587"}
        read -p $'\e[32mEnter Your Email Server [like  \'mail.example.com\']\e[0m: ' EMAIL_SERVER
        read -p $'\e[32mEnter Your Email Hostname [like \'mail.example.com\']\e[0m: ' EMAIL_HOSTNAME
        read -p $'\e[32mEnter Your Email Username [like \'info@example.com\']\e[0m: ' EMAIL_USERNAME
        read -p $'\e[32mEnter Your Email Password \e[0m: ' EMAIL_PASSWORD
        if [[ "$EMAIL_SYSTEM" != "" ]] && [[ "$EMAIL_DOMAIN" != "" ]] && 
            [[ "$EMAIL_PORT" != "" ]] && [[ "$EMAIL_SERVER" != "" ]] && 
            [[ "$EMAIL_HOSTNAME" != "" ]] && [[ "$EMAIL_USERNAME" != "" ]] && 
            [[ "$EMAIL_PASSWORD" != "" ]]; then 
            echo "email system: ${EMAIL_SYSTEM}"
            echo "email domain: ${EMAIL_DOMAIN}"
            echo "email port: ${EMAIL_PORT}"
            echo "email server: ${EMAIL_SERVER}"
            echo "email hostname: ${EMAIL_HOSTNAME}"
            echo "email username: ${EMAIL_USERNAME}"
            echo "email password: ${EMAIL_PASSWORD}"
            read -p $'\e[32mDo You Want to Proceed (YES/NO) ? [default is YES] \'\']\e[0m: ' EMAIL_CONFIRM
            EMAIL_CONFIRM=${EMAIL_CONFIRM:-"YES"}
            if [[ "${EMAIL_CONFIRM,,}" =~ ^yes$ ]]; then
                break
            else 
                echo -e "${Red}please try again!${NC}"
            fi 
        else 
            echo -e "${Red}You entered some empty values, please try again!${NC}"
        fi 
    done 
}


# web server selector
function web_server_selector() {
    read -p $'\e[32mChoose Your Web server (Nginx or Cowboy) [default is \'Cowboy\']\e[0m: ' WEBSERVER     
    case "${WEBSERVER,,}" in 
        "nginx")
             # check web server ports to close
            if netstat -nultp | egrep -w '80|443' > /dev/null; then
                echo -e "${Red}another apps using port 80 or 443, please kill the apps and rerun mishka.sh !${NC}"
                exit 1
            fi 
            return "0"
        ;;

        *)
            return "1"
        ;;
    esac 
}


# show mishka ascii logo
function mishka_logo() {
    clear
    bin/onefetch --ascii-input "$(cat docs/mishka-logo.ans)"
}