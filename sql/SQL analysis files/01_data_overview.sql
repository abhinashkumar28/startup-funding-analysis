-- ============================================
-- STARTUP FUNDING ANALYSIS
-- DATA OVERVIEW
-- ============================================

USE startup_funding_analysis;

-- 1. Inspect table structure
DESCRIBE startup_funding;

-- 2. Count total funding records
SELECT COUNT(*) AS total_records
FROM startup_funding;

-- 3. Identify funding date range
SELECT
    MIN(funding_date) AS earliest_funding_date,
    MAX(funding_date) AS latest_funding_date
FROM startup_funding;

-- 4. Summarize funding amounts
SELECT
    MIN(amount_in_usd) AS minimum_funding,
    MAX(amount_in_usd) AS maximum_funding,
    AVG(amount_in_usd) AS average_funding
FROM startup_funding;

-- 5. Check missing critical values
SELECT
    SUM(startup_name IS NULL OR TRIM(startup_name) = '')
        AS missing_startup_names,
    SUM(funding_date IS NULL)
        AS missing_dates,
    SUM(amount_in_usd IS NULL)
        AS missing_amounts
FROM startup_funding;