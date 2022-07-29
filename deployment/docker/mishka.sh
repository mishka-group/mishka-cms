#!/bin/bash
# set  -e -x

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

    # show mishka logo
    mishka_logo

    echo -e "${Green}Enter your environment type or number( 1) prod // 2) dev ):${NC}"
    options=(prod dev)
    select menu in "${options[@]}"; do 
        ENV_TYPE=$REPLY
        break;
    done

    ENV_TYPE_VAR=$(to_lower_case $ENV_TYPE)
    if [[ $ENV_TYPE_VAR =~ ^prod$ ]] || [[ "$menu" == "1" ]]; then # convert user input to lowercase then check it
        cp dockers/Dockerfile ../../

        if web_server_selector -eq "0"; then # nginx
            WEB_SERVER="nginx"
            while true; do 
                read -p $'\e[32mEnter Your CMS address (Domain or IP)  [default is \'localhost\']\e[0m: ' CMS_DOMAIN_NAME
                if domain_checker $CMS_DOMAIN_NAME; then
                    read -p $'\e[32mEnter Your API address \e[0m: ' API_DOMAIN_NAME
                    if domain_checker $API_DOMAIN_NAME && [[ ! $CMS_DOMAIN_NAME =~ $API_DOMAIN_NAME ]]; then 
                        break                        
                    else
                        echo -e "${Red}The api address must be different from the address for the CMS and must be a domain or sub-domain !${NC}"                         
                    fi
                else 
                    echo -e "${Red}The address of the CMS must not be an IP address!${NC}"
                fi 
            done 

            read -p $'\e[32mDo You Want to Enable SSL ? (YES/NO)  [default is YES]\e[0m: ' SSL
            SSL=${SSL:-"YES"}
            SSL_VAR=$(to_lower_case $SSL)
            if [[ $SSL_VAR =~ ^yes$ ]]; then 
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
        else 
            WEB_SERVER="cowboy" 
        fi 
        
        # get data from user
        read -p $'\e[32mEnter Your Database User [default is \'mishka_user\']\e[0m: ' DATABASE_USER
        read -p $'\e[32mEnter Your Database Password [default is \'mishka_password\']\e[0m: ' DATABASE_PASSWORD

        read -p $'\e[32mEnter Your Database Name [default is \'mishka_database\']\e[0m: ' DATABASE_NAME
        read -p $'\e[32mEnter Your Postgres User [default is \'postgres\']\e[0m: ' POSTGRES_USER
        read -p $'\e[32mEnter Your Postgres Password [default is \'postgres\']\e[0m: ' POSTGRES_PASSWORD
        
        echo -e "${Red}Please enable the email system for some verification, also, you will need the email server configuration!${NC}"
        read -p $'\e[32mDo You Want Enable Email System (YES/NO)[default is \'YES\']\e[0m: ' EMAIL_CONFIG
        EMAIL_CONFIG=${EMAIL_CONFIG:-"YES"}
        EMAIL_CONFIG_VAR=$(to_lower_case $EMAIL_CONFIG)
        if [[ "$EMAIL_CONFIG_VAR" =~ ^yes$ ]]; then 
            email_system
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
            --build-arg WEB_SERVER=$WEB_SERVER \
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
            purge
        fi
    else # dev
        pre_script # cleanup existing containers, network, volumes
        trap purge INT # trap control + c and run cleanup
        ENV_TYPE="dev"
        
        if web_server_selector -eq "0"; then # nginx
            WEB_SERVER="nginx"
            read -p $'\e[32mDo You Want to Enable SSL ? (YES/NO)  [default is YES]\e[0m: ' SSL
            SSL=${SSL:-"YES"}
            SSL_VAR=$(to_lower_case $SSL)
            if [[ $SSL_VAR =~ ^yes$ ]]; then 
                ssl_generator
                CMS_PORT="443"
                API_PORT="443" 
                PROTOCOL="https"
            else 
                CMS_PORT="80"
                API_PORT="80" 
                PROTOCOL="http"
            fi  

            CMS_DOMAIN_NAME="cms.example.com"       
            API_DOMAIN_NAME="api.example.com" 

                 
        else 
            WEB_SERVER="cowboy"
        fi 
        

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

        if [[ $(echo $?) != 0 ]]; then # run when docker got error
            echo -e "${Red}We got error during install. please check logs. cleanup process is running now...${NC}" 
            purge
            exit 1
        fi

        # print information
        print_build_output
        echo  -e "\033[33;5mPlease note the above information, you have 1 minute, after that you can see this information with sudo ./mishka.sh and after that type 'info'\033[0m"
        sleep 60s
        # create tables and compile files
        dev_operations
        
    fi 
else 
    load_configs
    ENV_TYPE_VAR=$(to_lower_case $ENV_TYPE)
    if [[ $ENV_TYPE_VAR =~ ^prod$ ]]; then  #production env  
        mishka_logo
        echo -e "${Green}Below Options is Available for Prod (enter the name for each section or number):
                       1) update    update images with old token
                       2) start     run all containers
                       3) stop      stop one or all containers
                       4) remove    stop and remove all containers plus network
                       5) destroy   stop and remove all containers plus netwok also remove docker images, volume
                       6) email     enable email system for cms
                       7) logs      show log of specific container of all containers
                       8) help      show help for mishka.sh${NC}"
        options=(update start stop remove destroy email logs help) 
        
        select menu in "${options[@]}"; do 
            break;
        done

        if [[ "$menu" == "" ]]; then
            INPUT_CASE=$REPLY
        else
            INPUT_CASE=$menu
        fi

        case $INPUT_CASE in 
            "update" | "1")
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
                        --build-arg WEB_SERVER=$WEB_SERVER \
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

            "start" | "2")
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

                ENV_TYPE_VAR=$(to_lower_case $ENV_TYPE)
                if [[ ! $ENV_TYPE_VAR =~ ^prod$ ]]; then 
                    echo -e "${Red}you must login into mishka_cms container then start server !${NC}"
                fi
            ;;

            "stop" | "3")
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

            "remove" | "4")
                docker-compose -f dockers/docker-compose.yml  -p mishka_cms down
            ;;

            "destroy" | "5")
                read -p $'\e[31mthis stage PERMANENTLY DELETE Mishka_CMS, ARE YOUR SURE ? (YES/NO)\e[0m: ' INPUT
                INPUT_VAR=$(to_lower_case $INPUT)
                if [[ $INPUT_VAR =~ ^yes$ ]]; then 
                    purge
                else 
                    echo -e "${Red} Your Operation is canceled..${NC}" 
                fi
            ;;

            "email" | "6")
                # load configs
                load_configs
                EMAIL_CONFIG_VAR=$(to_lower_case $EMAIL_CONFIG)
                if [[ "$EMAIL_CONFIG_VAR" =~ ^yes$ ]]; then 
                    read -p $'\e[32mDo You Want OVERWRITE Email System Config ? (YES/NO)\'\']\e[0m: ' EMAIL_CONFIG
                    if [[ "$EMAIL_CONFIG_VAR" =~ ^yes$ ]]; then 
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

            "logs" | "7")
                if [[ $2 != "" ]]; then 
                    docker logs -f $2
                else 
                    docker-compose -f dockers/docker-compose.yml  -p mishka_cms logs -f 
                fi
            ;;

            "help" | "8")
                echo -e "${Green}Below Options is Available (enter the name for each section):
                   1) update    update images with old token
                   2) start     run all containers
                   3) stop      stop one or all containers
                   4) remove    stop and remove all containers plus network
                   5) destroy   stop and remove all containers plus netwok also remove docker images, volume
                   6) email     enable email system for cms
                   7) logs      show log of specific container of all containers
                   8) help      show help for mishka.sh${NC}"
            ;;

            *)
                echo -e "${Red}$2 Does not Exist !${NC}"
                echo -e "${Green} Using 'mishka.sh help' for more information"
            ;;

        esac
    else  # dev stage
        mishka_logo
        echo -e "${Green}Below Options is Available for Dev (enter the name for each section or number):
                   1) start          all containers
                   2) stop           stop one or all containers
                   3) remove         stop and remove all containers plus network
                   4) run            start phoenix server with elixir console
                   5) rebuild        remove all old files (db, dependency, compile files,..) and recreate then recompile finally start server
                   6) destroy        stop and remove all containers plus netwok also remove docker images, volume
                   7) logs           show log of specific container of all containers
                   8) clean          Clean up dev enviroment
                   9) login          log into mishka_CMS container
                   10) db             graphical database manager with dbeaver
                   11) info           shows information about cms addresses and secrets${NC}"
        options=(start stop remove run rebuild destroy logs clean login db info) 

        select menu in "${options[@]}"; do 
            break;
        done 

        if [[ "$menu" == "" ]]; then
            INPUT_CASE=$REPLY
        else
            INPUT_CASE=$menu
        fi

        case $INPUT_CASE in 
            "start" | "1")
                if [ -f $PWD/etc/.secret ]; then 
                    docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d 

                    # load configs
                    load_configs


                    if domain_checker $CMS_DOMAIN_NAME && domain_checker $API_DOMAIN_NAME && [[ "$SSL" =~ ^yes$ ]]; then 
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

            "stop" | "2")
                if [[ $2 != "" ]]; then 
                    docker stop $2 && docker rm $2
                else 
                    echo -e "${Red}please specific container name for stop$PWD ${NC}"
                fi
            ;;

            "remove" | "3")
                docker-compose -f dockers/docker-compose.yml  -p mishka_cms down
            ;;

            "run" | "4")
                docker exec -it mishka_cms sh -c "iex -S mix phx.server"
            ;;
            
            "rebuild" | "5")
                # Stop Services and Delete Networks
                docker-compose -f dockers/docker-compose.yml  -p mishka_cms down

                # Clean disk database, dependency, mix.lock file and old compiled files
                cleanup all

                # Start Services and Delete Networks
                docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d

                # compile and start server
                dev_operations
            ;;

            "destroy" | "6")
                read -p $'\e[31mthis stage PERMANENTLY DELETE Mishka_CMS, ARE YOUR SURE ? (YES/NO)\e[0m: ' INPUT
                INPUT_VAR=$(to_lower_case $INPUT)
                if [[ $INPUT_VAR =~ ^yes$ ]]; then 
                    purge
                else 
                    echo -e "${Red} Your Operation is canceled..${NC}" 
                fi
            ;;


            "logs" | "7")
                if [[ $2 != "" ]]; then 
                    docker logs -f $2
                else 
                    docker-compose -f dockers/docker-compose.yml  -p mishka_cms logs -f 
                fi
            ;;

            "clean" | "8")
                mishka_logo
                echo -e "${Green}Below Options is Available for clean (enter the name for each section or number):
                               1) extensions clean extensions
                               2) deps       Clean dependency
                               3) compiled   Clean old compiled files
                               4) all        Clean disk database, dependency, mix.lock file and old compiled files${NC}"
                options=(extensions deps compiled all) 

                select menu in "${options[@]}"; do 
                    break;
                done 

                if [[ "$menu" == "" ]]; then
                    INPUT_CASE=$REPLY
                else
                    INPUT_CASE=$menu
                fi

                case $INPUT_CASE in
                    "extensions" | "1")
                        docker stop mishka_cms && docker rm mishka_cms
                        rm -rf ../extensions
                        echo -e "${Green} Clean up is Done, Before start again you must run ./mishka.sh${NC}" 
                    ;;

                    "deps" | "2")
                        docker stop mishka_cms && docker rm mishka_cms
                        rm -rf ../../deps
                        echo -e "${Green} Clean up is Done, Before start again you must run ./mishka.sh${NC}" 
                    ;;

                    "compiled" | "3")
                        docker stop mishka_cms && docker rm mishka_cms
                        rm -rf ../../_build
                        echo -e "${Green} Clean up is Done, Before start again you must run ./mishka.sh${NC}" 
                    ;;

                    "all" | "4")
                        docker stop mishka_cms && docker rm mishka_cms
                          rm -rf ../extensions ../../deps ../../_build ../../mix.lock
                        echo -e "${Green} Clean up is Done, Before start again you must run ./mishka.sh${NC}" 
                    ;;

                    *)
                        echo -e "${Green}you have four option to use:${NC}"  
                        echo -e "${Green}  1) extensions${NC}" 
                        echo -e "${Green}  2) deps${NC}" 
                        echo -e "${Green}  3) compiled${NC}" 
                        echo -e "${Green}  4) all${NC}" 
                    ;;
                esac
            ;;

            "login" | "9")
                CONTAINER_NAME=`docker ps --filter name=mishka_cms --format "{{.Names}}"`
                if [[ $CONTAINER_NAME != "" ]]; then 
                    docker exec -it $CONTAINER_NAME /bin/sh -l
                else 
                    echo -e "${Red} Mishka CMS not running !${NC}" 
                fi
            ;;

            "db" | "10")
                mishka_logo
                echo -e "${Green}Below Options is Available for DB (enter the name for each section or number):
                                install    install DBeaver Package
                                run        run DBeaver${NC}"
                options=(install run) 
                
                select menu in "${options[@]}"; do 
                    break;
                done 

                if [[ "$menu" == "" ]]; then
                    INPUT_CASE=$REPLY
                else
                    INPUT_CASE=$menu
                fi

                case $INPUT_CASE in
                        "install" | "1")
                            db_manager
                        ;;

                        "run" | "2")
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
                            echo -e "${Green}   install${NC}" 
                            echo -e "${Green}   run${NC}"
                        ;;
                esac
            ;;

            "info" | "11")
                load_configs
                print_build_output
            ;;

            *)
            
                echo -e "${Red}$2 Does not Exist !${NC}"
                echo -e "${Green} Using 'mishka.sh help' for more information"
            ;;

        esac
    fi
fi






