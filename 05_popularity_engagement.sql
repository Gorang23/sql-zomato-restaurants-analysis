-- ============================================================
-- 05: POPULARITY & ENGAGEMENT ANALYSIS (MySQL 8+)
-- ============================================================


-- -------------------------------------------------------
-- Q1: Hidden Gems — high rating, low votes
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which great restaurants are flying under the radar?
-- WHY IT MATTERS: Marketing opportunity — these restaurants deserve more
--   visibility. Also great recommendations for adventurous diners.
-- NOTE: MySQL lacks PERCENTILE_CONT, so we use a window-based median approach.

WITH location_medians AS (
    SELECT
        location,
        votes,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY votes) AS rn,
        COUNT(*) OVER (PARTITION BY location) AS cnt
    FROM zomato_clean
),
medians AS (
    SELECT
        location,
        AVG(votes) AS median_votes
    FROM location_medians
    WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
    GROUP BY location
)
SELECT
    r.name,
    r.location,
    r.rating,
    r.votes,
    ROUND(m.median_votes, 0) AS location_median_votes,
    r.cuisines
FROM zomato_clean r
JOIN medians m ON r.location = m.location
WHERE r.rating >= 4.2
  AND r.votes < m.median_votes * 0.5
ORDER BY r.rating DESC, r.votes ASC
LIMIT 20;


-- -------------------------------------------------------
-- Q2: Overhyped — high votes but mediocre rating
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which popular restaurants do not live up to the hype?
-- WHY IT MATTERS: High traffic does not mean high quality.

SELECT
    name,
    location,
    votes,
    rating,
    cuisines,
    approx_cost
FROM zomato_clean
WHERE votes >= 500
  AND rating < 3.5
ORDER BY votes DESC
LIMIT 20;


-- -------------------------------------------------------
-- Q3: Engagement percentile — rank restaurants by votes within area
-- -------------------------------------------------------
-- BUSINESS QUESTION: How does each restaurant compare to its neighbors?
-- WHY IT MATTERS: A restaurant with 200 votes in a quiet area is more
--   dominant than one with 200 votes in Koramangala.

SELECT
    name,
    location,
    votes,
    rating,
    ROUND(PERCENT_RANK() OVER (
        PARTITION BY location ORDER BY votes
    ) * 100, 1) AS votes_percentile_in_area
FROM zomato_clean
WHERE votes > 0
ORDER BY location, votes_percentile_in_area DESC;


-- -------------------------------------------------------
-- Q4: Online order impact on engagement
-- -------------------------------------------------------
-- BUSINESS QUESTION: Do online-order restaurants get more engagement?
-- WHY IT MATTERS: Quantifies the business case for joining delivery platforms.

SELECT
    online_order,
    COUNT(*) AS restaurants,
    ROUND(AVG(votes), 0) AS avg_votes,
    SUM(votes) AS total_votes,
    ROUND(AVG(rating), 2) AS avg_rating
FROM zomato_clean
GROUP BY online_order;


-- -------------------------------------------------------
-- Q5: Top 3 most reviewed restaurants per location
-- -------------------------------------------------------
-- BUSINESS QUESTION: Who dominates each neighborhood?
-- WHY IT MATTERS: Identifies local market leaders.

WITH ranked AS (
    SELECT
        name,
        location,
        votes,
        rating,
        cuisines,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY votes DESC) AS rank_in_area
    FROM zomato_clean
)
SELECT name, location, votes, rating, cuisines
FROM ranked
WHERE rank_in_area <= 3
ORDER BY location, rank_in_area;
