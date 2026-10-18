-- =====================================================
-- PROJECT: STARTUP FUNDING ANALYSIS
-- FILE: 02_data_quality_checks.sql
-- PURPOSE: DATA QUALITY VALIDATION
-- =====================================================

USE startup_funding_analysis;


-- =====================================================
-- 1. CHECK MISSING VALUES
-- Includes NULL, empty strings, and 'nan' labels.
-- =====================================================

SELECT
    SUM(sr_no IS NULL) AS missing_sr_no,

    SUM(funding_date IS NULL) AS missing_funding_date,

    SUM(
        startup_name IS NULL
        OR TRIM(startup_name) = ''
    ) AS missing_startup_name,

    SUM(
        industry_vertical IS NULL
        OR TRIM(industry_vertical) = ''
        OR LOWER(TRIM(industry_vertical)) = 'nan'
    ) AS missing_industry,

    SUM(
        sub_vertical IS NULL
        OR TRIM(sub_vertical) = ''
        OR LOWER(TRIM(sub_vertical)) = 'nan'
    ) AS missing_sub_vertical,

    SUM(
        city_location IS NULL
        OR TRIM(city_location) = ''
        OR LOWER(TRIM(city_location)) = 'nan'
    ) AS missing_city,

    SUM(
        investors_name IS NULL
        OR TRIM(investors_name) = ''
        OR LOWER(TRIM(investors_name)) = 'nan'
    ) AS missing_investors,

    SUM(
        investment_type IS NULL
        OR TRIM(investment_type) = ''
        OR LOWER(TRIM(investment_type)) = 'nan'
    ) AS missing_investment_type,

    SUM(amount_in_usd IS NULL) AS missing_amount,

    SUM(
        remarks IS NULL
        OR TRIM(remarks) = ''
    ) AS missing_remarks

FROM startup_funding;


-- =====================================================
-- 2. CHECK DUPLICATE RECORD IDs
-- =====================================================

SELECT
    sr_no,
    COUNT(*) AS duplicate_count
FROM startup_funding
GROUP BY sr_no
HAVING COUNT(*) > 1;


-- =====================================================
-- 3. CHECK DUPLICATE FULL RECORDS
-- =====================================================

SELECT
    COUNT(*) AS duplicate_record_groups
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
) AS duplicates;


-- =====================================================
-- 4. CHECK FUNDING DATE RANGE
-- =====================================================

SELECT
    MIN(funding_date) AS earliest_funding_date,
    MAX(funding_date) AS latest_funding_date
FROM startup_funding;


-- =====================================================
-- 5. CHECK FUNDING AMOUNTS
-- =====================================================

SELECT
    MIN(amount_in_usd) AS minimum_funding,
    MAX(amount_in_usd) AS maximum_funding,
    ROUND(AVG(amount_in_usd), 2) AS average_funding,
    SUM(amount_in_usd) AS total_funding,
    SUM(amount_in_usd < 0) AS negative_amounts,
    SUM(amount_in_usd = 0) AS zero_funding_records
FROM startup_funding;


-- =====================================================
-- 6. REVIEW ZERO OR NEGATIVE FUNDING RECORDS
-- =====================================================

SELECT
    sr_no,
    funding_date,
    startup_name,
    amount_in_usd,
    remarks
FROM startup_funding
WHERE amount_in_usd <= 0
ORDER BY amount_in_usd;


-- =====================================================
-- 7. VERIFY MISSING DATE COUNT
-- =====================================================

SELECT
    COUNT(*) AS total_records,
    COUNT(funding_date) AS records_with_dates,
    SUM(funding_date IS NULL) AS missing_dates
FROM startup_funding;