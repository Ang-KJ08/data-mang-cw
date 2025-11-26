#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root -p}"
DB_NAME="${DB_NAME:-gold_tracker}"

mysql_exec(){
    local sql="$1"
    $MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; ${sql};"
}

echo_info(){ echo -e "[INFO] $1"; }
echo_success(){ echo -e "[SUCCESS] $1"; }
echo_error(){ echo -e "[ERROR] $1"; }