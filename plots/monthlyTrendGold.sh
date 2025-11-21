#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root}"
DB_NAME="${DB_NAME:-goldtracker}"=
OUTDIR="./plots"
OUTFILE="$OUTDIR/monthlyTrendGold.png"
mkdir -p "$OUTDIR"

$MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; SELECT DATE_FORMAT(created_at, '%Y-%m') AS ym, ROUND(AVG(gold_price), 4) AS avg_price FROM gold_data GROUP BY ym ORDER BY ym;" > /tmp/monthlyTrendGold.csv
tail -n +2 /tmp/monthlyTrendGold.csv > /tmp/monthlyTrendGold.dat

gnuplot <<-GP
    set terminal png size 1200,700
    set output "$OUTFILE"
    set title "Monthly Average Gold Price"
    set xlabel "Month"
    set xtics rotate by -45
    set ylabel "Average Gold Price (USD)"
    set grid
    plot "/tmp/monthlyTrendGold.dat" using 1:2 with linespoints title "Monthly Average"
GP

echo "Wrote $OUTFILE"