#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root}"
DB_NAME="${DB_NAME:-goldtracker}"
TMPCSV="/tmp/gold_data.csv"
OUTDIR="./plots"
OUTFILE="$OUTDIR/goldSpread.png"
mkdir -p "$OUTDIR"

$MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; SELECT created_at, gold_price, silver_price FROM gold_data ORDER BY created_at;" > "$TMPCSV"
tail -n +2 "$TMPCSV" | awk -F'\t' '{ if($2!="" && $3!="") print $1 "\t" ($2-$3); }' > /tmp/goldSpread.dat

gnuplot <<-GP
    set terminal png size 1200,700
    set output "$OUTFILE"
    set xdata time
    set timefmt "%Y-%m-%d %H:%M:%S"
    set format x "%m/%d\n%H:%M"
    set title "Gold-Silver Spread vs Time"
    set xlabel "Time"
    set ylabel "Spread (USD)"
    set grid
    plot "/tmp/goldSpread.dat" using 1:2 with lines title "Spread"
GP

echo "Wrote $OUTFILE"