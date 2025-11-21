#!/bin/bash

param=$1
MYSQL="/usr/local/mysql/bin/mysql"

echo -n "MySQL password: "
read -s MYSQL_PW
echo

gnuplot <<EOF
set terminal png size 1280,720
set output "plots/${param}.png"
set title "Gold Price – ${param}"
set xlabel "Timestamp"
set ylabel "${param}"
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%m-%d\n%H:%M"

plot "< ${MYSQL} -u root -p${MYSQL_PW} -D gold_tracker -N -e 'SELECT timestamp, ${param} FROM gold_prices'" using 1:2 with linespoints title "${param}"
EOF