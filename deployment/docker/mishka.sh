#!/bin/bash

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




function update_compose() {        
    CMS_DOMAIN_NAME=`jq '.cms_domain_name' $PWD/.secret` 
    API_DOMAIN_NAME=`jq '.api_domain_name' $PWD/.secret` 
    CMS_PORT=`jq '.cms_port' $PWD/.secret`
    CMS_PORT=${CMS_PORT//[ #\"-%\"]}
    if [[ $CMS_PORT == "80" ]]; then 
        cp --force docker-compose_with_nginx.yml docker-compose.yml
        sed -i 's~MISHKA_CMS_DOMAIN_NAME~'${CMS_DOMAIN_NAME}'~' ./nginx/conf/conf.d/mishka_cms.conf
        sed -i 's~MISHKA_API_DOMAIN_NAME~'${API_DOMAIN_NAME}'~' ./nginx/conf/conf.d/mishka_api.conf 
    else 
        cp --force docker-compose_without_nginx.yml docker-compose.yml
    fi

    # change value in docker-compose.yml
    if [ -f $PWD/.secret ]; then 
        DATABASE_USER=`jq '.database_user' $PWD/.secret`
        DATABASE_PASSWORD=`jq '.database_password' $PWD/.secret`
        DATABASE_NAME=`jq '.database_name' $PWD/.secret`
        POSTGRES_USER=`jq '.postgres_user' $PWD/.secret`
        POSTGRES_PASSWORD=`jq '.postgres_password' $PWD/.secret`  

        # remove double qoutaion
        DATABASE_USER=${DATABASE_USER//[ #\"-%\"]}
        DATABASE_PASSWORD=${DATABASE_PASSWORD//[ #\"-%\"]}
        DATABASE_NAME=${DATABASE_NAME//[ #\"-%\"]}
        POSTGRES_USER=${POSTGRES_USER//[ #\"-%\"]}
        POSTGRES_PASSWORD=${POSTGRES_PASSWORD//[ #\"-%\"]}

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
    if [ -f docker-compose.yml ] || [ -f .secret ]; then 
        docker-compose -p mishka_cms down
        CMS_PORT=`jq '.cms_port' $PWD/.secret`
        CMS_PORT=${CMS_PORT//[ #\"-%\"]}
        if [[ $CMS_PORT == "80" ]]; then 
            docker image rm nginx:1.20.1-alpine mishak_app:latest mishkagroup/postgresql:3.14
        else 
            docker image rm mishak_app:latest mishkagroup/postgresql:3.14
        fi
        echo -e "${Red} mishka images deleted..${NC}"
        docker volume rm mishka_cms_database mishka_cms_cms
        echo -e "${Green} mishka volumes deleted..${NC}"
        rm $PWD/.secret
        echo -e "${Green} mishka secret file deleted..${NC}"
        if [ -f ../../Dockerfile ]; then
            rm docker-compose.yml ../../Dockerfile
        fi
    else 
        echo -e "${Red}NOTHING EXIST FOR CELAN !${NC}"
    fi
}


#=============================================================

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

            if [[ $ENV_TYPE == "prod" ]] || [[ $ENV_TYPE == "PROD" ]]; then
                # get data from user
                read -p $'\e[32mEnter Your Database User [default is \'mishka_user\']\e[0m: ' DATABASE_USER
                read -s -p $'\e[32mEnter Your Database Password [default is \'mishka_password\']\e[0m: ' DATABASE_PASSWORD
                echo
                read -p $'\e[32mEnter Your Database Name [default is \'mishka_database\']\e[0m: ' DATABASE_NAME
                read -p $'\e[32mEnter Your Postgres User [default is \'postgres\']\e[0m: ' POSTGRES_USER
                read -s -p $'\e[32mEnter Your Postgres Password [default is \'postgres\']\e[0m: ' POSTGRES_PASSWORD
                echo
                read -p $'\e[32mEnter Your CMS address  [default is \'127.0.0.1\']\e[0m: ' CMS_DOMAIN_NAME
                if [[ $CMS_DOMAIN_NAME =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    CMS_DOMAIN_NAME=$CMS_DOMAIN_NAME
                    API_DOMAIN_NAME=$CMS_DOMAIN_NAME
                    CMS_PORT="4000"
                    API_PORT="4001"
                elif [[ $CMS_DOMAIN_NAME != "" ]]; then
                    while true; do 
                        read -p $'\e[32mEnter Your API address \e[0m: ' API_DOMAIN_NAME
                        if [[ $CMS_DOMAIN_NAME =~ $API_DOMAIN_NAME ]]; then 
                            echo -e "${Red}address for api must be diffrent than address for cms !${NC}"
                        elif [[ $API_DOMAIN_NAME =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                            echo -e "${Red}address for api must be domain or sub-domain name!${NC}"
                        else 
                            break
                        fi
                    done 

                    CMS_PORT="80"
                    API_PORT="80" 
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
            "api_port": "'$API_PORT'"
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
                ../../ --no-cache
            
            if [[ $? == 0 ]]; then # if docker image was build
                # update docker-compose file with values
                update_compose

                # start containers 
                docker-compose -p mishka_cms up -d 

                # remove double qoutaion
                CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME//[ #\"-%\"]}
                API_DOMAIN_NAME=${API_DOMAIN_NAME//[ #\"-%\"]}
                CMS_PORT=${CMS_PORT//[ #\"-%\"]}
                API_PORT=${API_PORT//[ #\"-%\"]}

                echo -e "${Green}=======================================================================================================${NC}"
                echo -e "${Green}Mishka Cms Available on    --> $SPACE $CMS_DOMAIN_NAME:$CMS_PORT $END_SPACE ${NC}"
                echo -e "${Green}Mishka Api Available on    --> $SPACE $API_DOMAIN_NAME:$API_PORT $END_SPACE ${NC}"  
                echo -e "${Green}==================================================================================================${NC}"

                echo -e
                echo -e "${Yellow}=======================================================================================================${NC}"
                echo -e "${Yellow}Your Database User is      --> $SPACE $DATABASE_USER $END_SPACE ${NC}"
                echo -e "${Yellow}Your Database Name is      --> $SPACE $DATABASE_NAME $END_SPACE ${NC}"
                echo -e "${Yellow}Your Database Password is: --> $SPACE $DATABASE_PASSWORD $END_SPACE ${NC}"
                echo -e "${Yellow}Your Postgres User is:     --> $SPACE $POSTGRES_USER $END_SPACE ${NC}"
                echo -e "${Yellow}Your Postgres Password is: --> $SPACE $POSTGRES_PASSWORD $END_SPACE ${NC}"
                echo -e "${Yellow}==================================================================================================${NC}"
                 
                echo -e 
                echo -e "${Red}=======================================================================================================${NC}"
                echo -e "${Red}KEEP THIS VALUE IN SECRET, IF YOU LOSS THEM YOUR USERS CAN'T LOGIN INTO MISHKA CMS AFTER UPDATE:"     
                echo -e "${Red}token_jwt_key:             --> $SPACE $TOKEN_JWT_KEY $END_SPACE ${NC}"                                                                              
                echo -e "${Red}secret_current_token_salt: --> $SPACE $SECRET_CURRENT_TOKEN_SALT $END_SPACE ${NC}"                                                      
                echo -e "${Red}secret_refresh_token_salt: --> $SPACE $SECRET_REFRESH_TOKEN_SALT $END_SPACE ${NC}"                                                       
                echo -e "${Red}secret_access_token_salt:  --> $SPACE $SECRET_ACCESS_TOKEN_SALT $END_SPACE ${NC}"                                                           
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
                ../../ --no-cache
            
            # update docker-compose file with values
            update_compose

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

            # remove double qoutaion
            CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME//[ #\"-%\"]}
            API_DOMAIN_NAME=${API_DOMAIN_NAME//[ #\"-%\"]}
            CMS_PORT=${CMS_PORT//[ #\"-%\"]}
            API_PORT=${API_PORT//[ #\"-%\"]}

            echo -e "${Green}Mishka Cms Available on $CMS_DOMAIN_NAME:$CMS_PORT${NC}"
            echo -e "${Green}Mishka Api Available on $API_DOMAIN_NAME:$API_PORT${NC}"
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
        if [[ $INPUT == "Y" ]] || [[ $INPUT == "y" ]]; then 
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
            --build   create new token and make images 
            --update  update images with old token
            --start   run one or all containers
            --stop    stop one or all containers
            --remove  stop and remove all containers plus network
            --destroy   stop and remove all containers plus netwok also remove docker images, volume
            --logs    show log of specific container of all containers
            --backup  create database dump and dynamic files${NC}"
    ;;

    *)
        echo -e "${Red}$2 Does not Exist !${NC}"
        echo -e "${Green} Using 'mishka.sh --help' for more information"
    ;;

esac


