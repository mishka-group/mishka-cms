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
SECRET_KEY_BASE=$(strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo) \
SECRET_KEY_BASE_HTML=$(strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo) \
SECRET_KEY_BASE_API=$(strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 64 | tr -d '\n'; echo) \
LIVE_VIEW_SALT=$(strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 32 | tr -d '\n'; echo) \
SECRET_CURRENT_TOKEN_SALT=$(strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo) \
SECRET_REFRESH_TOKEN_SALT=$(strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo) \
SECRET_ACCESS_TOKEN_SALT=$(strings /dev/urandom | grep -o '[[:alpha:]]' | head -n 30 | tr -d '\n'; echo) 







function update_compose() {
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
    docker-compose -p mishka_cms down
    docker image rm mishak_app:latest mishka_db:13.4
    echo -e "${Red} mishka images deleted..${NC}"
    docker volume rm mishka_cms_database mishka_cms_cms
    echo -e "${Green} mishka volumes deleted..${NC}"
    rm $PWD/.secret
    echo -e "${Green} mishka secret file deleted..${NC}"
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

            read -p $'\e[32mChoose Environment Type [\'prod or dev, defualt is dev\']\e[0m: ' ENV_TYPE

            if [[ $ENV_TYPE == "prod" ]] || [[ $ENV_TYPE == "PROD" ]]; then
                # get data from user
                read -p $'\e[32mEnter Your Database User [default is \'mishka_user\']\e[0m: ' DATABASE_USER
                DATABASE_USER=${DATABASE_USER:-"mishka_user"}
                read -s -p $'\e[32mEnter Your Database Password [default is \'mishka_password\']\e[0m: ' DATABASE_PASSWORD
                DATABASE_PASSWORD=${DATABASE_PASSWORD:-"mishka_password"}
                echo
                read -p $'\e[32mEnter Your Database Name [default is \'mishka_database\']\e[0m: ' DATABASE_NAME
                DATABASE_NAME=${DATABASE_NAME:-"mishka_database"}
                read -p $'\e[32mEnter Your Postgres User [default is \'postgres\']\e[0m: ' POSTGRES_USER
                POSTGRES_USER=${POSTGRES_USER:-"postgres"}
                read -s -p $'\e[32mEnter Your Postgres Password [default is \'postgres\']\e[0m: ' POSTGRES_PASSWORD
                POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"postgres"}
                echo
                read -p $'\e[32mEnter Your Host Name or Host IP  [default is \'127.0.0.1\']\e[0m: ' DOMAIN_NAME
                DOMAIN_NAME=${DOMAIN_NAME:-"127.0.0.1"}
            else 
                DOMAIN_NAME="127.0.0.1"
            fi
            

            # create new token
            TOKEN_JWT_KEY=`dd if=/dev/urandom bs=32 count=1 | base64 | sed 's/+/-/g; s/\//_/g; s/=//g'`

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
            "domain_name": "'$DOMAIN_NAME'"
            }' > $PWD/.secret

            
            # build image
            docker build -t mishak_app:latest \
                --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
                --build-arg SECRET_KEY_BASE_HTML=$SECRET_KEY_BASE_HTML \
                --build-arg SECRET_KEY_BASE_API=$SECRET_KEY_BASE_API \
                --build-arg LIVE_VIEW_SALT=$LIVE_VIEW_SALT \
                --build-arg TOKEN_JWT_KEY=$TOKEN_JWT_KEY \
                --build-arg SECRET_CURRENT_TOKEN_SALT=$SECRET_CURRENT_TOKEN_SALT \
                --build-arg SECRET_REFRESH_TOKEN_SALT=$SECRET_REFRESH_TOKEN_SALT \
                --build-arg SECRET_ACCESS_TOKEN_SALT=$SECRET_ACCESS_TOKEN_SALT \
                --build-arg DOMAIN_NAME=$DOMAIN_NAME \
                . --no-cache
            
            if [[ $? == 0 ]]; then # if docker image was build
                # update docker-compose file with values
                update_compose

                # start containers 
                docker-compose -p mishka_cms up -d 

                echo -e "${Green}Mishka Cms Available on $DOMAIN_NAME:4000${NC}"
                echo -e "${Green}Mishka Api Available on $DOMAIN_NAME:4001${NC}"
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

        # using old value
        TOKEN_JWT_KEY=`jq '.token_jwt_key' $PWD/.secret` 
        SECRET_CURRENT_TOKEN_SALT=`jq '.secret_current_token_salt' $PWD/.secret` 
        SECRET_REFRESH_TOKEN_SALT=`jq '.secret_refresh_token_salt' $PWD/.secret` 
        SECRET_ACCESS_TOKEN_SALT=`jq '.secret_access_token_salt' $PWD/.secret` 
        DOMAIN_NAME=`jq '.domain_name' $PWD/.secret` 

        if [[ $TOKEN_JWT_KEY != "" ]]; then 
            docker build -t mishak_app:latest \
                --build-arg SECRET_KEY_BASE=$SECRET_KEY_BASE \
                --build-arg SECRET_KEY_BASE_HTML=$SECRET_KEY_BASE_HTML \
                --build-arg SECRET_KEY_BASE_API=$SECRET_KEY_BASE_API \
                --build-arg LIVE_VIEW_SALT=$LIVE_VIEW_SALT \
                --build-arg TOKEN_JWT_KEY=$TOKEN_JWT_KEY \
                --build-arg SECRET_CURRENT_TOKEN_SALT=$SECRET_CURRENT_TOKEN_SALT \
                --build-arg SECRET_REFRESH_TOKEN_SALT=$SECRET_REFRESH_TOKEN_SALT \
                --build-arg SECRET_ACCESS_TOKEN_SALT=$SECRET_ACCESS_TOKEN_SALT \
                --build-arg DOMAIN_NAME=$DOMAIN_NAME \
                . --no-cache
            
            # update docker-compose file with values
            update_compose

            # recreate containers
            docker-compose -p mishka_cms up -d 
        else 
            echo -e "${Red}secret file does not exist in $PWD/ ${Green} Please use 'mishka.sh --build' for fresh install ${NC}"
        fi
    ;;

    "--start")
        if [ -f $PWD/.secret ]; then 
            docker-compose -p mishka_cms up -d 
            DOMAIN_NAME=`jq '.domain_name' $PWD/.secret` 
            echo -e "${Green}Mishka Cms Available on $DOMAIN_NAME:4000${NC}"
            echo -e "${Green}Mishka Api Available on $DOMAIN_NAME:4001${NC}"
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


