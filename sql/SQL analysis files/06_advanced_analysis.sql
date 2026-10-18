-- PROJECT: STARTUP FUNDING ANALYSIS
-- FILE: 06_advanced_analysis.sql
-- LEVEL 4: ADVANCED ANALYSIS (Q16-Q20)
-- =====================================================

USE startup_funding_analysis;


-- =====================================================
-- Q16. HIGHEST-FUNDED STARTUP PER INDUSTRY
-- Include all ties for the highest individual funding.
-- =====================================================

WITH ranked_funding AS (
    SELECT
        industry_vertical,
        startup_name,
        funding_date,
        amount_in_usd,
        RANK() OVER (
            PARTITION BY industry_vertical
            ORDER BY amount_in_usd DESC
        ) AS funding_rank
    FROM startup_funding
    WHERE industry_vertical IS NOT NULL
      AND TRIM(industry_vertical) <> ''
      AND LOWER(TRIM(industry_vertical)) NOT IN ('nan', 'unknown')
      AND startup_name IS NOT NULL
      AND TRIM(startup_name) <> ''
      AND LOWER(TRIM(startup_name)) <> 'nan'
      AND amount_in_usd IS NOT NULL
)
SELECT
    industry_vertical,
    startup_name,
    funding_date,
    CONCAT(
        '$',
        FORMAT(amount_in_usd / 1000000, 2),
        ' M'
    ) AS highest_funding_usd_millions
FROM ranked_funding
WHERE funding_rank = 1
ORDER BY amount_in_usd DESC;


-- =====================================================
-- Q17. RANK CITIES BY TOTAL FUNDING
-- DENSE_RANK assigns consecutive ranks when values tie.
-- =====================================================

WITH city_funding AS (
    SELECT
        TRIM(city_location) AS city,
        SUM(amount_in_usd) AS total_funding
    FROM startup_funding
    WHERE city_location IS NOT NULL
      AND TRIM(city_location) <> ''
      AND LOWER(TRIM(city_location)) NOT IN ('nan', 'unknown')
      AND amount_in_usd IS NOT NULL
    GROUP BY TRIM(city_location)
),
ranked_cities AS (
    SELECT
        city,
        total_funding,
        DENSE_RANK() OVER (
            ORDER BY total_funding DESC
        ) AS funding_rank
    FROM city_funding
)
SELECT
    funding_rank,
    city,
    CONCAT(
        '$',
        FORMAT(total_funding / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions
FROM ranked_cities
ORDER BY funding_rank, city;


-- =====================================================
-- Q18. INDUSTRY FUNDING CONTRIBUTION
-- Calculate each industry's share of eligible funding.
-- =====================================================

SELECT
    industry_vertical,
    CONCAT(
        '$',
        FORMAT(SUM(amount_in_usd) / 1000000, 2),
        ' M'
    ) AS industry_funding_usd_millions,
    CONCAT(
        FORMAT(
            100.0 * SUM(amount_in_usd) /
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
    ) AS contribution_percentage
FROM startup_funding
WHERE industry_vertical IS NOT NULL
  AND TRIM(industry_vertical) <> ''
  AND LOWER(TRIM(industry_vertical)) NOT IN ('nan', 'unknown')
  AND amount_in_usd IS NOT NULL
GROUP BY industry_vertical
ORDER BY SUM(amount_in_usd) DESC;


-- =====================================================
-- Q19. YEAR-OVER-YEAR FUNDING GROWTH
-- Calculate absolute and percentage changes by year.
-- =====================================================

WITH yearly_funding AS (
    SELECT
        YEAR(funding_date) AS funding_year,
        SUM(amount_in_usd) AS total_funding
    FROM startup_funding
    WHERE funding_date IS NOT NULL
      AND amount_in_usd IS NOT NULL
    GROUP BY YEAR(funding_date)
),
funding_growth AS (
    SELECT
        funding_year,
        total_funding,
        LAG(total_funding) OVER (
            ORDER BY funding_year
        ) AS previous_year_funding
    FROM yearly_funding
)
SELECT
    funding_year,
    CONCAT(
        '$',
        FORMAT(total_funding / 1000000, 2),
        ' M'
    ) AS total_funding_usd_millions,
    CASE
        WHEN previous_year_funding IS NULL THEN 'N/A'
        ELSE CONCAT(
            '$',
            FORMAT(
                (total_funding - previous_year_funding) / 1000000,
                2
            ),
            ' M'
        )
    END AS absolute_change_usd_millions,
    CASE
        WHEN previous_year_funding IS NULL
          OR previous_year_funding = 0
        THEN 'N/A'
        ELSE CONCAT(
            FORMAT(
                100.0 * (total_funding - previous_year_funding)
                / ABS(previous_year_funding),
                2
            ),
            '%'
        )
    END AS percentage_change
FROM funding_growth
ORDER BY funding_year;


-- =====================================================
-- Q20. DATA QUALITY AUDIT
-- Count missing values and duplicate full-record groups.
-- =====================================================

SELECT
    'Missing startup names' AS audit_check,
    COUNT(*) AS affected_records
FROM startup_funding
WHERE startup_name IS NULL
   OR TRIM(startup_name) = ''
   OR LOWER(TRIM(startup_name)) = 'nan'

UNION ALL

SELECT
    'Missing funding dates',
    COUNT(*)
FROM startup_funding
WHERE funding_date IS NULL

UNION ALL

SELECT
    'Missing funding amounts',
    COUNT(*)
FROM startup_funding
WHERE amount_in_usd IS NULL

UNION ALL

SELECT
    'Missing industry labels',
    COUNT(*)
FROM startup_funding
WHERE industry_vertical IS NULL
   OR TRIM(industry_vertical) = ''
   OR LOWER(TRIM(industry_vertical)) IN ('nan', 'unknown')

UNION ALL

SELECT
    'Missing city labels',
    COUNT(*)
FROM startup_funding
WHERE city_location IS NULL
   OR TRIM(city_location) = ''
   OR LOWER(TRIM(city_location)) IN ('nan', 'unknown')

UNION ALL

SELECT
    'Duplicate full-record groups',
    COUNT(*)
FROM (
    SELECT
        funding_date,
        startup_name,
        industry_vertical,
        sub_vertical,
        city_location,
        investors_name,
        investment_type,
        amount_in_usd,
        remarks
    FROM startup_funding
    GROUP BY
        funding_date,
        startup_name,
        industry_vertical,
        sub_vertical,
        city_location,
        investors_name,
        investment_type,
        amount_in_usd,
        remarks
    HAVING COUNT(*) > 1
) AS duplicate_groups;