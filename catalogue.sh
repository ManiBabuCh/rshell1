#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=""

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE


VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2....$R FAILED $N"
    else
        echo -e "$2....$G Success $N"
    fi  
}

if [ $ID -ne 0]
then
    echo -e "$R ERROR :: Please run this script with root access $N"
    exit 1
else
    echo -e "$G you are the root user $N"
fi


dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabled nodejs default package"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabled nodejs default package"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "install nodejs req package"

useradd roboshop &>> $LOGFILE
VALIDATE $? "user creation"

mkdir /app &>> $LOGFILE
VALIDATE $? "directory creation"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $LOGFILE
VALIDATE $? "download catalogue package"

cd /app &>> $LOGFILE

unzip /tmp/catalogue.zip
VALIDATE $? "go to directory and unzip"

npm install &>> $LOGFILE
VALIDATE $? "npm install"

cp /home/centos/rshell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "copy"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "service reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "start "

cp /home/centos/rshell/mongo.repo  /etc/yum.repos.d/mongo.repo

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installing mongodb client"


mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "connect mongo db"