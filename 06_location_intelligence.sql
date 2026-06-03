-- ============================================================
-- 06: LOCATION INTELLIGENCE (MySQL 8+)
-- ============================================================


-- -------------------------------------------------------
-- Q1: Restaurant density by area
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which areas have the most restaurants (highest competition)?
-- WHY IT MATTERS: High density = saturated market.

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


-- -------------------------------------------------------
-- Q2: Location quality score — areas with best average ratings
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which neighborhoods have the best dining scene?
-- WHY IT MATTERS: Helps consumers pick areas and helps owners choose locations.

SELECT
    location,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(votes), 0) AS avg_votes,
    ROUND(AVG(approx_cost), 0) AS avg_cost
FROM zomato_clean
GROUP BY location
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC
LIMIT 15;


-- -------------------------------------------------------
-- Q3: Dominant cuisine per location
-- -------------------------------------------------------
-- BUSINESS QUESTION: What food defines each neighborhood?
-- WHY IT MATTERS: Reveals cultural patterns and identifies gaps.

WITH cuisine_counts AS (
    SELECT
        location,
        cuisines,
        COUNT(*) AS cnt,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY COUNT(*) DESC) AS rn
    FROM zomato_clean
    WHERE cuisines IS NOT NULL
    GROUP BY location, cuisines
)
SELECT location, cuisines AS dominant_cuisine, cnt AS restaurant_count
FROM cuisine_counts
WHERE rn = 1
ORDER BY cnt DESC
LIMIT 20;f


-- -------------------------------------------------------
-- Q4: Location competitiveness — rating spread within areas
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which areas have the widest quality gap?
-- WHY IT MATTERS: High variance = inconsistent dining experience.

SELECT
    location,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    ROUND(MAX(rating) - MIN(rating), 1) AS rating_spread,
    ROUND(STDDEV(rating), 2) AS rating_stddev
FROM zomato_clean
GROUP BY location
HAVING COUNT(*) >= 20
ORDER BY rating_stddev DESC
LIMIT 15;


-- -------------------------------------------------------
-- Q5: Areas with highest proportion of premium restaurants
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which areas are the fine dining hubs?
-- WHY IT MATTERS: Identifies upscale corridors for premium brand placement.

SELECT
    location,
    COUNT(*) AS total_restaurants,
    SUM(CASE WHEN approx_cost > 1000 THEN 1 ELSE 0 END) AS premium_count,
    ROUND(100.0 * SUM(CASE WHEN approx_cost > 1000 THEN 1 ELSE 0 END)
          / COUNT(*), 1) AS premium_pct,
    ROUND(AVG(rating), 2) AS avg_rating
FROM zomato_clean
WHERE approx_cost IS NOT NULL
GROUP BY location
HAVING COUNT(*) >= 15
ORDER BY premium_pct DESC
LIMIT 15;
