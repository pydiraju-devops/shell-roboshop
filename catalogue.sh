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

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "enable nodejs 20"

dnf install nodejs -y &>> $$LOGS_FILE
VALIDATE $? "installing nodejs"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "user added"
else
    echo -e "user already exist ...$Y skipping $N"    

fi    

mkdir -p /app 
VALIDATE $? "created directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
VALIDATE $? "unzipping code"

cd /app 
VALIDATE $? "path change to /app"

unzip /tmp/catalogue.zip &>> $LOGS_FILE
VALIDATE $? "unzipping code"

npm install 
VALIDATE $? "npm installation"

cp catalogue service.sh   /etc/systemd/system/catalogue.service
VALIDATE $? "service created"

systemctl daemon-reload
VALIDATE $? "reload"

systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "enabling and start"