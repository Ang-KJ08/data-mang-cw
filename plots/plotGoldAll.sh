#!/bin/bash
param=$1

mkdir -p ./plots
TMPDATA="/tmp/${param}_data.dat"
/usr/local/mysql/bin/mysql -u root -p -B -e "USE gold_tracker; SELECT timestamp, ${param} FROM gold_prices;" | tail -n +2 > "$TMPDATA"

gnuplot <<EOF
set terminal png size 1280,720
set output "./plots/${param}.png"
set title "Gold Price — ${param}"
set xlabel "Timestamp"
set ylabel "${param}"
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%m-%d\n%H:%M"

plot "$TMPDATA" using 1:2 with linespoints title "${param}"
EOF

echo "[INFO] Plot created: ./plots/${param}.png"