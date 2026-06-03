# Zomato Bangalore Restaurant Analysis (MySQL 8+)

## Overview
SQL-based exploratory analysis of **50,000+ restaurants** in Bangalore using Zomato data. This project uncovers dining trends, pricing patterns, cuisine preferences, and location intelligence to answer real business questions.

## Dataset
- **Source:** [Kaggle - Zomato Restaurants Data](https://www.kaggle.com/datasets/shrutimehta/zomato-restaurants-data)
- **Records:** ~51,000 restaurant listings
- **Columns:** 17 (name, location, cuisines, cost, rating, votes, etc.)
- **Geography:** Bangalore, India

## Tools Used
- MySQL 8.0+
- Git & GitHub for version control

## Questions Explored

### Restaurant Performance
- Which restaurants are truly the best (with statistical confidence)?
- Does online ordering correlate with higher ratings?
- How are ratings distributed across the city?

### Cuisine Analysis
- What are the most common and highest-rated cuisines?
- Do multi-cuisine restaurants outperform focused ones?
- Which cuisines generate the most customer engagement?

### Cost Analysis
- Which neighborhoods are the priciest?
- Does spending more guarantee a better experience?
- Where can you eat well without breaking the bank?

### Popularity & Engagement
- Which great restaurants are flying under the radar (hidden gems)?
- Which popular restaurants don't live up to the hype?
- How does each restaurant's popularity compare to its neighbors?

### Location Intelligence
- Which areas have the highest restaurant density?
- What cuisine defines each neighborhood?
- Where are the fine dining hubs?

### Advanced Text Parsing
- What are the most popular individual dishes?
- Which restaurants offer the most diverse menus?

## Key Findings
See [findings/insights_summary.md](findings/insights_summary.md) for detailed insights.

## How to Run

```bash
# 1. Create the database and table
mysql -u root < schema.sql

# 2. Load the CSV data (update path in schema.sql)
# Or use MySQL Workbench Import Wizard

# 3. Run data cleaning first (creates the clean view)
mysql -u root zomato < queries/01_data_cleaning.sql

# 4. Run any analysis file
mysql -u root zomato < queries/02_restaurant_performance.sql
```

## Project Structure
```
sql-zomato-restaurants-analysis/
│
├── 01_data_cleaning.sql
├── 02_restaurant_performance.sql
├── 03_cuisine_analysis.sql
├── 04_cost_analysis.sql
├── 05_popularity_engagement.sql
├── 06_location_intelligence.sql
├── 07_advanced_text_parsing.sql
|
├── Screenshot 2026-06-03 155111.png
├── Screenshot 2026-06-03 155237.png
├── Screenshot 2026-06-03 155513.png
├── Screenshot 2026-06-03 155621.png
|── Screenshot 2026-06-03 155721.png
|
|── README.md
├── schema.sql
├── insights_summary.md

## Skills Demonstrated
- Data cleaning & preparation (handling messy real-world data)
- Window functions (ROW_NUMBER, PERCENT_RANK, NTILE)
- CTEs and subqueries
- Conditional aggregation (CASE WHEN)
- String manipulation (SUBSTRING_INDEX, recursive CTEs for splitting)
- Statistical analysis (STDDEV, percentiles via window functions)
- Business-oriented analytical thinking

