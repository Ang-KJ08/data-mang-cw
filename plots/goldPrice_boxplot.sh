#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root}"
DB_NAME="${DB_NAME:-goldtracker}"
TMPCSV="/tmp/gold_data.csv"
OUTDIR="./plots"
OUTFILE="$OUTDIR/goldPrice_boxplot.png"
mkdir -p "$OUTDIR"

$MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; SELECT gold_price FROM gold_data WHERE gold-price IS NOT NULL;" > "$TMPCSV"
tail -n +2 "$TMPCSV" > /tmp/goldPriceVals.dat

gnuplot <<-GP
    set terminal png size 800,800
    set output "$OUTFILE"
    set title "Boxplot of Gold Prices"
    set ylabel "Gold Price (USD)"
    set style boxplot outliers pointtype 7
    set style data boxplot
    plot "/tmp/gold_vs_time.dat" using (1):1 notitle
GP

echo "Wrote $OUTFILE"