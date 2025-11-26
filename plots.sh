#!/bin/bash

MYSQL_CMD="${MYSQL_CMD:-mysql}"
MYSQL_FLAGS="${MYSQL_FLAGS="-u root -p"}"
DB_NAME="${DB_NAME:-gold_tracker}"

OUTDIR="./plots"
mkdir -p "$OUTDIR"

mysql_query(){
    local sql="$1"
    $MYSQL_CMD $MYSQL_FLAGS -B -e "USE ${DB_NAME}; ${sql};"
}

plot_gold_percent_hist(){
    mysql_query "
        SELECT ROUND((price - LAG(price) OVER (ORDER BY timestamp))/LAG(price) OVER (ORDER BY timestamp)*100,2) AS pct_change FROM gold_prices WHERE price IS NOT NULL;
    " > /tmp/goldPctVals_raw.csv

    tail -n +2 /tmp/goldPctVals_raw.csv > /tmp/goldPctVals.dat

    gnuplot <<-GP
        set terminal png size 1000,720
        set output "${OUTDIR}/gold_1dChange_histogram.png"
        set title "Histogram of Gold Percent Change"
        set xlabel "Percentage Change (%)"
        set ylabel "Count"
        binwidth=0.1
        bin(x,width)=width*floor(x/width)
        plot "/tmp/goldPctVals.dat" using (bin(\$1, binwidth)):(1) smooth freq with boxes notitle
GP

    echo "[OK] Wrote ${OUTDIR}/gold_1dChange_histogram.png"
}

plot_gold_rolling_avg(){
    mysql_query "SELECT timestamp, price FROM gold_prices ORDER BY timestamp;" > /tmp/goldPrices_raw.csv
    tail -n +2 /tmp/goldPrices_raw.csv > /tmp/goldPricesTime.dat

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
        set output "${OUTDIR}/goldRollAvg.png"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%m/%d\n%H:%M"
        set title "Gold Rolling Average"
        set xlabel "Time"
        set ylabel "Gold Price (USD)"
        set grid
        plot "/tmp/goldRollAvg.dat" using 1:2 with lines title "Gold Rolling Average"
GP

    echo "[OK] Wrote ${OUTDIR}/goldRollAvg.png"
}

plot_gold_vs_silver(){
    mysql_query "SELECT g.timestamp, g.price, s.price FROM gold_prices g JOIN silver_prices s ON g.timestamp=s.timestamp ORDER BY g.timestamp;" \
        > /tmp/gold_vs_silver_raw.csv

    tail -n +2 /tmp/gold_vs_silver_raw.csv | awk -F '\t' '{print $2 "\t" $3}' > /tmp/gold_vs_silver.dat

    gnuplot <<-GP
        set terminal png size 1200,720
        set output "${OUTDIR}/gold_vs_silver.png"
        set title "Gold vs Silver Prices"
        set xlabel "Gold Price (USD)"
        set ylabel "Silver Price (USD)"
        set grid
        plot "/tmp/gold_vs_silver.dat" using 1:2 with points pointtype 7 pointsize 1 title "Data Points"
GP

    echo "[OK] Wrote ${OUTDIR}/gold_vs_silver.png"
}

plot_gold_vs_time(){
    mysql_query "SELECT timestamp, price FROM gold_prices ORDER BY timestamp;" > /tmp/gold_vs_time_raw.csv
    tail -n +2 /tmp/gold_vs_time_raw.csv > /tmp/gold_vs_time.dat

    gnuplot <<-GP
        set terminal png size 1200,720
        set output "${OUTDIR}/gold_vs_time.png"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%m/%d\n%H:%M"
        set title "Gold Price vs Time"
        set xlabel "Time"
        set ylabel "Gold Price (USD)"
        set grid
        plot "/tmp/gold_vs_time.dat" using 1:2 with lines title "Gold Price"
GP

    echo "[OK] Wrote ${OUTDIR}/gold_vs_time.png"
}

plot_gold_boxplot(){
    mysql_query "SELECT price FROM gold_prices WHERE price IS NOT NULL;" > /tmp/goldPriceVals_raw.csv
    tail -n +2 /tmp/goldPriceVals_raw.csv > /tmp/goldPriceVals.dat

    gnuplot <<-GP
        set terminal png size 800,800
        set output "${OUTDIR}/goldPrice_boxplot.png"
        set title "Boxplot of Gold Prices"
        set ylabel "Gold Price (USD)"
        set style boxplot outliers pointtype 7
        set style data boxplot
        plot "/tmp/goldPriceVals.dat" using (1):1 notitle
GP

    echo "[OK] Wrote ${OUTDIR}/goldPrice_boxplot.png"
}

plot_gold_spread(){
    mysql_query "SELECT g.timestamp, g.price, s.price FROM gold_prices g JOIN silver_prices s ON g.timestamp=s.timestamp ORDER BY g.timestamp;" > /tmp/goldSpread_raw.csv
    tail -n +2 /tmp/goldSpread_raw.csv | awk -F'\t' '{ if($2!="" && $3!="") print $1 "\t" ($2-$3); }' > /tmp/goldSpread.dat

    gnuplot <<-GP
        set terminal png size 1200,700
        set output "${OUTDIR}/goldSpread.png"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%m/%d\n%H:%M"
        set title "Gold-Silver Spread vs Time"
        set xlabel "Time"
        set ylabel "Spread (USD)"
        set grid
        plot "/tmp/goldSpread.dat" using 1:2 with lines title "Spread"
GP

    echo "[OK] Wrote ${OUTDIR}/goldSpread.png"
}

plot_silver_percent_hist(){
    mysql_query "
        SELECT ROUND((price - LAG(price) OVER (ORDER BY timestamp))/LAG(price) OVER (ORDER BY timestamp)*100,2) AS pct_change FROM silver_prices WHERE price IS NOT NULL;
    " > /tmp/silverPctVals_raw.csv

    tail -n +2 /tmp/silverPctVals_raw.csv > /tmp/silverPctVals.dat

    gnuplot <<-GP
        set terminal png size 1000,720
        set output "${OUTDIR}/silver_1dChange_histogram.png"
        set title "Histogram of Silver Percent Change"
        set xlabel "Percentage Change (%)"
        set ylabel "Count"
        binwidth=0.1
        bin(x,width)=width*floor(x/width)
        plot "/tmp/silverPctVals.dat" using (bin(\$1, binwidth)):(1) smooth freq with boxes notitle
GP

    echo "[OK] Wrote ${OUTDIR}/silver_1dChange_histogram.png"
}

plot_silver_rolling_avg(){
    mysql_query "SELECT timestamp, price FROM silver_prices ORDER BY timestamp;" > /tmp/silverPrices_raw.csv
    tail -n +2 /tmp/silverPrices_raw.csv > /tmp/silverPricesTime.dat

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
    }' /tmp/silverPricesTime.dat > /tmp/silverRollAvg.dat

    gnuplot <<-GP
        set terminal png size 1200,720
        set output "${OUTDIR}/silverRollAvg.png"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%m/%d\n%H:%M"
        set title "Silver Rolling Average"
        set xlabel "Time"
        set ylabel "Silver Price (USD)"
        set grid
        plot "/tmp/silverRollAvg.dat" using 1:2 with lines title "Silver Rolling Average"
GP

    echo "[OK] Wrote ${OUTDIR}/silverRollAvg.png"
}

plot_weekly_avg(){
    mysql_query "
        SELECT CONCAT(YEAR(g.timestamp), '-', LPAD(WEEK(g.timestamp,1),2,'0')) AS yw, ROUND(AVG(g.price),4), ROUND(AVG(s.price),4) FROM gold_prices g JOIN silver_prices s ON g.timestamp=s.timestamp GROUP BY yw ORDER BY yw;
    " > /tmp/weeklyAvg_raw.csv

    tail -n +2 /tmp/weeklyAvg_raw.csv > /tmp/weeklyAvg.dat

    gnuplot <<-GP
        set terminal png size 1200,720
        set output "${OUTDIR}/weeklyAvgGoldSilver.png"
        set title "Weekly Average Gold & Silver Prices"
        set xlabel "Year-Week"
        set xtics rotate by -45
        set ylabel "Price (USD)"
        set grid
        plot "/tmp/weeklyAvg.dat" using 1:2 with lines title "Gold Avg", \
             "/tmp/weeklyAvg.dat" using 1:3 with lines title "Silver Avg"
GP

    echo "[OK] Wrote ${OUTDIR}/weeklyAvgGoldSilver.png"
}

case "$1" in
    gold_hist)            plot_gold_percent_hist ;;
    gold_roll_avg)        plot_gold_rolling_avg ;;
    silver_hist)          plot_silver_percent_hist ;;
    silver_roll_avg)      plot_silver_rolling_avg ;;
    gold_vs_silver)       plot_gold_vs_silver ;;
    gold_vs_time)         plot_gold_vs_time ;;
    gold_boxplot)         plot_gold_boxplot ;;
    gold_spread)          plot_gold_spread ;;
    weekly_goldsilver)    plot_weekly_avg ;;
    *)
        echo "Usage: ./plots.sh <function>"
        echo ""
        echo "Functions:"
        echo "  gold_hist"
        echo "  gold_roll_avg"
        echo "  silver_hist"
        echo "  silver_roll_avg"
        echo "  gold_vs_silver"
        echo "  gold_vs_time"
        echo "  gold_boxplot"
        echo "  gold_spread"
        echo "  weekly_goldsilver"
        ;;
esac