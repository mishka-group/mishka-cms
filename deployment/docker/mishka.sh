#!/bin/bash
# set -e -x

# color variables
source src/variables.sh 

# variables for build
source src/functions.sh 



#=============================================================

# check requirments before run shell
check_requirements






case $1 in 
    "--build")
        if [ ! -f $PWD/etc/.secret ]; then 
            if [ -d .git ];then 
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
                    ../../ --no-cache
                
                if [[ $? == 0 ]]; then # if docker image was build
                    # update docker-compose file with values
                    update_config

                    # start containers 
                    docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d 

                    # remove double qoutaion
                    CMS_DOMAIN_NAME=${CMS_DOMAIN_NAME//[ #\"-%\"]}
                    API_DOMAIN_NAME=${API_DOMAIN_NAME//[ #\"-%\"]}
                    CMS_PORT=${CMS_PORT//[ #\"-%\"]}
                    API_PORT=${API_PORT//[ #\"-%\"]}

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
            echo -e "${Red}your previously build exist, Operation cenceled, Please use 'mishka.sh --update' for update you app${NC}"
            exit 1
        fi    

    ;;

    "--update")
        if [ -d .git ];then 
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
                ../../ --no-cache
            
            # update docker-compose file with values
            update_config

            echo -e "${Green}Your App updated Successfully${NC}"

            # recreate containers
            docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d 
            rm ../../Dockerfile
        else 
            echo -e "${Red}secret file does not exist in $PWD/ ${Green} Please use 'mishka.sh --build' for fresh install ${NC}"
        fi
    ;;

    "--start")
        if [ -f $PWD/etc/.secret ]; then 
            docker-compose -f dockers/docker-compose.yml  -p mishka_cms up -d 

            # load configs
            load_configs

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
            echo -e "${Red}secret file does not exist in $PWD/etc ${Green} Please use 'mishka.sh --build' for install ${NC}"
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
        docker-compose -f dockers/docker-compose.yml  -p mishka_cms down
    ;;

    "--destroy")
        read -p $'\e[31mthis stage PERMANENTLY DELETE Mishka_CMS, ARE YOUR SURE ? (Y/N)\e[0m: ' INPUT
        if [[ ${INPUT,,} =~ ^y$ ]]; then 
            cleanup
        else 
            echo -e "${Red} Your Operation is canceled..${NC}" 
        fi
    ;;


    "--logs")
        if [[ $2 != "" ]]; then 
            docker logs -f $2
        else 
            docker-compose -f dockers/docker-compose.yml  -p mishka_cms logs -f 
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
            --logs      show log of specific container of all containers${NC}"
    ;;

    *)
        echo -e "${Red}$2 Does not Exist !${NC}"
        echo -e "${Green} Using 'mishka.sh --help' for more information"
    ;;

esac


