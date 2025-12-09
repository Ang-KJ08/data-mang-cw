#!/bin/bash

DB_HOST="localhost"
DB_NAME="gold_prices"
DB_USER="root"
DB_PASS="angkj_08"

SCRIPT_DIR=$(dirname "$0")
PLOTS_DIR="$SCRIPT_DIR/plots"
DATA_DIR="$SCRIPT_DIR/data"
mkdir -p "$PLOTS_DIR"
mkdir -p "$DATA_DIR"

log_message(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

check_data_count(){
    local count=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT COUNT(*) FROM goldsilver_price" 2>/dev/null)
    echo $count
}

plot_gold_price_over_time(){
    log_message "Creating plot 1: Gold Price Over Time"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT scraped_date, current_price FROM goldsilver_price 
         WHERE metal_type = 'gold' 
         ORDER BY scraped_date" > "$DATA_DIR/gold_prices.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/gold_price_over_time.png'
set title 'Gold Price Over Time'
set xlabel 'Date'
set ylabel 'Price (USD)'
set grid
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%d'
set xtics rotate by 45 right
plot '$DATA_DIR/gold_prices.csv' using 1:2 with linespoints lc rgb '#FFD700' lw 2 pt 7 ps 0.5 title 'Gold Price'
EOF
    
    log_message "Plot 1 saved"
}

plot_silver_price_over_time(){
    log_message "Creating plot 2: Silver Price Over Time"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT scraped_date, current_price FROM goldsilver_price 
         WHERE metal_type = 'silver' 
         ORDER BY scraped_date" > "$DATA_DIR/silver_prices.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/silver_price_over_time.png'
set title 'Silver Price Over Time'
set xlabel 'Date'
set ylabel 'Price (USD)'
set grid
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%d'
set xtics rotate by 45 right
plot '$DATA_DIR/silver_prices.csv' using 1:2 with linespoints lc rgb '#C0C0C0' lw 2 pt 7 ps 0.5 title 'Silver Price'
EOF
    
    log_message "Plot 2 saved"
}

plot_gold_vs_silver(){
    log_message "Creating plot 3: Gold vs Silver Prices"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT g.scraped_date, g.current_price as gold_price, s.current_price as silver_price
         FROM goldsilver_price g
         JOIN goldsilver_price s ON g.scraped_date = s.scraped_date 
         WHERE g.metal_type = 'gold' AND s.metal_type = 'silver'
         ORDER BY g.scraped_date" > "$DATA_DIR/gold_vs_silver.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/gold_vs_silver.png'
set title 'Gold vs Silver Prices Comparison'
set xlabel 'Date'
set ylabel 'Gold Price (USD)'
set y2label 'Silver Price (USD)'
set grid
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%d'
set xtics rotate by 45 right
set ytics nomirror
set y2tics
plot '$DATA_DIR/gold_vs_silver.csv' using 1:2 axes x1y1 with lines lc rgb '#FFD700' lw 2 title 'Gold', \
     '' using 1:3 axes x1y2 with lines lc rgb '#C0C0C0' lw 2 title 'Silver'
EOF
    
    log_message "Plot 3 saved"
}

plot_daily_changes(){
    log_message "Creating plot 4: Daily Price Changes"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT scraped_date, recent_change 
         FROM goldsilver_price 
         WHERE metal_type = 'gold' 
         ORDER BY scraped_date" > "$DATA_DIR/daily_changes.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/daily_changes.png'
set title 'Gold Daily Price Changes'
set xlabel 'Date'
set ylabel 'Daily Change (USD)'
set grid
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%d'
set xtics rotate by 45 right
set style fill solid 0.5
plot '$DATA_DIR/daily_changes.csv' using 1:2 with boxes lc rgb '#00FF00' title 'Change'
EOF
    
    log_message "Plot 4 saved"
}

plot_monthly_performance(){
    log_message "Creating plot 5: Monthly Performance"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT metal_type, scraped_date, monthly_change_percent 
         FROM goldsilver_price 
         WHERE DAY(scraped_date) = 1
         ORDER BY scraped_date, metal_type" > "$DATA_DIR/monthly_performance.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/monthly_performance.png'
set title 'Monthly Performance (% Change)'
set xlabel 'Date'
set ylabel 'Monthly Change (%)'
set grid
set xdata time
set timefmt '%Y-%m-%d'
set format x '%b %Y'
set xtics rotate by 45 right
plot '$DATA_DIR/monthly_performance.csv' using 1:3 with linespoints lc rgb '#FFD700' lw 2 pt 7 ps 1 title 'Gold'
EOF
    
    log_message "Plot 5 saved"
}

plot_price_distribution(){
    log_message "Creating plot 6: Price Distribution Histogram"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT current_price FROM goldsilver_price WHERE metal_type = 'gold'" > "$DATA_DIR/gold_distribution.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/price_distribution.png'
set title 'Gold Price Distribution'
set xlabel 'Price (USD)'
set ylabel 'Frequency'
set grid
set style fill solid 0.5
plot '$DATA_DIR/gold_distribution.csv' using (1):(1) with boxes lc rgb '#FFD700' title 'Gold'
EOF
    
    log_message "Plot 6 saved"
}

plot_correlation(){
    log_message "Creating plot 7: Gold-Silver Correlation"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT g.current_price, s.current_price
         FROM goldsilver_price g
         JOIN goldsilver_price s ON g.scraped_date = s.scraped_date 
         WHERE g.metal_type = 'gold' AND s.metal_type = 'silver'" > "$DATA_DIR/correlation.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/correlation.png'
set title 'Gold vs Silver Price Correlation'
set xlabel 'Gold Price (USD)'
set ylabel 'Silver Price (USD)'
set grid
plot '$DATA_DIR/correlation.csv' using 1:2 with points pt 7 ps 2 lc rgb '#666666' title 'Data Points'
EOF
    
    log_message "Plot 7 saved"
}

plot_moving_average(){
    log_message "Creating plot 8: Moving Average Trend"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT scraped_date, current_price FROM goldsilver_price 
         WHERE metal_type = 'gold' 
         ORDER BY scraped_date" > "$DATA_DIR/gold_ma.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/moving_average.png'
set title 'Gold Price Trend'
set xlabel 'Date'
set ylabel 'Price (USD)'
set grid
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%d'
set xtics rotate by 45 right
plot '$DATA_DIR/gold_ma.csv' using 1:2 with lines lc rgb '#FFD700' lw 2 title 'Gold Price'
EOF
    
    log_message "Plot 8 saved"
}

plot_volatility(){
    log_message "Creating plot 9: Volatility Analysis"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT scraped_date, ABS(recent_change_percent) as daily_volatility
         FROM goldsilver_price 
         WHERE metal_type = 'gold' 
         ORDER BY scraped_date" > "$DATA_DIR/volatility.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/volatility.png'
set title 'Gold Daily Volatility'
set xlabel 'Date'
set ylabel 'Daily Volatility (%)'
set grid
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%d'
set xtics rotate by 45 right
plot '$DATA_DIR/volatility.csv' using 1:2 with points pt 7 ps 2 lc rgb '#FF6B6B' title 'Volatility'
EOF
    
    log_message "Plot 9 saved"
}

plot_gold_silver_ratio(){
    log_message "Creating plot 10: Gold-to-Silver Ratio"
    
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -B -N -e \
        "SELECT g.scraped_date, g.current_price / s.current_price as ratio
         FROM goldsilver_price g
         JOIN goldsilver_price s ON g.scraped_date = s.scraped_date 
         WHERE g.metal_type = 'gold' AND s.metal_type = 'silver'
         ORDER BY g.scraped_date" > "$DATA_DIR/ratio.csv"
    
    gnuplot << EOF
set terminal pngcairo size 1200,800
set output '$PLOTS_DIR/gold_silver_ratio.png'
set title 'Gold-to-Silver Ratio'
set xlabel 'Date'
set ylabel 'Ratio (Gold Price / Silver Price)'
set grid
set xdata time
set timefmt '%Y-%m-%d'
set format x '%m/%d'
set xtics rotate by 45 right
plot '$DATA_DIR/ratio.csv' using 1:2 with linespoints lc rgb '#8B4513' lw 2 pt 5 ps 0.5 title 'Gold/Silver Ratio'
EOF
    
    log_message "Plot 10 saved"
}

main(){
    log_message "=== Generating 10 Gold/Silver Analysis Plots ==="
    
    if ! command -v gnuplot &> /dev/null; then
        log_message "ERROR: gnuplot is not installed!"
        exit 1
    fi
    
    if ! mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" "$DB_NAME" 2>/dev/null; then
        log_message "ERROR: Cannot connect to MySQL database"
        exit 1
    fi
    
    local data_count=$(check_data_count)
    log_message "Data points in database: $data_count"
    
    if [ "$data_count" -lt 2 ]; then
        log_message "WARNING: Need at least 2 days of data for meaningful plots"
        log_message "Run scraper.sh multiple times or wait for cron to collect more data"
    fi
    
    plot_gold_price_over_time
    plot_silver_price_over_time
    plot_gold_vs_silver
    plot_daily_changes
    plot_monthly_performance
    plot_price_distribution
    plot_correlation
    plot_moving_average
    plot_volatility
    plot_gold_silver_ratio
    
    log_message "=== All 10 plots generated successfully! ==="
    log_message "Plots saved in: $PLOTS_DIR/"
}

main