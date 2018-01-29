# 简介

常用Shell脚本,每个目录为一个功能模块，环境为Linux操作系统，进入功能模块之后直接使用sh 运行文件即可。

# Common 目录

该目录下存放的是公共函数库

# Log 目录

该目录下存放的是，执行每个模块之后的输出日志存放目录

# MutualTrust 模块

互信脚本，通过Master主机执行脚本，生成公钥和私钥，传输到所有主机上，使所有主机都建立互相信任。

如果没有安装expect工具的话,需要yum install -y expect安装expect工具

执行命令 cd ShellScript/MutualTrust 进入MutualTrust目录

然后执行 sh MutualTrust.sh 用户名 密码 host.txt

注意：host.txt文件不能在windows新建,会编码不一样。直接使用里面的host.txt文件即可。host文件里面不用添加执行脚本的主机ip,脚本里面会自动添加了的。