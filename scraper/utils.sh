#!/bin/bash

mysql_exec(){
local CMD="$1"
/usr/local/mysql/bin/mysql -u root -p -e "USE gold_tracker; $CMD"
}

echo_info() { echo "[INFO] $1"; }
echo_success() { echo "[SUCCESS] $1"; }
echo_error() { echo "[ERROR] $1"; }