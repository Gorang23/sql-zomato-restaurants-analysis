-- ============================================================
-- 01: DATA CLEANING & PREPARATION (MySQL 8+)
-- ============================================================


-- -------------------------------------------------------
-- Q1: Parse the rating column from "X/5" to a numeric value
-- -------------------------------------------------------
-- BUSINESS QUESTION: How do we standardize ratings for analysis?
-- WHY IT MATTERS: Raw data has ratings as strings like "4.1/5" or "NEW"
--   which cannot be used in calculations without cleaning.

SELECT
    name,
    rate AS raw_rate,
    CASE
        WHEN rate = 'NEW' OR rate = '-' OR rate IS NULL THEN NULL
        ELSE CAST(REPLACE(rate, '/5', '') AS DECIMAL(3,1))
    END AS rating_numeric
FROM zomato_restaurants
LIMIT 20;


-- -------------------------------------------------------
-- Q2: Identify and count NULL/missing values per column
-- -------------------------------------------------------
-- BUSINESS QUESTION: How complete is our dataset?
-- WHY IT MATTERS: Knowing data gaps helps us decide which analyses
--   are reliable and where we need to caveat our findings.

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN rate IS NULL OR rate = '' OR rate = '-' OR rate = 'NEW' THEN 1 ELSE 0 END) AS missing_rate,
    SUM(CASE WHEN votes IS NULL OR votes = 0 THEN 1 ELSE 0 END) AS missing_votes,
    SUM(CASE WHEN cuisines IS NULL OR cuisines = '' THEN 1 ELSE 0 END) AS missing_cuisines,
    SUM(CASE WHEN approx_cost IS NULL OR approx_cost = '' THEN 1 ELSE 0 END) AS missing_cost,
    SUM(CASE WHEN rest_type IS NULL OR rest_type = '' THEN 1 ELSE 0 END) AS missing_rest_type
FROM zomato_restaurants;


-- -------------------------------------------------------
-- Q3: Find duplicate restaurants
-- -------------------------------------------------------
-- BUSINESS QUESTION: Are there duplicate entries skewing our analysis?
-- WHY IT MATTERS: Duplicates inflate counts and distort averages.

SELECT
    name,
    address,
    COUNT(*) AS duplicate_count
FROM zomato_restaurants
GROUP BY name, address
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 20;


-- -------------------------------------------------------
-- Q4: Create a cleaned view for downstream analysis
-- -------------------------------------------------------
-- BUSINESS QUESTION: How do we prepare a reliable base table?
-- WHY IT MATTERS: All subsequent queries use this cleaned version,
--   ensuring consistency across the entire analysis.

CREATE OR REPLACE VIEW zomato_clean AS
SELECT
    name,
    online_order,
    book_table,
    CAST(REPLACE(rate, '/5', '') AS DECIMAL(3,1)) AS rating,
    votes,
    location,
    rest_type,
    dish_liked,
    cuisines,
    CAST(REPLACE(approx_cost, ',', '') AS UNSIGNED) AS approx_cost,
    listed_in_type,
    listed_in_city
FROM zomato_restaurants
WHERE rate IS NOT NULL AND rate != 'NEW' AND rate != '-' AND rate != '';
