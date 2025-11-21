#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root}"
DB_NAME="${DB_NAME:-goldtracker}"
TMPCSV="/tmp/gold_data.csv"
OUTDIR="./plots"
OUTFILE="$OUTDIR/gold_vs_silver.png"
mkdir -p "$OUTDIR"

$MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; SELECT created_at, gold_price, silver_price FROM gold_data ORDER BY created_at;" > "$TMPCSV"
tail -n +2 "$TMPCSV" | awk -F '\t' '{print $2 "\t" $3}' > /tmp/gold_vs_silver.dat

gnuplot <<-GP
    set terminal png size 1200,720
    set output "$OUTFILE"
    set title "Gold Price vs Silver Price"
    set xlabel "Gold Price (USD)"
    set ylabel "Silver Price (USD)"
    set grid
    plot "/tmp/gold_vs_silver.dat" using 1:2 with pointtype 7 pointsize 1 title "Data Points"
GP

echo "Wrote $OUTFILE"