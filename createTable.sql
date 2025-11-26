CREATE DATABASE IF NOT EXISTS gold_tracker;

USE gold_tracker;

CREATE TABLE IF NOT EXISTS gold_prices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    gold_spot DECIMAL(10,2) NULL,
    change_rate DECIMAL(10,2) NULL,
    performance_30d DECIMAL(10,2) NULL,
    performance_1y DECIMAL(10,2) NULL,
    timestamp DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS silver_prices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    silver_spot DECIMAL(10,2) NULL,
    change_rate DECIMAL(10,2) NULL,
    performance_30d DECIMAL(10,2) NULL,
    performance_1y DECIMAL(10,2) NULL,
    timestamp DATETIME NOT NULL
);