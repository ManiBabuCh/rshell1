#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "mongodb repo copied"