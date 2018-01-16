#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    MutualTrust.sh
# Revision:    1.0
# Date:        2018/01/16
# Author:      jiegl
# Email:       jiegl1@lenovo.com
# Website:     https://jiedada.top
# Description: 建立主机互信
# Notes:       This plugin uses the "sh MutualTrust.sh" command
# -------------------------------------------------------------------------------

source ../Common/Common.sh

DestUser=$1  
PassWord=$2  
HostsFile=$3

if [ $# -ne 3 ]; then  
    echo "Error: please input sh $0 user password hostsFile"  
    exit 1
fi

function CreateSSH(){

    SSH_DIR=~/.ssh  
    SCRIPT_PREFIX=./tmp
    ip=`ip route get 1|head -n1|awk '{print $NF}'`

    #创建ssh目录
    if [ ! -d "$SSH_DIR" ];then
        mkdir $SSH_DIR
        chmod 700 $SSH_DIR  
    fi

    #生成创建ssh的秘钥和公钥的脚本 
    TMP_SCRIPT=$SCRIPT_PREFIX.sh  
    echo  "#!/usr/bin/expect">$TMP_SCRIPT  
    echo  "spawn ssh-keygen -b 2048 -t rsa">>$TMP_SCRIPT  
    echo  "expect *key*">>$TMP_SCRIPT  
    echo  "send \r">>$TMP_SCRIPT  
    if [ -f $SSH_DIR/id_rsa ]; then  
        echo  "expect *verwrite*">>$TMP_SCRIPT  
        echo  "send y\r">>$TMP_SCRIPT  
    fi  
    echo  "expect *passphrase*">>$TMP_SCRIPT  
    echo  "send \r">>$TMP_SCRIPT  
    echo  "expect *again:">>$TMP_SCRIPT  
    echo  "send \r">>$TMP_SCRIPT  
    echo  "interact">>$TMP_SCRIPT  
      
    chmod +x $TMP_SCRIPT  
    
    #执行上面脚本的命令,并将执行过程输出到Log目录下
    /usr/bin/expect $TMP_SCRIPT &>> ../Log/$0.log
    if [ $? -eq 0 ]; then
        Status $ip $0 true
    else
        Status $ip $0 false
    fi

    rm $TMP_SCRIPT  
    
    cat $SSH_DIR/id_rsa.pub>>$SSH_DIR/authorized_keys  

    chmod 600 $SSH_DIR/authorized_keys  

}

function RelationsBuilding(){
    #拷贝文件到其他主机
    for ip in $(cat $HostsFile)    
    do  
        if [ "x$ip" != "x" ]; then  
            TMP_SCRIPT=${SCRIPT_PREFIX}.$ip.sh  
            # 检查是否已知主机
            val=`ssh-keygen -F $ip`  
            if [ "x$val" == "x" ]; then  
                echo "$ip not in $SSH_DIR/known_hosts, need to add"  &>> ../Log/$0.log
                val=`ssh-keyscan $ip 2>/dev/null`  
                if [ "x$val" == "x" ]; then  
                    echo "ssh-keyscan $ip failed!"  &>> ../Log/$0.log
                else  
                    echo $val>>$SSH_DIR/known_hosts  
                fi  
            fi  
            echo "copy $SSH_DIR to $ip"  &>> ../Log/$0.log
            
            #生成拷贝文件到其他主机的脚本
            echo  "#!/usr/bin/expect">$TMP_SCRIPT  
            echo  "spawn scp -r  $SSH_DIR $DestUser@$ip:~/">>$TMP_SCRIPT  
            echo  "expect *assword*">>$TMP_SCRIPT  
            echo  "send $PassWord\r">>$TMP_SCRIPT  
            echo  "interact">>$TMP_SCRIPT  
              
            chmod +x $TMP_SCRIPT

            #执行上面脚本的命令,并将执行过程输出到Log目录下
            /usr/bin/expect $TMP_SCRIPT &>> ../Log/$0.log
            if [ $? -eq 0 ]; then
                Status $ip $0 true
            else
                Status $ip $0 false
            fi

            rm $TMP_SCRIPT               
        fi  
    done  
}

function Main(){

    CreateSSH

    RelationsBuilding

}

Main