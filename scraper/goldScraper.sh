#!/bin/bash
source./scraper/utils.sh

echo "Fetching gold price HTML......"
curl -s https://goldprice.org/gold-price-chart.html -o $OUTPUT

if [ ! -s "$OUTPUT" ]; then
    echo "Empty output. Possible website protection or connection issue."
fi

echo "Parsing HTML......"
parsed=$(awk -f ./scraper/goldParser.awk $OUTPUT)

echo "Parsed Data; $parsed"
IFS=',' read -r gold spot change day30 year <<< "$parsed"

timestamp=$(date + %Y=%m=%d %H: %M:%S)

sql="INSERT INTO goldprices (gold_spot, change_rate, performance_30d, performance_1y, timestamp) VALUES ('$spot', '$change', '$day30', '$year', '$timestamp');"

echo "Inserting into MySQL......"
mysql_exec "$sql"
echo "Data inserted at $timestamp"