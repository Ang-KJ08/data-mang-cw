#!/bin/bash

source ./scraper/utils.sh
OUTPUT="raw_gold.html"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

to_null(){ [ -z "$1" ] && echo NULL || echo "$1"; }

echo "[INFO] Fetching HTML..."
curl -s https://goldprice.org/gold-price-chart.html -o "$OUTPUT"

if [ ! -s "$OUTPUT" ]; then
    echo "[ERROR] Empty HTML. Exiting."
    exit 1
fi

echo "[INFO] Parsing HTML for gold..."
JSON_LINE=$(grep -o 'var USDXAU = {[^;]*}' "$OUTPUT")

GOLD_SPOT=$(echo "$JSON_LINE" | awk -F'"xauPrice":' '{print $2}' | awk -F',' '{print $1}')
GOLD_CHANGE=$(echo "$JSON_LINE" | awk -F'"chgPct":' '{print $2}' | awk -F',' '{print $1}')
GOLD_30D=$(echo "$JSON_LINE" | awk -F'"xau30d":' '{print $2}' | awk -F',' '{print $1}')
GOLD_1Y=$(echo "$JSON_LINE" | awk -F'"xau365d":' '{print $2}' | awk -F',' '{print $1}')

GOLD_SPOT=$(to_null "$GOLD_SPOT")
GOLD_CHANGE=$(to_null "$GOLD_CHANGE")
GOLD_30D=$(to_null "$GOLD_30D")
GOLD_1Y=$(to_null "$GOLD_1Y")

sql_gold="INSERT INTO gold_prices (gold_spot, change_rate, performance_30d, performance_1y, timestamp) 
VALUES ($GOLD_SPOT, $GOLD_CHANGE, $GOLD_30D, $GOLD_1Y, '$timestamp');"

echo "[INFO] Inserting into MySQL..."
mysql_exec "$sql_gold"
echo "[SUCCESS] Done."

echo "[INFO] Parsing HTML for silver..."

JSON_LINE_SILVER=$(grep -o 'var USDSIL = {[^;]*}' "$OUTPUT")

SILVER_SPOT=$(echo "$JSON_LINE_SILVER" | awk -F'"xagPrice":' '{print $2}' | awk -F',' '{print $1}')
SILVER_CHANGE=$(echo "$JSON_LINE_SILVER" | awk -F'"chgPct":' '{print $2}' | awk -F',' '{print $1}')
SILVER_30D=$(echo "$JSON_LINE_SILVER" | awk -F'"xag30d":' '{print $2}' | awk -F',' '{print $1}')
SILVER_1Y=$(echo "$JSON_LINE_SILVER" | awk -F'"xag365d":' '{print $2}' | awk -F',' '{print $1}')

SILVER_SPOT=$(to_null "$SILVER_SPOT")
SILVER_CHANGE=$(to_null "$SILVER_CHANGE")
SILVER_30D=$(to_null "$SILVER_30D")
SILVER_1Y=$(to_null "$SILVER_1Y")

sql_silver="INSERT INTO silver_prices (silver_spot, change_rate, performance_30d, performance_1y, timestamp) 
VALUES ($SILVER_SPOT, $SILVER_CHANGE, $SILVER_30D, $SILVER_1Y, '$timestamp');"

echo "[INFO] Inserting into MySQL..."
mysql_exec "$sql_silver"
echo "[SUCCESS] Done."

echo "[SUCCESS] Gold and silver scraper completed."