#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root}"
DB_NAME="${DB_NAME:-goldtracker}"
TMPCSV="/tmp/gold_data.csv"
OUTDIR="./plots"
OUTFILE="$OUTDIR/goldPct_vs_time.png"
mkdir -p "$OUTDIR"

$MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; SELECT created_at, gold_percent FROM gold_data ORDER BY created_at;" > "$TMPCSV"
tail -n +2 "$TMPCSV" > /tmp/goldPct_vs_time.dat

gnuplot <<-GP
    set terminal png size 1200,720
    set output "$OUTFILE"
    set xdata time
    set timefmt "%Y-%m-%d %H:%M:%S"
    set format x "%m/%d\n%H:%M"
    set title "Gold Percent Change vs Time"
    set xlabel "Time"
    set ylabel "Percent Change (%)"
    set grid
    plot "/tmp/goldPct_vs_time.dat" using 1:2 with lines title "Gold % Change"
GP

echo "Wrote $OUTFILE"