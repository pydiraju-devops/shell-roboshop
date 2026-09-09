#!/bin/bash

USER_ID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then
    echo -e "$R Run this script with root user $N" | tee -a "$LOGS_FILE"
    exit 1
fi

mkdir -p "$LOGS_FOLDER"

VALIDATE() {

    if [ $1 -ne 0 ]; then
        echo -e "$2 is $R failure $N" | tee -a "$LOGS_FILE"
        exit 1
    else
        echo -e "$2 is $G success $N" | tee -a "$LOGS_FILE"
    fi
}

dnf module disable redis -y &>> $LOGS_FILE
dnf module enable redis:7 -y
VALIDATE $? "disable and enable redis"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e  '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "editing"



systemctl enable redis  &>> $LOGS_FILE
systemctl start redis 
VALIDATE $? "enable and start"