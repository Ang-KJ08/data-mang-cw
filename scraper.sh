#!/bin/bash

source ./utils.sh
MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root -p}"
DB_NAME="${DB_NAME:-gold_tracker}"

timestamp=$(date +"%Y-%m-%d %H:%M:%S")

fetch_and_parse(){
    local metal="$1"
    local metal_upper
    metal_upper=$(echo "$metal" | tr '[:lower:]' '[:upper:]')   # fix for Bash <4
    local json_url="https://data-asg.goldprice.org/dbXRates/${metal}"
    local tmp_file="/tmp/${metal}.json"

    echo "[INFO] [${metal_upper}] Fetching JSON..."
    curl -s "$json_url" -o "$tmp_file"

    if [ ! -s "$tmp_file" ]; then
        echo "[ERROR] [${metal_upper}] Empty JSON. Exiting."
        return 1
    fi

    echo "[INFO] [${metal_upper}] Parsing JSON..."
    local price change pct_30d pct_1y
    price=$(awk -F'"' '/"price"/ {print $4}' "$tmp_file" | head -n1)
    change=$(awk -F'"' '/"chgPct"/ {print $4}' "$tmp_file" | head -n1)
    pct_30d=$(awk -F'"' '/"price30Days"/ {print $4}' "$tmp_file" | head -n1)
    pct_1y=$(awk -F'"' '/"price365Days"/ {print $4}' "$tmp_file" | head -n1)

    to_null() { [ -z "$1" ] && echo NULL || echo "$1"; }
    price=$(to_null "$price")
    change=$(to_null "$change")
    pct_30d=$(to_null "$pct_30d")
    pct_1y=$(to_null "$pct_1y")

    echo "[INFO] [${metal_upper}] Inserting into MySQL..."
    sql="INSERT INTO ${metal}_prices (price, change_rate, performance_30d, performance_1y, timestamp) VALUES ($price, $change, $pct_30d, $pct_1y, '$timestamp');"
    $MYSQL_CMD $MYSQL_FLAGS -e "USE $DB_NAME; $sql"

    echo "[SUCCESS] [${metal_upper}] Done."
}

fetch_and_parse "gold"
fetch_and_parse "silver"

echo "[SUCCESS] Gold and silver scraped completed."