-- ============================================================
-- ZOMATO BANGALORE RESTAURANT ANALYSIS (MySQL 8+)
-- Schema Definition
-- ============================================================

CREATE DATABASE IF NOT EXISTS zomato;
USE zomato;

DROP TABLE IF EXISTS zomato_restaurants;

CREATE TABLE zomato_restaurants (
    url                 TEXT,
    address             TEXT,
    name                VARCHAR(255),
    online_order        VARCHAR(10),
    book_table          VARCHAR(10),
    rate                VARCHAR(10),
    votes               INT,
    phone               TEXT,
    location            VARCHAR(100),
    rest_type           VARCHAR(200),
    dish_liked          TEXT,
    cuisines            TEXT,
    approx_cost         VARCHAR(20),
    reviews_list        LONGTEXT,
    menu_item           TEXT,
    listed_in_type      VARCHAR(50),
    listed_in_city      VARCHAR(50)
);

-- Load data
-- LOAD DATA INFILE '/path/to/zomato.csv'
-- INTO TABLE zomato_restaurants
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;
