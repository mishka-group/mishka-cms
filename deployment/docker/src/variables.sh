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