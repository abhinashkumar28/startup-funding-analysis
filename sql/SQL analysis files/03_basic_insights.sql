-- PROJECT: STARTUP FUNDING ANALYSIS
-- FILE: 03_basic_insights.sql
-- PURPOSE: BASIC BUSINESS INSIGHTS
-- =====================================================

USE startup_funding_analysis;


-- Q1. TOTAL FUNDING RECORDS
-- How many funding records are in the dataset?

SELECT
    COUNT(*) AS total_funding_records
FROM startup_funding;


-- Q2. UNIQUE STARTUPS
-- How many distinct startups received funding?

SELECT
    COUNT(DISTINCT startup_name) AS unique_startups
FROM startup_funding;


-- Q3. INDUSTRY DISTRIBUTION
-- How many funding records belong to each industry?

SELECT
    industry_vertical,
    COUNT(*) AS total_funding_records
FROM startup_funding
WHERE industry_vertical IS NOT NULL
  AND TRIM(industry_vertical) <> ''
  AND LOWER(TRIM(industry_vertical)) <> 'nan'
GROUP BY industry_vertical
ORDER BY total_funding_records DESC;


-- Q4. CITY DISTRIBUTION
-- Which are the top 10 cities by funding record count?

SELECT
    city_location,
    COUNT(*) AS total_funding_records
FROM startup_funding
WHERE city_location IS NOT NULL
  AND TRIM(city_location) <> ''
  AND LOWER(TRIM(city_location)) <> 'nan'
GROUP BY city_location
ORDER BY total_funding_records DESC
LIMIT 10;


-- Q5. INVESTMENT TYPE DISTRIBUTION
-- How many funding records belong to each investment type?

SELECT
    investment_type,
    COUNT(*) AS total_funding_records
FROM startup_funding
WHERE investment_type IS NOT NULL
  AND TRIM(investment_type) <> ''
  AND LOWER(TRIM(investment_type)) <> 'nan'
GROUP BY investment_type
ORDER BY total_funding_records DESC;


-- Q6. VERIFY STANDARDIZED INVESTMENT TYPES
-- Review the investment type categories after cleaning.

SELECT
    investment_type,
    COUNT(*) AS total_records
FROM startup_funding
WHERE investment_type IS NOT NULL
  AND TRIM(investment_type) <> ''
  AND LOWER(TRIM(investment_type)) <> 'nan'
GROUP BY investment_type
ORDER BY total_records DESC;


-- Q7. OVERALL FUNDING SUMMARY
-- Summarize funding records and funding amounts.
-- Amounts are assumed to remain in original USD.

SELECT
    COUNT(*) AS total_funding_records,
    COUNT(DISTINCT startup_name) AS unique_startups,
    ROUND(SUM(amount_in_usd), 2) AS total_funding_usd,
    ROUND(AVG(amount_in_usd), 2) AS average_funding_usd,
    MAX(amount_in_usd) AS highest_funding_usd,
    MIN(amount_in_usd) AS lowest_funding_usd
FROM startup_funding;