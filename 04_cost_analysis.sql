-- ============================================================
-- 04: COST ANALYSIS (MySQL 8+)
-- ============================================================


-- -------------------------------------------------------
-- Q1: Average cost by location — most expensive areas
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which Bangalore neighborhoods are the priciest to dine in?
-- WHY IT MATTERS: Helps new restaurants choose locations matching their price positioning.

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


-- -------------------------------------------------------
-- Q2: Cost vs Rating — do expensive restaurants rate higher?
-- -------------------------------------------------------
-- BUSINESS QUESTION: Does spending more guarantee a better experience?
-- WHY IT MATTERS: Tests whether price is a reliable proxy for quality.

SELECT
    CASE
        WHEN approx_cost < 300 THEN 'Budget (< 300)'
        WHEN approx_cost BETWEEN 300 AND 600 THEN 'Mid-range (300-600)'
        WHEN approx_cost BETWEEN 601 AND 1000 THEN 'Premium (601-1000)'
        ELSE 'Luxury (> 1000)'
    END AS cost_segment,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(votes), 0) AS avg_votes
FROM zomato_clean
WHERE approx_cost IS NOT NULL
GROUP BY cost_segment
ORDER BY avg_rating DESC;


-- -------------------------------------------------------
-- Q3: Best value for money — high rating, low cost
-- -------------------------------------------------------
-- BUSINESS QUESTION: Where can you eat well without breaking the bank?
-- WHY IT MATTERS: Most actionable insight for consumers.

SELECT
    name,
    location,
    cuisines,
    rating,
    approx_cost,
    votes,
    ROUND(rating / NULLIF(approx_cost, 0) * 100, 2) AS value_score
FROM zomato_clean
WHERE approx_cost IS NOT NULL
  AND votes >= 50
  AND rating >= 4.0
ORDER BY value_score DESC
LIMIT 20;


-- -------------------------------------------------------
-- Q4: Cost comparison by restaurant type
-- -------------------------------------------------------
-- BUSINESS QUESTION: How does pricing differ across restaurant formats?
-- WHY IT MATTERS: Benchmarks for new entrants.

SELECT
    rest_type,
    COUNT(*) AS count,
    ROUND(AVG(approx_cost), 0) AS avg_cost,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(approx_cost) / NULLIF(AVG(rating), 0), 0) AS cost_per_rating_point
FROM zomato_clean
WHERE rest_type IS NOT NULL AND approx_cost IS NOT NULL
GROUP BY rest_type
HAVING COUNT(*) >= 20
ORDER BY avg_cost DESC;


-- -------------------------------------------------------
-- Q5: Overpriced restaurants — high cost, low rating vs area average
-- -------------------------------------------------------
-- BUSINESS QUESTION: Which restaurants charge more than their area average but underdeliver?
-- WHY IT MATTERS: Red flags for consumers.

SELECT
    r.name,
    r.location,
    r.approx_cost,
    loc.avg_location_cost,
    r.approx_cost - loc.avg_location_cost AS cost_above_avg,
    r.rating
FROM zomato_clean r
JOIN (
    SELECT location, ROUND(AVG(approx_cost), 0) AS avg_location_cost
    FROM zomato_clean
    WHERE approx_cost IS NOT NULL
    GROUP BY location
) loc ON r.location = loc.location
WHERE r.approx_cost > loc.avg_location_cost * 1.5
  AND r.rating < 3.5
ORDER BY cost_above_avg DESC
LIMIT 20;
