#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root}"
DB_NAME="${DB_NAME:-goldtracker}"=
OUTDIR="./plots"
OUTFILE="$OUTDIR/weeklyAvgGold.png"
mkdir -p "$OUTDIR"

$MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; SELECT CONCAT(YEAR(created_at)),'-',LPAD(WEEK(created_at, 1), 2, '0')) AS yw, ROUND(AVG(gold_price), 4) AS avg_price FROM gold_data GROUP BY  yw ORDER BY yw;" > /tmp.weeklyAvgGold.csv
tail -n +2 /tmp/weeklyAvgGold.csv > /tmp/weeklyAvgGold.dat

gnuplot <<-GP
    set terminal png size 1200,720
    set output "$OUTFILE"
    set title "Weekly Average Gold Price"
    set xlabel "Year-Week"
    set xtics rotate by -45
    set ylabel "Average Gold Price (USD)"
    set grid
    set boxwidth 0.6
    set style fill solid 0.5
    plot "/tmp/weeklyAvgGold.dat" using 1:2 with lines title "Weekly Average"
GP

echo "Wrote $OUTFILE"