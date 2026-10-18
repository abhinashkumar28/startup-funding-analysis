-- PROJECT: STARTUP FUNDING ANALYSIS
-- FILE: 05_business_insights.sql
-- LEVEL 3: BUSINESS INSIGHTS (Q11-Q15)
-- =====================================================

USE startup_funding_analysis;


-- =====================================================
-- Q11. YEAR-WISE FUNDING TREND
-- How does funding change across years?
-- =====================================================

SELECT
    YEAR(funding_date) AS funding_year,
    COUNT(*) AS total_funding_records,
    CONCAT(
        '$',
        FORMAT(SUM(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions
FROM startup_funding
WHERE funding_date IS NOT NULL
  AND amount_in_usd IS NOT NULL
GROUP BY YEAR(funding_date)
ORDER BY SUM(amount_in_usd) DESC;


-- =====================================================
-- Q12. MONTHLY FUNDING TREND
-- Compare funding across calendar months.
-- January across all years is grouped together.
-- =====================================================

SELECT
    MONTH(funding_date) AS month_number,
    MONTHNAME(funding_date) AS month_name,
    COUNT(*) AS total_funding_records,
    CONCAT(
        '$',
        FORMAT(SUM(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions
FROM startup_funding
WHERE funding_date IS NOT NULL
  AND amount_in_usd IS NOT NULL
GROUP BY
    MONTH(funding_date),
    MONTHNAME(funding_date)
ORDER BY SUM(amount_in_usd) DESC;


-- =====================================================
-- Q13. MOST ACTIVE INVESTORS
-- Find the top 10 most frequently recorded investors.
-- =====================================================

SELECT
    TRIM(investors_name) AS investor_name,
    COUNT(*) AS total_funding_records
FROM startup_funding
WHERE investors_name IS NOT NULL
  AND TRIM(investors_name) <> ''
  AND LOWER(TRIM(investors_name)) <> 'nan'
GROUP BY TRIM(investors_name)
ORDER BY total_funding_records DESC
LIMIT 10;


-- =====================================================
-- Q14. INDUSTRY FUNDING CONTRIBUTION
-- Calculate total funding and percentage share by industry.
-- =====================================================

SELECT
    industry_vertical,
    CONCAT(
        '$',
        FORMAT(SUM(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions,
    CONCAT(
        FORMAT(
            SUM(amount_in_usd) * 100.0 /
            (
                SELECT SUM(amount_in_usd)
                FROM startup_funding
                WHERE industry_vertical IS NOT NULL
                  AND TRIM(industry_vertical) <> ''
                  AND LOWER(TRIM(industry_vertical))
                      NOT IN ('nan', 'unknown')
                  AND amount_in_usd IS NOT NULL
            ),
            2
        ),
        '%'
    ) AS funding_share_percentage
FROM startup_funding
WHERE industry_vertical IS NOT NULL
  AND TRIM(industry_vertical) <> ''
  AND LOWER(TRIM(industry_vertical)) NOT IN ('nan', 'unknown')
  AND amount_in_usd IS NOT NULL
GROUP BY industry_vertical
ORDER BY SUM(amount_in_usd) DESC;


-- =====================================================
-- Q15. ABOVE-AVERAGE FUNDING ROUNDS
-- Find funding records above the overall average.
-- =====================================================

SELECT
    sr_no,
    funding_date,
    startup_name,
    industry_vertical,
    investors_name,
    investment_type,
    CONCAT(
        '$',
        FORMAT(amount_in_usd / 1000000, 2),
        ' M'
    ) AS funding_amount_usd_millions
FROM startup_funding
WHERE amount_in_usd IS NOT NULL
  AND amount_in_usd > (
      SELECT AVG(amount_in_usd)
      FROM startup_funding
      WHERE amount_in_usd IS NOT NULL
  )
ORDER BY amount_in_usd DESC;