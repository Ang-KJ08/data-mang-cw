CREATE DATABASE IF NOT EXISTS gold_tracker;

USE gold_tracker;

CREATE TABLE gold_prices (
id INT AUTO_INCREMENT PRIMARY KEY,
gold_spot DECIMAL(10,2) NULL,
change_rate DECIMAL(6,2) NULL,
performance_30d DECIMAL(6,2) NULL,
performance_1y DECIMAL(6,2) NULL,
timestamp DATETIME
);