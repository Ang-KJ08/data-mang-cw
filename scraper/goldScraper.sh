#!/bin/bash
source ./scraper/utils.sh
OUTPUT="raw_gold.html"

echo "[INFO] Fetching gold price HTML..."
curl -s https://goldprice.org/gold-price-chart.html -o "$OUTPUT"

if [ ! -s "$OUTPUT" ]; then
    echo "[ERROR: ] Empty output. Possible website protection or connection issue."
    exit 1
fi

echo "[INFO: ] Parsing HTML..."
parsed=$(awk -f ./scraper/goldParser.awk "$OUTPUT")

echo "[INFO: ] Parsed Data: $parsed"

IFS=',' read -r spot change perf30 perf1y <<< "$parsed"

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
sql="INSERT INTO gold_prices (gold_spot, change_rate, performance_30d, performance_1y, timestamp) VALUES ('$spot', '$change', '$perf30', '$perf1y', '$timestamp');"

echo "[INFO] Inserting into MySQL..."
mysql_exec "$sql"

echo "[SUCCESS: ] Data inserted at $timestamp"