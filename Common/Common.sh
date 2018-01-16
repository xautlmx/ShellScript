#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    Common.sh
# Revision:    1.0
# Date:        2018/01/16
# Author:      jiegl
# Email:       jiegl1@lenovo.com
# Website:     https://jiedada.top
# Description: 公共函数
# Notes:       This plugin uses the "source Common.sh" command
# -------------------------------------------------------------------------------
function Status(){
	DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
    HOST_N="$1"
    PREFIX="$DATE_N $HOST_N"
    echo -n "$PREFIX Execute $2 "
    if [ $3 == true ]; then
        echo -e "\033[32m succeed. \033[0m"
    else
        echo -e "\033[41;37m failed. \033[0m"
    fi
}