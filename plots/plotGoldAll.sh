#!/bin/bash

param=$1

gnuplot <<EOF
set terminal png size 1280,720
set output "plots/${param}.png"
set title "Gold Price — ${param}"
set xlabel "Timestamp"
set ylabel "${param}"
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%m-%d\n%H:%M"

plot "< /opt/lampp/bin/mysql -u root -e 'SELECT timestamp, ${param} FROM gold_tracker.gold_prices'" using 1:2 with linespoints
EOF