#!/bin/bash

mysql_exec(){
    CMD=$1
    /opt/lampp/bin/mysql -u root -e "$CMD"
}