#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/config/bin/
cd "$(dirname "$0")"

# EXIT CODES
# 42 "Found session"
# 30 "No session found yet..."
# 31 "No cinnamon-session found yet..."

#### FIND THE SESSION USER ####
SESSION_USER=$(ps -aux|grep "cinnamon-session"|grep -v "grep"|awk 'NR==1{print $1}'|sed 's/+//g')
if [ "$?" == 1 ];then
	exit 31
elif [ -z "$SESSION_USER" ];then
	exit 31
fi


#### CHECK PASSWD FOR VAILD SYSTEM USER
grep "$SESSION_USER" /etc/passwd| awk -F':' 'NR==1{print $1}'

#### SET EXIT CODE
if grep -q "$SESSION_USER" /etc/passwd| awk -F':' 'NR==1{print $1}';then
	exit 42
else
	exit 30
fi
