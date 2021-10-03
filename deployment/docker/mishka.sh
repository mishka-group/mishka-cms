#!/bin/bash
# set -e -x
# color variables
Red='\033[0;31m'
Black='\033[0;30m'
Dark_Gray='\033[1;30m'
Light_Red='\033[1;31m'
Green='\033[0;32m'  
Light_Green='\033[1;32m'
Brown_Orange='\033[0;33m'  
Yellow='\033[1;33m'
Blue='\033[0;34m' 
Light_Blue='\033[1;34m'
Purple='\033[0;35m'
Light_Purple='\033[1;35m'
Cyan='\033[0;36m'
Light_Cyan='\033[1;36m'
Light_Gray='\033[0;37m'  
White='\033[1;37m'
NC='\033[0m' # No Color
SPACE=`tput setab 7`
END_SPACE=`tput sgr 0`

# variables for build
SECRET_KEY_BASE=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo`
SECRET_KEY_BASE_HTML=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo`
SECRET_KEY_BASE_API=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo`
LIVE_VIEW_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 32 | tr -d '\n'; echo`




function update_config() {        
    local CMS_DOMAIN_NAME=`jq '.cms_domain_name' $PWD/.secret` 
    local API_DOMAIN_NAME=`jq '.api_domain_name' $PWD/.secret` 
    local SSL=`jq '.ssl' $PWD/.secret`
    local CMS_PORT=`jq '.cms_port' $PWD/.secret`

    local CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME//[ #\"-%\"]}
    local API_DOMAIN_NAME=${API_DOMAIN_NAME//[ #\"-%\"]}
    local SSL=${SSL//[ #\"-%\"]}
    local CMS_PORT=${CMS_PORT//[ #\"-%\"]}
    
    if [[ $CMS_PORT == "443" ]] && [[ ${SSL,,} =~ ^yes$ ]]; then 
        cp --force docker-compose_with_nginx.yml docker-compose.yml
        # change domains 
        sed -i 's~MISHKA_CMS_DOMAIN_NAME~'${CMS_DOMAIN_NAME}'~' ./nginx/conf/conf.d/mishka_cms.conf
        sed -i 's~MISHKA_API_DOMAIN_NAME~'${API_DOMAIN_NAME}'~' ./nginx/conf/conf.d/mishka_api.conf
        # change ports
        sed -i 's~MISHKA_CMS_PORT~443 ssl http2~' ./nginx/conf/conf.d/mishka_cms.conf 
        sed -i 's~MISHKA_API_PORT~443 ssl http2~' ./nginx/conf/conf.d/mishka_api.conf
        # enable ssl 
        sed -i 's~SITE_NAME~'$CMS_DOMAIN_NAME'~' ./nginx/conf/ssl.conf
        sed -i 's~#include~include~' ./nginx/conf/conf.d/mishka_api.conf 
        sed -i 's~#include~include~' ./nginx/conf/conf.d/mishka_cms.conf 
    elif [[ $CMS_PORT == "80" ]]; then 
        cp --force docker-compose_with_nginx.yml docker-compose.yml
        # change domains
        sed -i 's~MISHKA_CMS_DOMAIN_NAME~'${CMS_DOMAIN_NAME}'~' ./nginx/conf/conf.d/mishka_cms.conf
        sed -i 's~MISHKA_API_DOMAIN_NAME~'${API_DOMAIN_NAME}'~' ./nginx/conf/conf.d/mishka_api.conf
        # change ports
        sed -i 's~MISHKA_CMS_PORT~80~' ./nginx/conf/conf.d/mishka_cms.conf 
        sed -i 's~MISHKA_API_PORT~80~' ./nginx/conf/conf.d/mishka_api.conf 
    else 
        cp --force docker-compose_without_nginx.yml docker-compose.yml
    fi

    # change value in docker-compose.yml
    if [ -f $PWD/.secret ]; then 
        local DATABASE_USER=`jq '.database_user' $PWD/.secret`
        local DATABASE_PASSWORD=`jq '.database_password' $PWD/.secret`
        local DATABASE_NAME=`jq '.database_name' $PWD/.secret`
        local POSTGRES_USER=`jq '.postgres_user' $PWD/.secret`
        local POSTGRES_PASSWORD=`jq '.postgres_password' $PWD/.secret`  

        # remove double qoutaion
        local DATABASE_USER=${DATABASE_USER//[ #\"-%\"]}
        local DATABASE_PASSWORD=${DATABASE_PASSWORD//[ #\"-%\"]}
        local DATABASE_NAME=${DATABASE_NAME//[ #\"-%\"]}
        local POSTGRES_USER=${POSTGRES_USER//[ #\"-%\"]}
        local POSTGRES_PASSWORD=${POSTGRES_PASSWORD//[ #\"-%\"]}

        sed -i 's~DATABASE_USER=mishka_user~DATABASE_USER='${DATABASE_USER}'~' docker-compose.yml 
        sed -i 's~DATABASE_PASSWORD=mishka_password~DATABASE_PASSWORD='${DATABASE_PASSWORD}'~' docker-compose.yml 
        sed -i 's~DATABASE_NAME=mishka_database~DATABASE_NAME='${DATABASE_NAME}'~' docker-compose.yml 
        sed -i 's~POSTGRES_USER=postgres~POSTGRES_USER='${POSTGRES_USER}'~' docker-compose.yml 
        sed -i 's~POSTGRES_PASSWORD=postgres~POSTGRES_PASSWORD='${POSTGRES_PASSWORD}'~' docker-compose.yml 
    else 
        echo -e "${Red}.secret file not found, Operation cenceled, Please use 'mishka.sh --build' for install app${NC}"
        exit 1
    fi
   
}


function cleanup() {
    if [ -f docker-compose.yml ] && [ -f .secret ]; then 
        CMS_PORT=`jq '.cms_port' $PWD/.secret`
        CMS_PORT=${CMS_PORT//[ #\"-%\"]}

        # Stop Services and Delete Networks
        docker-compose -p mishka_cms down
        
        # Delete Images
        if [[ $CMS_PORT == "80" ]] || [[ $CMS_PORT == "443" ]]; then 
            docker image rm nginx:1.20.1-alpine mishak_app:latest mishkagroup/postgresql:3.14
            echo -e "${Red} mishka images deleted..${NC}"
        else 
            docker image rm mishak_app:latest mishkagroup/postgresql:3.14
            echo -e "${Red} mishka images deleted..${NC}"
        fi

        # Delete SSL certificate 
        if [ -f certbot/letsencrypt ]; then 
            rm -r certbot/letsencrypt
            echo -e "${Red} mishka ssl deleted..${NC}"
        fi

        # Delete temp Files
        if [ -f ../../Dockerfile ]; then
            rm docker-compose.yml ../../Dockerfile
            echo -e "${Green} mishka Temp Files deleted..${NC}"
        fi

        # Delete Volumes
        docker volume rm mishka_cms_database mishka_cms_cms
        echo -e "${Green} mishka volumes deleted..${NC}"

        # Delete Secrets
        if [ -f $PWD/.secret ]; then 
            rm $PWD/.secret
            echo -e "${Green} mishka secret file deleted..${NC}"
        fi 

        # Fresh nginx conf
        cp --force nginx/conf/sample_conf/mishka_* nginx/conf/conf.d
       
        
    else 
        echo -e "${Red}NOTHING EXIST FOR CELAN !${NC}"
    fi
}


function ssl_generator() {
    local ADMIN_EMAIL=$1
    local CMS_DOMAIN_NAME=$2
    local API_DOMAIN_NAME=$3

    # create dhparam2048
    if [ ! -f certbot/master_certificates/dhparam2048.pem ]; then 
        openssl dhparam -out certbot/master_certificates/dhparam2048.pem 2048
    fi

    # remove old certs
    if [ -d ./certbot/letsencrypt ]; then 
        rm -rf ./certbot/letsencrypt
    fi

    # create ssl for domains
    docker run -it --rm --name certbot  \
    -p 80:80 \
    -p 443:443 \
    -v "$PWD/certbot/letsencrypt:/etc/letsencrypt"  \
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

#=============================================================

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




case $1 in 
    "--build")
        if [ ! -f $PWD/.secret ]; then 
            if [ -d .git ];then 
                git pull
            fi 

            cp Dockerfile ../../

            read -p $'\e[32mChoose Environment Type [\'prod or dev, defualt is dev\']\e[0m: ' ENV_TYPE

            if [[ ${ENV_TYPE,,} =~ ^prod$ ]]; then # convert user input to lowercase then check it
                # check web server ports to close
                if netstat -nultp | egrep -w '80|443' > /dev/null; then
                        echo -e "${Red}another apps using port 80 or 443, please kill the apps and rerun mishka.sh --build !${NC}"
                        exit 1
                else
                    # get data from user
                    read -p $'\e[32mEnter Your Database User [default is \'mishka_user\']\e[0m: ' DATABASE_USER
                    read -s -p $'\e[32mEnter Your Database Password [default is \'mishka_password\']\e[0m: ' DATABASE_PASSWORD
                    echo
                    read -p $'\e[32mEnter Your Database Name [default is \'mishka_database\']\e[0m: ' DATABASE_NAME
                    read -p $'\e[32mEnter Your Postgres User [default is \'postgres\']\e[0m: ' POSTGRES_USER
                    read -s -p $'\e[32mEnter Your Postgres Password [default is \'postgres\']\e[0m: ' POSTGRES_PASSWORD
                    echo
                    read -p $'\e[32mEnter Your CMS address (Domain or IP)  [default is \'127.0.0.1\']\e[0m: ' CMS_DOMAIN_NAME
                    if ip_checker $CMS_DOMAIN_NAME; then
                        CMS_DOMAIN_NAME=$CMS_DOMAIN_NAME
                        API_DOMAIN_NAME=$CMS_DOMAIN_NAME
                        CMS_PORT="4000"
                        API_PORT="4001"
                    elif domain_checker $CMS_DOMAIN_NAME; then
                        while true; do 
                            read -p $'\e[32mEnter Your API address \e[0m: ' API_DOMAIN_NAME
                            if [[ $CMS_DOMAIN_NAME =~ $API_DOMAIN_NAME ]]; then 
                                echo -e "${Red}address for api must be diffrent than address for cms !${NC}"
                            elif ip_checker $API_DOMAIN_NAME; then
                                echo -e "${Red}address for api must be domain or sub-domain name!${NC}"
                            elif domain_checker $API_DOMAIN_NAME || domain_checker $API_DOMAIN_NAME; then  
                                break
                            fi
                        done 

                        read -p $'\e[32mDo You Want to Enable SSL ? (YES/NO)  [default is YES]\e[0m: ' SSL
                        SSL=${SSL:-"YES"}
                        if [[ ${SSL,,} =~ ^yes$ ]]; then # convert user input to lowercase then check it
                            while true; do 
                                read -p $'\e[32mEnter Your Email Address:\e[0m: ' ADMIN_EMAIL
                                if email_checker $ADMIN_EMAIL; then
                                    ssl_generator $ADMIN_EMAIL $CMS_DOMAIN_NAME $API_DOMAIN_NAME
                                    if [[ $? == "0" ]]; then
                                        break
                                    else
                                        echo -e "${Red}certbot can't create ssl because port is already allocated or image can not download!${NC}"
                                        exit 1
                                    fi 
                                else 
                                    echo -e "${Red}email address invalid please enter correct email address!${NC}"
                                fi
                            done

                            CMS_PORT="443"
                            API_PORT="443" 
                            PROTOCOL="https" 
                        else
                            CMS_PORT="80"
                            API_PORT="80" 
                            PROTOCOL="http"
                        fi 
                    fi 
                fi
            fi
            
            # set default value for variables
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

            # create new token
            TOKEN_JWT_KEY=`dd if=/dev/urandom bs=32 count=1 | base64 | sed 's/+/-/g; s/\//_/g; s/=//g'`
            SECRET_CURRENT_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo` 
            SECRET_REFRESH_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo`
            SECRET_ACCESS_TOKEN_SALT=`strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo`

            # store data in file
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
            }' > $PWD/.secret

            
            # build image
            docker build -t mishak_app:latest -f ../../Dockerfile \
                --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
                --build-arg SECRET_KEY_BASE_HTML=$SECRET_KEY_BASE_HTML \
                --build-arg SECRET_KEY_BASE_API=$SECRET_KEY_BASE_API \
                --build-arg LIVE_VIEW_SALT=$LIVE_VIEW_SALT \
                --build-arg TOKEN_JWT_KEY=$TOKEN_JWT_KEY \
                --build-arg SECRET_CURRENT_TOKEN_SALT=$SECRET_CURRENT_TOKEN_SALT \
                --build-arg SECRET_REFRESH_TOKEN_SALT=$SECRET_REFRESH_TOKEN_SALT \
                --build-arg SECRET_ACCESS_TOKEN_SALT=$SECRET_ACCESS_TOKEN_SALT \
                --build-arg CMS_DOMAIN_NAME=$CMS_DOMAIN_NAME \
                --build-arg API_DOMAIN_NAME=$API_DOMAIN_NAME \
                --build-arg CMS_PORT=$CMS_PORT \
                --build-arg API_PORT=$API_PORT \
                --build-arg PROTOCOL=$PROTOCOL \
                ../../ --no-cache
            
            if [[ $? == 0 ]]; then # if docker image was build
                # update docker-compose file with values
                update_config

                # start containers 
                docker-compose -p mishka_cms up -d 

                # remove double qoutaion
                CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME//[ #\"-%\"]}
                API_DOMAIN_NAME=${API_DOMAIN_NAME//[ #\"-%\"]}
                CMS_PORT=${CMS_PORT//[ #\"-%\"]}
                API_PORT=${API_PORT//[ #\"-%\"]}

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

                rm ../../Dockerfile
            else # if docker image was not build, we do cleanup
                echo -e "${Red}we can't make docker image, Cleanup Process is running.....${NC}" 
                cleanup
                echo -e "${Green}Clenup Process is done.${NC}"
            fi
        else 
            echo -e "${Red}your previously build exist, Operation cenceled, Please use 'mishka.sh --update' for update you app${NC}"
            exit 1
        fi    

    ;;

    "--update")
        if [ -d .git ];then 
            git pull
        fi 

        cp Dockerfile ../../
        # using old value
        TOKEN_JWT_KEY=`jq '.token_jwt_key' $PWD/.secret` 
        SECRET_CURRENT_TOKEN_SALT=`jq '.secret_current_token_salt' $PWD/.secret` 
        SECRET_REFRESH_TOKEN_SALT=`jq '.secret_refresh_token_salt' $PWD/.secret` 
        SECRET_ACCESS_TOKEN_SALT=`jq '.secret_access_token_salt' $PWD/.secret` 
        CMS_DOMAIN_NAME=`jq '.cms_domain_name' $PWD/.secret` 
        API_DOMAIN_NAME=`jq '.api_domain_name' $PWD/.secret` 
        CMS_PORT=`jq '.cms_port' $PWD/.secret` 
        API_PORT=`jq '.api_port' $PWD/.secret` 

        if [[ $TOKEN_JWT_KEY != "" ]]; then 
            docker build -t mishak_app:latest -f ../../Dockerfile \
                --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
                --build-arg SECRET_KEY_BASE_HTML=$SECRET_KEY_BASE_HTML \
                --build-arg SECRET_KEY_BASE_API=$SECRET_KEY_BASE_API \
                --build-arg LIVE_VIEW_SALT=$LIVE_VIEW_SALT \
                --build-arg TOKEN_JWT_KEY=$TOKEN_JWT_KEY \
                --build-arg SECRET_CURRENT_TOKEN_SALT=$SECRET_CURRENT_TOKEN_SALT \
                --build-arg SECRET_REFRESH_TOKEN_SALT=$SECRET_REFRESH_TOKEN_SALT \
                --build-arg SECRET_ACCESS_TOKEN_SALT=$SECRET_ACCESS_TOKEN_SALT \
                --build-arg CMS_DOMAIN_NAME=$CMS_DOMAIN_NAME \
                --build-arg API_DOMAIN_NAME=$API_DOMAIN_NAME \
                --build-arg CMS_PORT=$CMS_PORT \
                --build-arg API_PORT=$API_PORT \
                --build-arg PROTOCOL=$PROTOCOL \
                ../../ --no-cache
            
            # update docker-compose file with values
            update_config

            echo -e "${Green}Your App updated Successfully${NC}"

            # recreate containers
            docker-compose -p mishka_cms up -d 
            rm ../../Dockerfile
        else 
            echo -e "${Red}secret file does not exist in $PWD/ ${Green} Please use 'mishka.sh --build' for fresh install ${NC}"
        fi
    ;;

    "--start")
        if [ -f $PWD/.secret ]; then 
            docker-compose -p mishka_cms up -d 
            CMS_DOMAIN_NAME=`jq '.cms_domain_name' $PWD/.secret` 
            API_DOMAIN_NAME=`jq '.api_domain_name' $PWD/.secret` 
            CMS_PORT=`jq '.cms_port' $PWD/.secret` 
            API_PORT=`jq '.api_port' $PWD/.secret` 
            ADMIN_EMAIL=`jq '.admin_email' $PWD/.secret`

            # remove double qoutaion
            CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME//[ #\"-%\"]}
            API_DOMAIN_NAME=${API_DOMAIN_NAME//[ #\"-%\"]}
            CMS_PORT=${CMS_PORT//[ #\"-%\"]}
            API_PORT=${API_PORT//[ #\"-%\"]}

            if domain_checker $CMS_DOMAIN_NAME && domain_checker $API_DOMAIN_NAME && [[ $ADMIN_EMAIL != "example@example.com" ]]; then 
                echo -e "${Green}Mishka Cms Available on    --> $SPACE https://$CMS_DOMAIN_NAME $END_SPACE ${NC}"
                echo -e "${Green}Mishka Api Available on    --> $SPACE https://$API_DOMAIN_NAME $END_SPACE ${NC}" 
            else 
                echo -e "${Green}Mishka Cms Available on    --> $SPACE http://$CMS_DOMAIN_NAME:$CMS_PORT $END_SPACE ${NC}"
                echo -e "${Green}Mishka Api Available on    --> $SPACE http://$API_DOMAIN_NAME:$API_PORT $END_SPACE ${NC}"
            fi
        else 
            echo -e "${Red}secret file does not exist in $PWD/ ${Green} Please use 'mishka.sh --build' for install ${NC}"
        fi
    ;;

    "--stop")
        if [[ $2 != "" ]]; then 
            docker stop $2 && docker rm $2
        else 
            echo -e "${Red}please specific container name for stop$PWD ${NC}"
        fi
    ;;

    "--remove")
        docker-compose -p mishka_cms down
    ;;

    "--destroy")
        read -p $'\e[31mthis stage PERMANENTLY DELETE Mishka_CMS, ARE YOUR SURE ? (Y/N)\e[0m: ' INPUT
        if [[ ${INPUT,,} =~ ^y$ ]]; then 
            cleanup
        else 
            echo -e "${Red} Your Operation is canceled..${NC}" 
        fi
    ;;

    "--backup")
       echo "this is backup"
    ;;

    "--logs")
        if [[ $2 != "" ]]; then 
            docker logs -f $2
        else 
            docker-compose -p mishka_cms logs -f 
        fi
    ;;

    "--help")
        echo -e "${Green}Below Options is Available:
            --build     create new token and make images 
            --update    update images with old token
            --start     run one or all containers
            --stop      stop one or all containers
            --remove    stop and remove all containers plus network
            --destroy   stop and remove all containers plus netwok also remove docker images, volume
            --ssl       this flag detect your domains and create ssl certificate or renew ssl certificate if time near to expire
            --logs      show log of specific container of all containers
            --backup    create database dump and dynamic files${NC}"
    ;;

    *)
        echo -e "${Red}$2 Does not Exist !${NC}"
        echo -e "${Green} Using 'mishka.sh --help' for more information"
    ;;

esac


