#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.pydiraju.online

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nginx -y
dnf module enable nginx:1.24 -y
dnf install nginx -y
VALIDATE $? "installing and enabling"

systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "starting"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing default file"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "unzip"

cd /usr/share/nginx/html 
VALIDATE $? "change"

unzip /tmp/frontend.zip
VALIDATE $? "unzipping"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf  /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Created systemctl service"

systemctl restart nginx 
VALIDATE $? "restarted"

