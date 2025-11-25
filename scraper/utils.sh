#!/bin/bash

mysql_exec() {
    CMD=$1
    /usr/local/mysql/bin/mysql -u root -p -e "USE gold_tracker; $CMD"
}