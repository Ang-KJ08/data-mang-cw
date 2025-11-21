#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS:--u root}"
DB_NAME="${DB_NAME:-goldtracker}"
TMPCSV="/tmp/gold_data.csv"
OUTDIR="./plots"
OUTFILE="$OUTDIR/goldRollAvg.png"
mkdir -p "$OUTDIR"

$MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; SELECT created_at, gold_price FROM gold_data ORDER BY created_at;" > "$TMPCSV"
tail -n +2 "$TMPCSV" > /tmp/goldPricesTime.dat

awk -F '\t' '{
    t[NR]=$1; v[NR]=$2;
}
END {
    for (i=1;i<=NR;i++){
        s=0; cnt=0;
        start=(i-6>1?i-6:1)
        for(j=start;j<=i;j++){ s+=v[j]; cnt++ }
        printf "%s\t%.6f\n", t[i], s/cnt
    }
}' /tmp/goldPricesTime.dat > /tmp/goldRollAvg.dat

gnuplot <<-GP
    set terminal png size 1200,720
    set output "$OUTFILE"
    set xdata time
    set timefmt "%Y-%m-%d %H:%M:%S"
    set format x "%m/%d\n%H:%M"
    set title "Gold Rolling Average"
    set xlabel "Time"
    set ylabel "Gold Price (USD)"
    set grid
    plot "/tmp/goldRollAvg.dat" using 1:2 with lines title Gold Rolling Average"
GP

echo "Wrote $OUTFILE"