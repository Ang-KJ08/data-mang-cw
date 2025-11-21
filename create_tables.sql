CREATE DATABASE IF NOT EXISTS gold_tracket;

USE gold_tracker;

CREATE TABLE gold_prices{
    id INT AUTO_INCREMENT PRIMARY KEY,
    gold_spot DECIMAL (10,2),
    change_rate DECIMAL (6,2),
    performance_30d DECIMAL (6,2),
    performance_1y DECIMAL (6,2),
    timestamp DATETIME
};