-- ============================================================
-- 02: RESTAURANT PERFORMANCE & RATINGS (MySQL 8+)
-- ============================================================


-- -------------------------------------------------------
-- Q1: Top 10 highest-rated restaurants (with minimum vote threshold)
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which restaurants are truly the best in Bangalore?
-- WHY IT MATTERS: A restaurant with 5.0 rating but 2 votes is not reliable.
--   Filtering by minimum votes gives credible recommendations.

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


-- -------------------------------------------------------
-- Q2: Online order vs dine-in — does it affect ratings?
-- -------------------------------------------------------
-- BUSINESS QUESTION: Do restaurants offering online ordering rate higher?
-- WHY IT MATTERS: Helps restaurant owners decide whether to invest in
--   online ordering platforms like Swiggy/Zomato delivery.

SELECT
    online_order,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(votes), 0) AS avg_votes,
    ROUND(AVG(approx_cost), 0) AS avg_cost
FROM zomato_clean
GROUP BY online_order;


-- -------------------------------------------------------
-- Q3: Table booking vs no booking — rating comparison
-- -------------------------------------------------------
-- BUSINESS QUESTION: Are restaurants with table booking better rated?
-- WHY IT MATTERS: Table booking is often a proxy for upscale dining.
--   This validates whether premium positioning correlates with quality.

SELECT
    book_table,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(approx_cost), 0) AS avg_cost,
    ROUND(AVG(votes), 0) AS avg_votes
FROM zomato_clean
GROUP BY book_table;


-- -------------------------------------------------------
-- Q4: Rating distribution — how are restaurants spread?
-- -------------------------------------------------------
-- BUSINESS QUESTION: What does the rating landscape look like?
-- WHY IT MATTERS: Understanding distribution helps identify if ratings
--   are inflated (clustered at 4+) or normally distributed.

SELECT
    CASE
        WHEN rating BETWEEN 1.0 AND 2.0 THEN '1.0-2.0 (Poor)'
        WHEN rating BETWEEN 2.1 AND 3.0 THEN '2.1-3.0 (Average)'
        WHEN rating BETWEEN 3.1 AND 3.5 THEN '3.1-3.5 (Good)'
        WHEN rating BETWEEN 3.6 AND 4.0 THEN '3.6-4.0 (Very Good)'
        WHEN rating BETWEEN 4.1 AND 4.5 THEN '4.1-4.5 (Excellent)'
        WHEN rating > 4.5 THEN '4.5+ (Outstanding)'
    END AS rating_bucket,
    COUNT(*) AS restaurant_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM zomato_clean), 2) AS percentage
FROM zomato_clean
GROUP BY rating_bucket
ORDER BY rating_bucket;


-- -------------------------------------------------------
-- Q5: Restaurant types ranked by average rating
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which type of restaurant performs best?
-- WHY IT MATTERS: Investors and new restaurant owners can identify
--   which format (Casual Dining, Cafe, QSR) has the best reception.

SELECT
    rest_type,
    COUNT(*) AS count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(votes), 0) AS avg_votes
FROM zomato_clean
WHERE rest_type IS NOT NULL
GROUP BY rest_type
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;
