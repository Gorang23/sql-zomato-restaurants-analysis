-- ============================================================
-- 03: CUISINE ANALYSIS (MySQL 8+)
-- ============================================================


-- -------------------------------------------------------
-- Q1: Most common cuisines in Bangalore
-- -------------------------------------------------------
-- BUSINESS QUESTION: What food does Bangalore eat the most?
-- WHY IT MATTERS: Identifies market saturation and opportunity gaps.

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


-- -------------------------------------------------------
-- Q2: Highest-rated cuisine types (minimum 30 restaurants)
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which cuisines are loved the most?
-- WHY IT MATTERS: Helps food entrepreneurs pick a cuisine with proven
--   customer satisfaction, not just popularity.

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


-- -------------------------------------------------------
-- Q3: Cuisine diversity — restaurants offering the most cuisines
-- -------------------------------------------------------
-- BUSINESS QUESTION: Do multi-cuisine restaurants perform better or worse?
-- WHY IT MATTERS: Tests the "jack of all trades" hypothesis.

SELECT
    name,
    cuisines,
    (LENGTH(cuisines) - LENGTH(REPLACE(cuisines, ',', '')) + 1) AS cuisine_count,
    rating,
    votes
FROM zomato_clean
WHERE cuisines IS NOT NULL
ORDER BY cuisine_count DESC
LIMIT 20;


-- -------------------------------------------------------
-- Q4: Single-cuisine vs multi-cuisine — rating comparison
-- -------------------------------------------------------
-- BUSINESS QUESTION: Should a new restaurant focus on one cuisine or many?
-- WHY IT MATTERS: Data-driven answer to a common restaurant strategy question.

SELECT
    CASE
        WHEN (LENGTH(cuisines) - LENGTH(REPLACE(cuisines, ',', '')) + 1) = 1 THEN 'Single Cuisine'
        WHEN (LENGTH(cuisines) - LENGTH(REPLACE(cuisines, ',', '')) + 1) BETWEEN 2 AND 3 THEN '2-3 Cuisines'
        WHEN (LENGTH(cuisines) - LENGTH(REPLACE(cuisines, ',', '')) + 1) BETWEEN 4 AND 5 THEN '4-5 Cuisines'
        ELSE '6+ Cuisines'
    END AS cuisine_diversity,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(votes), 0) AS avg_votes,
    ROUND(AVG(approx_cost), 0) AS avg_cost
FROM zomato_clean
WHERE cuisines IS NOT NULL
GROUP BY cuisine_diversity
ORDER BY avg_rating DESC;


-- -------------------------------------------------------
-- Q5: Top cuisines by votes (most engaged customers)
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which cuisines generate the most customer engagement?
-- WHY IT MATTERS: High votes = high footfall and word-of-mouth.

SELECT
    cuisines,
    COUNT(*) AS restaurant_count,
    SUM(votes) AS total_votes,
    ROUND(AVG(votes), 0) AS avg_votes_per_restaurant,
    ROUND(AVG(rating), 2) AS avg_rating
FROM zomato_clean
WHERE cuisines IS NOT NULL
GROUP BY cuisines
HAVING COUNT(*) >= 20
ORDER BY avg_votes_per_restaurant DESC
LIMIT 15;
