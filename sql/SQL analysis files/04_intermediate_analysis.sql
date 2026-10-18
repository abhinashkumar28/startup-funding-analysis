-- PROJECT: STARTUP FUNDING ANALYSIS
-- FILE: 04_intermediate_analysis.sql
-- LEVEL 2: FUNDING INSIGHTS (Q6-Q10)
-- =====================================================

USE startup_funding_analysis;


-- =====================================================
-- Q6. TOTAL FUNDING AMOUNT
-- Business Question:
-- What is the total recorded funding amount?
-- =====================================================

SELECT
    CONCAT(
        '$',
        FORMAT(SUM(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions
FROM startup_funding
WHERE amount_in_usd IS NOT NULL;


-- =====================================================
-- Q7. AVERAGE FUNDING BY INDUSTRY
-- Business Question:
-- Which industries have the highest average funding?
-- =====================================================

SELECT
    industry_vertical,
    COUNT(*) AS total_funding_records,
    CONCAT(
        '$',
        FORMAT(AVG(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS average_funding_usd_millions
FROM startup_funding
WHERE industry_vertical IS NOT NULL
  AND TRIM(industry_vertical) <> ''
  AND LOWER(TRIM(industry_vertical)) NOT IN ('nan', 'unknown')
  AND amount_in_usd IS NOT NULL
GROUP BY industry_vertical
ORDER BY AVG(amount_in_usd) DESC;


-- =====================================================
-- Q8. TOP 10 FUNDED STARTUPS
-- Business Question:
-- Which startups have the highest total recorded funding?
-- =====================================================

SELECT
    startup_name,
    COUNT(*) AS total_funding_records,
    CONCAT(
        '$',
        FORMAT(SUM(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions
FROM startup_funding
WHERE startup_name IS NOT NULL
  AND TRIM(startup_name) <> ''
  AND LOWER(TRIM(startup_name)) <> 'nan'
  AND amount_in_usd IS NOT NULL
GROUP BY startup_name
ORDER BY SUM(amount_in_usd) DESC
LIMIT 10;


-- =====================================================
-- Q9. FUNDING BY CITY
-- Business Question:
-- Which 10 cities have the highest total funding?
-- =====================================================

SELECT
    city_location,
    COUNT(*) AS total_funding_records,
    CONCAT(
        '$',
        FORMAT(SUM(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions
FROM startup_funding
WHERE city_location IS NOT NULL
  AND TRIM(city_location) <> ''
  AND LOWER(TRIM(city_location)) NOT IN ('nan', 'unknown')
  AND amount_in_usd IS NOT NULL
GROUP BY city_location
ORDER BY SUM(amount_in_usd) DESC
LIMIT 10;


-- =====================================================
-- Q10. INVESTMENT STAGE ANALYSIS
-- Business Question:
-- Which investment types have the highest funding?
-- =====================================================

SELECT
    investment_type,
    COUNT(*) AS total_funding_records,
    CONCAT(
        '$',
        FORMAT(SUM(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions,
    CONCAT(
        '$',
        FORMAT(AVG(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS average_funding_usd_millions
FROM startup_funding
WHERE investment_type IS NOT NULL
  AND TRIM(investment_type) <> ''
  AND LOWER(TRIM(investment_type)) <> 'nan'
  AND amount_in_usd IS NOT NULL
GROUP BY investment_type
ORDER BY SUM(amount_in_usd) DESC;