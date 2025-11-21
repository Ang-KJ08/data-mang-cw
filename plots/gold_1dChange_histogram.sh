#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root}"
DB_NAME="${DB_NAME:-goldtracker}"
TMPCSV="/tmp/gold_data.csv"
OUTDIR="./plots"
OUTFILE="$OUTDIR/gold_1dChange_histogram.png"
mkdir -p "$OUTDIR"

$MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; SELECT gold_percent FROM gold_data WHERE gold-percent IS NOT NULL;" > "$TMPCSV"
tail -n +2 "$TMPCSV" > /tmp/goldPctVals.dat

gnuplot <<-GP
    set terminal png size 1000,720
    set output "$OUTFILE"
    set title "Histogram of Gold Percent Change"
    set xlabel "Percentage Change"
    set ylabel "Count"
    binwidth=0.1
    bin(x,width)=width*floor(x/width)
    plot "/tmp/goldPctVals.dat" using (bin(\$1, binwidth)):(1) smooth freq with boxes notitle
GP

echo "Wrote $OUTFILE"