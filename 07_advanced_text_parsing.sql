-- ============================================================
-- 07: ADVANCED TEXT PARSING & STRING MANIPULATION (MySQL 8+)
-- ============================================================
-- MySQL lacks UNNEST/STRING_TO_ARRAY, so we use recursive CTEs
-- with SUBSTRING_INDEX to split comma-separated values.
-- This is a common real-world challenge in MySQL environments.
-- ============================================================


-- -------------------------------------------------------
-- Q1: Most popular individual dishes across all restaurants
-- -------------------------------------------------------
-- BUSINESS QUESTION: What are the most loved dishes in Bangalore?
-- WHY IT MATTERS: Helps food delivery platforms feature trending dishes.
-- TECHNIQUE: Recursive CTE to split comma-separated dish_liked column.

WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 20
),
split_dishes AS (
    SELECT
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(dish_liked, ',', n), ',', -1)) AS dish
    FROM zomato_clean
    CROSS JOIN numbers
    WHERE dish_liked IS NOT NULL AND dish_liked != ''
      AND n <= (LENGTH(dish_liked) - LENGTH(REPLACE(dish_liked, ',', '')) + 1)
)
SELECT
    dish,
    COUNT(*) AS mention_count
FROM split_dishes
WHERE dish != ''
GROUP BY dish
ORDER BY mention_count DESC
LIMIT 25;


-- -------------------------------------------------------
-- Q2: Most popular dishes per location
-- -------------------------------------------------------
-- BUSINESS QUESTION: What does each neighborhood crave?
-- WHY IT MATTERS: Hyper-local menu recommendations for delivery apps.

WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 20
),
split_dishes AS (
    SELECT
        location,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(dish_liked, ',', n), ',', -1)) AS dish
    FROM zomato_clean
    CROSS JOIN numbers
    WHERE dish_liked IS NOT NULL AND dish_liked != ''
      AND n <= (LENGTH(dish_liked) - LENGTH(REPLACE(dish_liked, ',', '')) + 1)
),
ranked AS (
    SELECT
        location,
        dish,
        COUNT(*) AS mentions,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY COUNT(*) DESC) AS rn
    FROM split_dishes
    WHERE dish != ''
    GROUP BY location, dish
)
SELECT location, dish, mentions
FROM ranked
WHERE rn <= 3
ORDER BY location, rn;


-- -------------------------------------------------------
-- Q3: Restaurants with the most liked dishes (menu breadth)
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which restaurants have the widest appeal?
-- WHY IT MATTERS: More liked dishes = more reasons for customers to visit.

SELECT
    name,
    location,
    rating,
    votes,
    (LENGTH(dish_liked) - LENGTH(REPLACE(dish_liked, ',', '')) + 1) AS liked_dish_count,
    dish_liked
FROM zomato_clean
WHERE dish_liked IS NOT NULL AND dish_liked != ''
ORDER BY liked_dish_count DESC
LIMIT 20;


-- -------------------------------------------------------
-- Q4: Restaurants that appear in multiple listing categories
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which restaurants are versatile enough to be listed
--   under multiple categories (Buffet, Delivery, Dine-out)?
-- WHY IT MATTERS: Multi-category presence = broader customer reach.

SELECT
    name,
    location,
    COUNT(DISTINCT listed_in_type) AS category_count,
    GROUP_CONCAT(DISTINCT listed_in_type SEPARATOR ', ') AS categories,
    ROUND(AVG(rating), 2) AS avg_rating,
    MAX(votes) AS max_votes
FROM zomato_clean
GROUP BY name, location
HAVING COUNT(DISTINCT listed_in_type) > 1
ORDER BY category_count DESC, max_votes DESC
LIMIT 20;


-- -------------------------------------------------------
-- Q5: Cuisine co-occurrence — which cuisines pair together most?
-- -------------------------------------------------------
-- BUSINESS QUESTION: What cuisine combinations are most common?
-- WHY IT MATTERS: Reveals natural pairings (e.g., North Indian + Chinese).

WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
),
split_cuisines AS (
    SELECT
        name,
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cuisines, ',', n), ',', -1)) AS cuisine
    FROM zomato_clean
    CROSS JOIN numbers
    WHERE cuisines IS NOT NULL
      AND cuisines LIKE '%,%'
      AND n <= (LENGTH(cuisines) - LENGTH(REPLACE(cuisines, ',', '')) + 1)
)
SELECT
    a.cuisine AS cuisine_1,
    b.cuisine AS cuisine_2,
    COUNT(DISTINCT a.name) AS pair_count
FROM split_cuisines a
JOIN split_cuisines b
    ON a.name = b.name AND a.cuisine < b.cuisine
GROUP BY a.cuisine, b.cuisine
ORDER BY pair_count DESC
LIMIT 20;
