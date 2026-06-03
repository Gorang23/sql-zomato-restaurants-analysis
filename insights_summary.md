# Key Findings & Insights

## Dataset Overview
- **Total records:** 51,717
- **Clean records (with valid ratings):** 41,665
- **Locations covered:** 90+ neighborhoods in Bangalore

---

## Top Insights

### 1. Online Ordering Slightly Boosts Ratings
- Online order restaurants: **avg rating 3.72** (27,206 restaurants)
- No online order: **avg rating 3.66** (14,459 restaurants)
- However, non-online restaurants have higher average cost (Rs 716 vs Rs 544), suggesting they skew toward dine-in premium experiences.

### 2. Table Booking = Premium Signal (Confirmed)
- Restaurants with table booking: **avg rating 4.14**, avg cost **Rs 1,276**, avg votes **1,171**
- Without table booking: **avg rating 3.62**, avg cost **Rs 482**, avg votes **206**
- Table booking restaurants rate **0.52 points higher** and get **5.7x more engagement**.

### 3. Price Correlates with Rating — Luxury Leads
| Segment | Avg Rating | Avg Votes | Count |
|---------|-----------|-----------|-------|
| Luxury (> Rs 1000) | 4.13 | 1,225 | 5,135 |
| Premium (Rs 601-1000) | 3.80 | 514 | 7,790 |
| Mid-range (Rs 300-600) | 3.61 | 177 | 21,176 |
| Budget (< Rs 300) | 3.56 | 72 | 7,317 |

Spending more does correlate with better ratings, but the biggest jump is from mid-range to premium (+0.19 points).

### 4. Multi-Cuisine Restaurants Actually Rate HIGHER
Contrary to the "jack of all trades" hypothesis:
| Diversity | Avg Rating | Avg Votes | Count |
|-----------|-----------|-----------|-------|
| 6+ Cuisines | 3.99 | 732 | 1,184 |
| 4-5 Cuisines | 3.85 | 727 | 7,235 |
| 2-3 Cuisines | 3.67 | 287 | 24,275 |
| Single Cuisine | 3.62 | 175 | 8,960 |

More cuisines = higher rating. Likely because multi-cuisine restaurants tend to be larger, better-funded establishments.

### 5. 204 Hidden Gems Identified
Restaurants with rating >= 4.2 but less than half their area's median votes. These are high-quality restaurants that lack visibility.

### 6. BTM Dominates Restaurant Density
| Location | Count | Avg Rating | Avg Cost |
|----------|-------|-----------|----------|
| BTM | 3,930 | 3.57 | Rs 419 |
| Koramangala 5th Block | 2,319 | 4.01 | Rs 681 |
| HSR | 2,019 | 3.67 | Rs 500 |
| Indiranagar | 1,847 | 3.83 | Rs 679 |
| JP Nagar | 1,717 | 3.68 | Rs 554 |

BTM has the most restaurants but below-average ratings. Koramangala 5th Block has both high density AND the best average rating (4.01).

### 7. Chinese + North Indian is the #1 Cuisine Pairing
| Pair | Co-occurrence |
|------|--------------|
| Chinese + North Indian | 1,857 restaurants |
| North Indian + South Indian | 771 |
| Chinese + South Indian | 621 |
| Biryani + North Indian | 547 |

### 8. Pasta is the Most Loved Dish in Bangalore
| Dish | Mentions |
|------|----------|
| Pasta | 3,387 |
| Burgers | 3,017 |
| Cocktails | 2,796 |
| Pizza | 2,702 |
| Biryani | 2,073 |
| Coffee | 1,988 |

Surprisingly, Pasta beats Biryani — reflecting Bangalore's cosmopolitan, young professional demographic.

### 9. Rating Distribution is Right-Skewed
- 43.6% of restaurants fall in the 3.6-4.0 range (Very Good)
- Only 1.41% achieve 4.5+ (Outstanding)
- Just 0.04% rate below 2.0
- The median restaurant is "Very Good" — ratings are inflated.

---

## SQL Skills Demonstrated

| Technique | Used In |
|-----------|---------|
| CTEs (Common Table Expressions) | All files |
| Window Functions (ROW_NUMBER, PERCENT_RANK, PERCENTILE_CONT) | Files 05, 06, 07 |
| Conditional Aggregation (CASE WHEN) | Files 02, 03, 04 |
| Subqueries & JOINs | Files 04, 05 |
| String Manipulation (STRING_TO_ARRAY, UNNEST, LENGTH tricks) | File 07 |
| Statistical Functions (STDDEV, percentiles) | Files 05, 06 |
| Views for data pipeline | File 01 |
| Self-JOINs | File 07 (cuisine co-occurrence) |

---

## Recommendations for Further Analysis
- Sentiment analysis on the reviews_list column (NLP project extension)
- Time-series analysis if date data is available
- Geospatial clustering using address/location data
- Build a Tableau/Power BI dashboard with the top 5 findings
