#!/bin/bash

source ./scraper/utils.sh
OUTPUT="raw_gold.html"

echo_info "Fetching gold price HTML..."
curl -s https://goldprice.org/gold-price-chart.html -o "$OUTPUT"

if [ ! -s "$OUTPUT" ]; then
echo_error "Empty HTML. Exiting."
exit 1
fi

echo_info "Parsing HTML with AWK..."
parsed=$(awk -f ./scraper/goldParser.awk "$OUTPUT")
IFS=',' read -r GOLD_SPOT GOLD_CHANGE GOLD_30D GOLD_1Y <<< "$parsed"

timestamp=$(date +"%Y-%m-%d %H:%M:%S")

to_null() { [ -z "$1" ] && echo NULL || echo "$1"; }
GOLD_SPOT=$(to_null "$GOLD_SPOT")
GOLD_CHANGE=$(to_null "$GOLD_CHANGE")
GOLD_30D=$(to_null "$GOLD_30D")
GOLD_1Y=$(to_null "$GOLD_1Y")

sql="INSERT INTO gold_prices (gold_spot, change_rate, performance_30d, performance_1y, timestamp) VALUES ($GOLD_SPOT, $GOLD_CHANGE, $GOLD_30D, $GOLD_1Y, '$timestamp');"

echo_info "Inserting into MySQL..."
mysql_exec "$sql"
echo_success "Gold scraper complete at $timestamp"