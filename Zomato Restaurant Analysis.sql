-- ============================================================
-- ZOMATO BANGALORE RESTAURANT ANALYSIS PROJECT
-- MYSQL 8+
-- ============================================================

-- ============================================================
-- 01. DATABASE SETUP
-- ============================================================

DROP DATABASE IF EXISTS zomato_project;
CREATE DATABASE zomato_project;
USE zomato_project;

-- ============================================================
-- 02. CREATE TABLE
-- ============================================================

CREATE TABLE zomato_restaurants (
	restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    url TEXT,
    address TEXT,
    name VARCHAR(255),
    online_order VARCHAR(10),
    book_table VARCHAR(10),
    rate VARCHAR(10),
    votes INT,
    phone VARCHAR(50),
    location VARCHAR(100),
    rest_type VARCHAR(255),
    dish_liked TEXT,
    cuisines TEXT,
    approx_cost VARCHAR(20),
    reviews_list LONGTEXT,
    menu_item LONGTEXT,
    listed_in_type VARCHAR(100),
    listed_in_city VARCHAR(100)
);

-- ============================================================
-- 03. CREATE INDEXES
-- ============================================================

CREATE INDEX idx_location
ON zomato_restaurants(location);

CREATE INDEX idx_votes
ON zomato_restaurants(votes);

CREATE INDEX idx_rate
ON zomato_restaurants(rate);

-- ============================================================
-- 04. ENABLE CSV IMPORT
-- ============================================================

SET GLOBAL local_infile = 1;

-- ============================================================
-- 05. LOAD CSV DATA
-- ============================================================

LOAD DATA LOCAL INFILE 'D:/Zomato/Zomato/zomato-bangalore-analysis-mysql/data/zomato.csv'
INTO TABLE zomato_restaurants
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM zomato_restaurants;
-- ============================================================
-- 06. DATA CLEANING & PREPARATION
-- ============================================================

-- Rating cleaning

SELECT
    name,
    rate AS raw_rate,
    CASE
        WHEN rate = 'NEW'
          OR rate = '-'
          OR rate IS NULL
        THEN NULL

        ELSE CAST(REPLACE(rate, '/5', '') AS DECIMAL(3,1))
    END AS rating_numeric

FROM zomato_restaurants
LIMIT 20;

-- Missing values

SELECT
	COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN rate IS NULL
              OR rate = ''
              OR rate = '-'
              OR rate = 'NEW'
            THEN 1
            ELSE 0
        END
    ) AS missing_rate,
    SUM(
        CASE
            WHEN votes IS NULL
              OR votes = 0
            THEN 1
            ELSE 0
        END
    ) AS missing_votes,
    SUM(
        CASE
            WHEN cuisines IS NULL
              OR cuisines = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_cuisines,
	SUM(
        CASE
            WHEN approx_cost IS NULL
              OR approx_cost = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_cost,
    SUM(
        CASE
            WHEN rest_type IS NULL
              OR rest_type = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_rest_type

FROM zomato_restaurants;
DESCRIBE zomato_restaurants;

ALTER TABLE zomato_restaurants
RENAME COLUMN `approx_cost(for two people)` TO approx_cost;

ALTER TABLE zomato_restaurants
RENAME COLUMN `listed_in(type)` TO listed_in_type;

ALTER TABLE zomato_restaurants
RENAME COLUMN `listed_in(city)` TO listed_in_city;

-- Duplicate restaurants

SELECT
name,
address,
COUNT(*) AS duplicate_count
FROM zomato_restaurants
GROUP BY name, address
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 20;

-- ============================================================
-- 07. CREATE CLEANED VIEW
-- ============================================================

DROP VIEW IF EXISTS zomato_clean;
CREATE VIEW zomato_clean AS
SELECT
name,
online_order,
book_table,
     CAST(
        REPLACE(rate, '/5', '')
        AS DECIMAL(3,1)
    ) AS rating,

    votes,
    location,
    rest_type,
    dish_liked,
    cuisines,

    CAST(
        REPLACE(approx_cost, ',', '')
        AS UNSIGNED
    ) AS approx_cost,

    listed_in_type,
    listed_in_city

FROM zomato_restaurants
WHERE rate IS NOT NULL
AND rate != 'NEW'
AND rate != '-'
AND rate != '';

-- ============================================================
-- 08. RESTAURANT PERFORMANCE & RATINGS
-- ============================================================

-- Top-rated restaurants

SELECT
name,
location,
rating,
votes,
cuisines,
approx_cost
FROM zomato_clean
WHERE votes >= 100
ORDER BY rating DESC, votes DESC
LIMIT 10;

-- Online order vs ratings

SELECT
online_order,
COUNT(*) AS restaurant_count,
ROUND(AVG(rating), 2) AS avg_rating,
ROUND(AVG(votes), 0) AS avg_votes,
ROUND(AVG(approx_cost), 0) AS avg_cost
FROM zomato_clean
GROUP BY online_order;

-- Table booking analysis

SELECT
book_table,
COUNT(*) AS restaurant_count,
ROUND(AVG(rating), 2) AS avg_rating,
ROUND(AVG(approx_cost), 0) AS avg_cost,
ROUND(AVG(votes), 0) AS avg_votes
FROM zomato_clean
GROUP BY book_table;

-- Rating distribution

SELECT
CASE
	WHEN rating BETWEEN 1.0 AND 2.0
	THEN '1.0-2.0 (Poor)'
	WHEN rating BETWEEN 2.1 AND 3.0
	THEN '2.1-3.0 (Average)'
	WHEN rating BETWEEN 3.1 AND 3.5
	THEN '3.1-3.5 (Good)'
	WHEN rating BETWEEN 3.6 AND 4.0
	THEN '3.6-4.0 (Very Good)'
    WHEN rating BETWEEN 4.1 AND 4.5
	THEN '4.1-4.5 (Excellent)'
ELSE '4.5+ (Outstanding)'
END AS rating_bucket,
COUNT(*) AS restaurant_count,
ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM zomato_clean),
        2
    ) AS percentage

FROM zomato_clean
GROUP BY rating_bucket
ORDER BY rating_bucket;

-- Restaurant type rankings

SELECT
rest_type,
COUNT(*) AS restaurant_count,
ROUND(AVG(rating), 2) AS avg_rating,
ROUND(AVG(votes), 0) AS avg_votes
FROM zomato_clean
WHERE rest_type IS NOT NULL
GROUP BY rest_type
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;

-- ============================================================
-- 09. CUISINE ANALYSIS
-- ============================================================

-- Most common cuisines

SELECT
cuisines,
COUNT(*) AS restaurant_count,
ROUND(AVG(rating), 2) AS avg_rating,
ROUND(AVG(votes), 0) AS avg_votes
FROM zomato_clean
WHERE cuisines IS NOT NULL
GROUP BY cuisines
ORDER BY restaurant_count DESC
LIMIT 20;

-- Highest-rated cuisines

SELECT
cuisines,
COUNT(*) AS restaurant_count,
ROUND(AVG(rating), 2) AS avg_rating,
ROUND(AVG(approx_cost), 0) AS avg_cost
FROM zomato_clean
WHERE cuisines IS NOT NULL
GROUP BY cuisines
HAVING COUNT(*) >= 30
ORDER BY avg_rating DESC
LIMIT 15;

-- ============================================================
-- 10. COST ANALYSIS
-- ============================================================

-- Average cost by location

SELECT
location,
COUNT(*) AS restaurant_count,
ROUND(AVG(approx_cost), 0) AS avg_cost,
MIN(approx_cost) AS min_cost,
MAX(approx_cost) AS max_cost
FROM zomato_clean
WHERE approx_cost IS NOT NULL
GROUP BY location
HAVING COUNT(*) >= 10
ORDER BY avg_cost DESC
LIMIT 15;

-- Best value restaurants

SELECT
name,
location,
cuisines,
rating,
approx_cost,
votes,
	ROUND(
        rating / NULLIF(approx_cost, 0) * 100,
        2
    ) AS value_score
FROM zomato_clean
WHERE approx_cost IS NOT NULL
AND votes >= 50
AND rating >= 4.0
ORDER BY value_score DESC
LIMIT 20;

-- ============================================================
-- 11. POPULARITY ANALYSIS
-- ============================================================

-- Hidden gems

WITH location_medians AS (
SELECT
location,
votes,
ROW_NUMBER() OVER (
PARTITION BY location
ORDER BY votes) 
AS rn,
COUNT(*) OVER (
PARTITION BY location) 
AS cnt
FROM zomato_clean
),

medians AS (
SELECT
location,
AVG(votes) AS median_votes
FROM location_medians
WHERE rn IN (
FLOOR((cnt + 1) / 2),
CEIL((cnt + 1) / 2)
    )
GROUP BY location
)

SELECT

    r.name,
    r.location,
    r.rating,
    r.votes,

    ROUND(m.median_votes, 0)
    AS location_median_votes,

    r.cuisines

FROM zomato_clean r
JOIN medians m
ON r.location = m.location
WHERE r.rating >= 4.2
AND r.votes < m.median_votes * 0.5
ORDER BY r.rating DESC, r.votes ASC
LIMIT 20;

-- ============================================================
-- 12. LOCATION ANALYSIS
-- ============================================================

-- Restaurant density

SELECT
location,
COUNT(*) AS restaurant_count,
ROUND(AVG(rating), 2) AS avg_rating,
ROUND(AVG(approx_cost), 0) AS avg_cost,
SUM(votes) AS total_engagement
FROM zomato_clean
GROUP BY location
ORDER BY restaurant_count DESC
LIMIT 20;

-- Premium restaurant areas

SELECT
location,
COUNT(*) AS total_restaurants,
SUM(
        CASE
		WHEN approx_cost > 1000
		THEN 1
		ELSE 0
        END
    ) AS premium_count,

ROUND(
	100.0 *
SUM(
CASE
WHEN approx_cost > 1000
THEN 1
ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS premium_pct,

    ROUND(AVG(rating), 2) AS avg_rating

FROM zomato_clean
WHERE approx_cost IS NOT NULL
GROUP BY location
HAVING COUNT(*) >= 15
ORDER BY premium_pct DESC
LIMIT 15;

-- ============================================================
-- 13. ADVANCED TEXT ANALYSIS
-- ============================================================

WITH RECURSIVE numbers AS (
SELECT 1 AS n
UNION ALL
SELECT n + 1
FROM numbers
WHERE n < 20
),

split_dishes AS (
SELECT
	TRIM(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(dish_liked, ',', n),
                ',',
                -1
            )
        ) AS dish

FROM zomato_clean
CROSS JOIN numbers
WHERE dish_liked IS NOT NULL
AND dish_liked != ''
AND n <= (
            LENGTH(dish_liked)
          - LENGTH(REPLACE(dish_liked, ',', ''))
          + 1
      )
)

SELECT
	dish,
COUNT(*) AS mention_count
FROM split_dishes
WHERE dish != ''
GROUP BY dish
ORDER BY mention_count DESC
LIMIT 25;

-- ============================================================
-- 14. FINAL BUSINESS INSIGHTS
-- ============================================================

/*

1. Online ordering is associated with higher customer engagement.

2. Premium areas have significantly higher average dining costs.

3. Multi-cuisine restaurants tend to attract more customer votes.

4. Budget-friendly restaurants with high ratings provide the best value.

5. Some expensive restaurants underperform compared to local averages.

*/