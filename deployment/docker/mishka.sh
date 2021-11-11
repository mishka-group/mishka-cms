#!/bin/bash
# set -e -x

# color variables
source src/variables.sh 

# variables for build
source src/functions.sh 



#=============================================================

# check requirments before run shell
check_requirements


if [ ! -f $PWD/etc/.secret ]; then  # build 
    if [ -d ../../.git ];then 
        git pull
    fi 


    read -p $'\e[32mChoose Environment Type [\'prod or dev, defualt is dev\']\e[0m: ' ENV_TYPE

    if [[ ${ENV_TYPE,,} =~ ^prod$ ]]; then # convert user input to lowercase then check it
        cp dockers/Dockerfile ../../

        # check web server ports to close
        if netstat -nultp | egrep -w '80|443' > /dev/null; then
                echo -e "${Red}another apps using port 80 or 443, please kill the apps and rerun mishka.sh --build !${NC}"
                exit 1
        fi 
        
        # get data from user
        read -p $'\e[32mEnter Your Database User [default is \'mishka_user\']\e[0m: ' DATABASE_USER
        read -s -p $'\e[32mEnter Your Database Password [default is \'mishka_password\']\e[0m: ' DATABASE_PASSWORD
        echo
        read -p $'\e[32mEnter Your Database Name [default is \'mishka_database\']\e[0m: ' DATABASE_NAME
        read -p $'\e[32mEnter Your Postgres User [default is \'postgres\']\e[0m: ' POSTGRES_USER
        read -s -p $'\e[32mEnter Your Postgres Password [default is \'postgres\']\e[0m: ' POSTGRES_PASSWORD
        echo 
        echo -e "${Red}Please enable the email system for some verification, also, you will need the email server configuration!${NC}"
        read -s -p $'\e[32mDo You Want Enable Email System (YES/NO) ? [default is YES] \'\']\e[0m: ' EMAIL_CONFIG
        EMAIL_CONFIG=${EMAIL_CONFIG:-"YES"}
        if [[ "${EMAIL_CONFIG,,}" =~ ^yes$ ]]; then 
            email_system
        fi

        echo
        read -p $'\e[32mEnter Your CMS address (Domain or IP)  [default is \'localhost\']\e[0m: ' CMS_DOMAIN_NAME
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
        

        # set default value for variables
        default_values
        
        # create new secrets
        secret_generators

        # store configs
        store_configs
        
        
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
            --build-arg EMAIL_SYSTEM=$EMAIL_SYSTEM \
            --build-arg EMAIL_DOMAIN=$EMAIL_DOMAIN \
            --build-arg EMAIL_PORT=$EMAIL_PORT \
            --build-arg EMAIL_SERVER=$EMAIL_SERVER \
            --build-arg EMAIL_HOSTNAME=$EMAIL_HOSTNAME \
            --build-arg EMAIL_USERNAME=$EMAIL_USERNAME \
            --build-arg EMAIL_PASSWORD=$EMAIL_PASSWORD \
            ../../ --no-cache
        
        if [[ $? == 0 ]]; then # if docker image was build
            # update docker-compose file with values
            update_config

            # start containers 
            docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d 


            # print build output
            print_build_output
        
            
            rm ../../Dockerfile
        else # if docker image was not build, we do cleanup
            echo -e "${Red}we can't make docker image, Cleanup Process is running.....${NC}" 
            cleanup
        fi
    else # dev
        ENV_TYPE="dev"
        
        # set default value for variables
        default_values

        # create new secrets
        secret_generators

        # store configs
        store_configs

        # create env file
        env_generator

        # update docker-compose file with values
        update_config

        docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d
    fi   
else 
    load_configs
    if [[ ${ENV_TYPE,,} =~ ^prod$ ]]; then  #production env  
        case $1 in 
            "update")
                if [ -d ../../.git ];then 
                    git pull
                fi 

                cp dockers/Dockerfile ../../
                # load configs
                load_configs

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
                        --build-arg EMAIL_SYSTEM=$EMAIL_SYSTEM \
                        --build-arg EMAIL_DOMAIN=$EMAIL_DOMAIN \
                        --build-arg EMAIL_PORT=$EMAIL_PORT \
                        --build-arg EMAIL_SERVER=$EMAIL_SERVER \
                        --build-arg EMAIL_HOSTNAME=$EMAIL_HOSTNAME \
                        --build-arg EMAIL_USERNAME=$EMAIL_USERNAME \
                        --build-arg EMAIL_PASSWORD=$EMAIL_PASSWORD \
                        ../../ --no-cache
                    
                    # update docker-compose file with values
                    update_config

                    echo -e "${Green}Your App updated Successfully${NC}"

                    # recreate containers
                    docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d 
                    rm ../../Dockerfile
                else 
                    echo -e "${Red}secret file does not exist in $PWD/ ${Green} Please use 'mishka.sh build' for fresh install ${NC}"
                fi
            ;;

            "start")
                docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d 

                # load configs
                load_configs

                if domain_checker $CMS_DOMAIN_NAME && domain_checker $API_DOMAIN_NAME && [[ $ADMIN_EMAIL != "example@example.com" ]]; then 
                    echo -e "${Green}Mishka Cms Available on    --> $SPACE https://$CMS_DOMAIN_NAME $END_SPACE ${NC}"
                    echo -e "${Green}Mishka Api Available on    --> $SPACE https://$API_DOMAIN_NAME $END_SPACE ${NC}" 
                else 
                    echo -e "${Green}Mishka Cms Available on    --> $SPACE http://$CMS_DOMAIN_NAME:$CMS_PORT $END_SPACE ${NC}"
                    echo -e "${Green}Mishka Api Available on    --> $SPACE http://$API_DOMAIN_NAME:$API_PORT $END_SPACE ${NC}"
                fi
            ;;

            "stop")
                if [[ $2 != "" ]]; then 
                    docker stop $2 && docker rm $2
                else 
                    docker ps --quiet --format "{{.Names}}" > /tmp/container_name
                    echo -e "${Red}please specific container name for stop${NC}"
                    echo -e "${Red}you have containers with name:${NC}"
                    for NAME in $(cat /tmp/container_name); do 
                        echo -e "${Red}$NAME${NC}"
                    done
                fi
            ;;

            "remove")
                docker-compose -f dockers/docker-compose.yml  -p mishka_cms down
            ;;

            "destroy")
                read -p $'\e[31mthis stage PERMANENTLY DELETE Mishka_CMS, ARE YOUR SURE ? (YES/NO)\e[0m: ' INPUT
                if [[ ${INPUT,,} =~ ^yes$ ]]; then 
                    cleanup
                else 
                    echo -e "${Red} Your Operation is canceled..${NC}" 
                fi
            ;;

            "email")
                # load configs
                load_configs

                if [[ "${EMAIL_CONFIG,,}" =~ ^yes$ ]]; then 
                    read -s -p $'\e[32mDo You Want OVERWRITE Email System Config ? (YES/NO)\'\']\e[0m: ' EMAIL_CONFIG
                    if [[ "${EMAIL_CONFIG,,}" =~ ^yes$ ]]; then 
                        email_system
                        store_configs
                    else
                        echo -e "${Red} Your Operation is canceled..${NC}"  
                    fi 
                else 
                    email_system
                    store_configs
                fi 
            ;;

            "logs")
                if [[ $2 != "" ]]; then 
                    docker logs -f $2
                else 
                    docker-compose -f dockers/docker-compose.yml  -p mishka_cms logs -f 
                fi
            ;;

            "help")
                echo -e "${Green}Below Options is Available:
                    update    update images with old token
                    start     run all containers
                    stop      stop one or all containers
                    remove    stop and remove all containers plus network
                    destroy   stop and remove all containers plus netwok also remove docker images, volume
                    email     enable email system for cms
                    logs      show log of specific container of all containers${NC}"
            ;;

            *)
                echo -e "${Red}$2 Does not Exist !${NC}"
                echo -e "${Green} Using 'mishka.sh help' for more information"
            ;;

        esac
    else 
        case $1 in 
            "start")
                if [ -f $PWD/etc/.secret ]; then 
                    docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d 

                    # load configs
                    load_configs


                    if domain_checker $CMS_DOMAIN_NAME && domain_checker $API_DOMAIN_NAME && [[ $ADMIN_EMAIL != "example@example.com" ]]; then 
                        echo -e "${Green}Mishka Cms Available on    --> $SPACE https://$CMS_DOMAIN_NAME $END_SPACE ${NC}"
                        echo -e "${Green}Mishka Api Available on    --> $SPACE https://$API_DOMAIN_NAME $END_SPACE ${NC}" 
                    else 
                        echo -e "${Green}Mishka Cms Available on    --> $SPACE http://$CMS_DOMAIN_NAME:$CMS_PORT $END_SPACE ${NC}"
                        echo -e "${Green}Mishka Api Available on    --> $SPACE http://$API_DOMAIN_NAME:$API_PORT $END_SPACE ${NC}"
                    fi
                else 
                    echo -e "${Red}secret file does not exist in $PWD/etc ${Green} Please use 'mishka.sh --build' for install ${NC}"
                fi
            ;;

            "stop")
                if [[ $2 != "" ]]; then 
                    docker stop $2 && docker rm $2
                else 
                    echo -e "${Red}please specific container name for stop$PWD ${NC}"
                fi
            ;;

            "remove")
                docker-compose -f dockers/docker-compose.yml  -p mishka_cms down
            ;;

            "destroy")
                read -p $'\e[31mthis stage PERMANENTLY DELETE Mishka_CMS, ARE YOUR SURE ? (YES/NO)\e[0m: ' INPUT
                if [[ ${INPUT,,} =~ ^yes$ ]]; then 
                    cleanup
                else 
                    echo -e "${Red} Your Operation is canceled..${NC}" 
                fi
            ;;


            "logs")
                if [[ $2 != "" ]]; then 
                    docker logs -f $2
                else 
                    docker-compose -f dockers/docker-compose.yml  -p mishka_cms logs -f 
                fi
            ;;

            "clean")
                case $2 in
                    "--diskdb")
                        docker stop mishka_cms && docker rm mishka_cms
                        rm --recursive --force ../../Mnesia.nonode@nohost
                        echo -e "${Green} Clean up is Done, Before start again you must run ./mishka.sh start !${NC}" 
                    ;;

                    "--deps")
                        docker stop mishka_cms && docker rm mishka_cms
                        rm --recursive --force ../../deps
                        echo -e "${Green} Clean up is Done, Before start again you must run ./mishka.sh start !${NC}" 
                    ;;

                    "--compiled")
                        docker stop mishka_cms && docker rm mishka_cms
                        rm --recursive --force ../../_build
                        echo -e "${Green} Clean up is Done, Before start again you must run ./mishka.sh start !${NC}" 
                    ;;

                    "--all")
                        docker stop mishka_cms && docker rm mishka_cms
                        rm --recursive --force ../../Mnesia.nonode@nohost ../../deps ../../_build ../../mix.lock
                        echo -e "${Green} Clean up is Done, Before start again you must run ./mishka.sh start !${NC}" 
                    ;;

                    *)
                        echo -e "${Green}you have four option to use:${NC}" 
                        echo -e "${Green}   --diskdb${NC}" 
                        echo -e "${Green}   --deps${NC}" 
                        echo -e "${Green}   --compiled${NC}" 
                        echo -e "${Green}   --all${NC}" 
                    ;;
                esac
            ;;

            "login")
                CONTAINER_NAME=`docker ps --filter name=mishka_cms --format "{{.Names}}"`
                if [[ $CONTAINER_NAME != "" ]]; then 
                    docker exec -it $CONTAINER_NAME ash
                else 
                    echo -e "${Red} Mishka CMS not running !${NC}" 
                fi
            ;;

            "db")
                case $2 in
                        "--install")
                            db_manager
                        ;;

                        "--run")
                            if netstat -nultp | egrep -w '5432' > /dev/null; then
                                if dbeaver_checker; then 
                                   dbeaver
                                else 
                                    echo -e "${Red}DBeaver is Not Installed Please Install it with './mishka.sh db --install' ${NC}" 
                                fi
                            else 
                                echo -e "${Red}Your Database is Not Running, Please Using './mishka.sh start' ${NC}" 
                            fi 
                        ;;

                        *)
                            echo -e "${Green}you have two option to use:${NC}" 
                            echo -e "${Green}   --install${NC}" 
                            echo -e "${Green}   --run${NC}"
                        ;;
                esac
            ;;

            "help")
                echo -e "${Green}Below Options is Available:
                    start          all containers
                    stop           stop one or all containers
                    remove         stop and remove all containers plus network
                    destroy        stop and remove all containers plus netwok also remove docker images, volume
                    logs           show log of specific container of all containers
                    clean          Clean up dev enviroment
                      --diskdb     Clean disk database like Erlang runtime db (mnesia)
                      --deps       Clean dependency
                      --compiled   Clean old compiled files
                      --all        Clean disk database, dependency, mix.lock file and old compiled files
                    login          log into mishka_CMS container
                    db             graphical database manager with dbeaver
                      --install    install DBeaver Package
                      --run        run DBeaver${NC}"
            ;;

            *)
                echo -e "${Red}$2 Does not Exist !${NC}"
                echo -e "${Green} Using 'mishka.sh help' for more information"
            ;;

        esac
    fi
fi






