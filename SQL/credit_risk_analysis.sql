/* =========================================================
   CREDIT RISK ANALYTICS
   MySQL Analysis for Loan Portfolio Risk
   ========================================================= */


/* =========================================================
   1. DATABASE & TABLE CREATION
   ========================================================= */

CREATE DATABASE IF NOT EXISTS credit_risk_analytics;

USE credit_risk_analytics;

CREATE TABLE loan_portfolio (
    loan_id VARCHAR(20),
    origination_date DATE,
    maturity_date DATE,
    maturity_months INT,
    sector VARCHAR(50),
    loan_type VARCHAR(50),
    collateral VARCHAR(50),
    initial_rating VARCHAR(10),
    credit_score INT,
    ead DECIMAL(15,2),
    coupon_rate DECIMAL(8,4),
    leverage DECIMAL(10,4),
    interest_coverage DECIMAL(10,4),
    debt_to_equity DECIMAL(10,4),
    pd_annual DECIMAL(10,6),
    lgd DECIMAL(10,6),
    el DECIMAL(15,2),
    unexpected_loss DECIMAL(15,2),
    rwa DECIMAL(15,2),
    defaulted INT,
    default_date VARCHAR(20),
    survival_months INT,
    recovery_rate VARCHAR(20),
    loss_given_default VARCHAR(30)
);


/* =========================================================
   2. DATA LOADING
   ========================================================= */

/*
Place loan_portfolio.csv in your local project folder
and update the path below before running.
*/

LOAD DATA LOCAL INFILE 'path/to/loan_portfolio.csv'
INTO TABLE credit_risk_analytics.loan_portfolio
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    @loan_id,
    @origination_date,
    @maturity_date,
    @maturity_months,
    @sector,
    @loan_type,
    @collateral,
    @initial_rating,
    @credit_score,
    @ead,
    @coupon_rate,
    @leverage,
    @interest_coverage,
    @debt_to_equity,
    @pd_annual,
    @lgd,
    @el,
    @unexpected_loss,
    @rwa,
    @defaulted,
    @default_date,
    @survival_months,
    @recovery_rate,
    @loss_given_default
)
SET
    loan_id = NULLIF(@loan_id, ''),
    origination_date =
        STR_TO_DATE(NULLIF(@origination_date, ''), '%Y-%m-%d'),
    maturity_date =
        STR_TO_DATE(NULLIF(@maturity_date, ''), '%Y-%m-%d'),
    maturity_months = NULLIF(@maturity_months, ''),
    sector = NULLIF(@sector, ''),
    loan_type = NULLIF(@loan_type, ''),
    collateral = NULLIF(@collateral, ''),
    initial_rating = NULLIF(@initial_rating, ''),
    credit_score = NULLIF(@credit_score, ''),
    ead = NULLIF(@ead, ''),
    coupon_rate = NULLIF(@coupon_rate, ''),
    leverage = NULLIF(@leverage, ''),
    interest_coverage = NULLIF(@interest_coverage, ''),
    debt_to_equity = NULLIF(@debt_to_equity, ''),
    pd_annual = NULLIF(@pd_annual, ''),
    lgd = NULLIF(@lgd, ''),
    el = NULLIF(@el, ''),
    unexpected_loss = NULLIF(@unexpected_loss, ''),
    rwa = NULLIF(@rwa, ''),
    defaulted = NULLIF(@defaulted, ''),
    default_date = NULLIF(@default_date, ''),
    survival_months = NULLIF(@survival_months, ''),
    recovery_rate = NULLIF(@recovery_rate, ''),
    loss_given_default = NULLIF(@loss_given_default, '');


/* =========================================================
   3. DATA VALIDATION
   ========================================================= */

-- Total loans and duplicate check

SELECT
    COUNT(*) AS total_loans,
    COUNT(DISTINCT loan_id) AS unique_loans,
    COUNT(*) - COUNT(DISTINCT loan_id) AS duplicate_loans
FROM credit_risk_analytics.loan_portfolio;


-- Credit score and exposure summary

SELECT
    MIN(credit_score) AS min_credit_score,
    MAX(credit_score) AS max_credit_score,
    AVG(credit_score) AS avg_credit_score,
    MIN(ead) AS min_ead,
    MAX(ead) AS max_ead,
    AVG(ead) AS avg_ead
FROM credit_risk_analytics.loan_portfolio;


-- Overall default rate

SELECT
    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,
    ROUND(
        SUM(defaulted) * 100.0 / COUNT(*),
        2
    ) AS default_rate_pct
FROM credit_risk_analytics.loan_portfolio;


/* =========================================================
   4. DEFAULT RATE ANALYSIS
   ========================================================= */

-- Default rate by sector

SELECT
    sector,
    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,
    ROUND(
        100.0 * SUM(defaulted) / COUNT(*),
        2
    ) AS default_rate_pct
FROM credit_risk_analytics.loan_portfolio
GROUP BY sector
ORDER BY default_rate_pct DESC;


-- Default rate by loan type

SELECT
    loan_type,
    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,
    ROUND(
        100.0 * SUM(defaulted) / COUNT(*),
        2
    ) AS default_rate_pct
FROM credit_risk_analytics.loan_portfolio
GROUP BY loan_type
ORDER BY default_rate_pct DESC;


/* =========================================================
   5. CREDIT SCORE RISK BANDS
   ========================================================= */

SELECT
    CASE
        WHEN credit_score < 600 THEN 'Very High Risk'
        WHEN credit_score < 650 THEN 'High Risk'
        WHEN credit_score < 700 THEN 'Medium Risk'
        WHEN credit_score < 750 THEN 'Low Risk'
        ELSE 'Very Low Risk'
    END AS risk_band,

    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,

    ROUND(
        100.0 * SUM(defaulted) / COUNT(*),
        2
    ) AS default_rate_pct

FROM credit_risk_analytics.loan_portfolio

GROUP BY risk_band
ORDER BY default_rate_pct DESC;


/* =========================================================
   6. SECTOR EXPOSURE & EXPECTED LOSS
   ========================================================= */

SELECT
    sector,
    COUNT(*) AS total_loans,
    ROUND(SUM(ead), 2) AS total_ead,
    ROUND(SUM(el), 2) AS total_expected_loss,
    ROUND(AVG(el), 2) AS avg_expected_loss
FROM credit_risk_analytics.loan_portfolio
GROUP BY sector
ORDER BY total_expected_loss DESC;


-- Expected loss share by sector

SELECT
    sector,
    ROUND(SUM(el), 2) AS total_expected_loss,
    ROUND(
        100.0 * SUM(el) /
        SUM(SUM(el)) OVER (),
        2
    ) AS expected_loss_share_pct
FROM credit_risk_analytics.loan_portfolio
GROUP BY sector
ORDER BY expected_loss_share_pct DESC;


/* =========================================================
   7. TOP 3 HIGH-RISK LOANS BY SECTOR
   ========================================================= */

WITH ranked_loans AS (
    SELECT
        loan_id,
        sector,
        loan_type,
        credit_score,
        ead,
        pd_annual,
        lgd,
        el AS expected_loss,
        defaulted,

        RANK() OVER (
            PARTITION BY sector
            ORDER BY el DESC
        ) AS risk_rank

    FROM credit_risk_analytics.loan_portfolio
)

SELECT *
FROM ranked_loans
WHERE risk_rank <= 3
ORDER BY sector, risk_rank;


/* =========================================================
   8. SECTOR RISK CLASSIFICATION
   ========================================================= */

WITH sector_risk AS (
    SELECT
        sector,
        COUNT(*) AS total_loans,
        SUM(defaulted) AS defaulted_loans,

        ROUND(
            100.0 * SUM(defaulted) / COUNT(*),
            2
        ) AS default_rate_pct,

        ROUND(SUM(ead), 2) AS total_ead,
        ROUND(SUM(el), 2) AS total_expected_loss

    FROM credit_risk_analytics.loan_portfolio
    GROUP BY sector
)

SELECT
    sector,
    total_loans,
    default_rate_pct,
    total_ead,
    total_expected_loss,

    CASE
        WHEN default_rate_pct >= 14.5
            THEN 'High Risk'

        WHEN default_rate_pct >= 14.0
            THEN 'Medium-High Risk'

        WHEN default_rate_pct >= 13.5
            THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS sector_risk

FROM sector_risk
ORDER BY default_rate_pct DESC;


/* =========================================================
   9. RISK BAND BY LOAN TYPE
   ========================================================= */

SELECT
    CASE
        WHEN credit_score < 600 THEN 'Very High Risk'
        WHEN credit_score < 650 THEN 'High Risk'
        WHEN credit_score < 700 THEN 'Medium Risk'
        WHEN credit_score < 750 THEN 'Low Risk'
        ELSE 'Very Low Risk'
    END AS risk_band,

    loan_type,

    COUNT(*) AS total_loans,
    SUM(defaulted) AS defaulted_loans,

    ROUND(
        100.0 * SUM(defaulted) / COUNT(*),
        2
    ) AS default_rate_pct,

    ROUND(SUM(ead), 2) AS total_ead,

    ROUND(SUM(el), 2) AS total_expected_loss

FROM credit_risk_analytics.loan_portfolio

GROUP BY risk_band, loan_type

HAVING COUNT(*) >= 100

ORDER BY total_expected_loss DESC;


/* =========================================================
   10. RISK DECILE ANALYSIS
   ========================================================= */

WITH ranked_loans AS (
    SELECT
        loan_id,
        sector,
        loan_type,
        credit_score,
        ead,
        pd_annual,
        lgd,
        el AS expected_loss,
        defaulted,

        NTILE(10) OVER (
            ORDER BY el DESC
        ) AS risk_decile

    FROM credit_risk_analytics.loan_portfolio
)

SELECT
    risk_decile,

    COUNT(*) AS total_loans,

    ROUND(
        AVG(expected_loss),
        2
    ) AS avg_expected_loss,

    ROUND(
        SUM(expected_loss),
        2
    ) AS total_expected_loss,

    ROUND(
        100.0 * SUM(defaulted) / COUNT(*),
        2
    ) AS default_rate_pct

FROM ranked_loans

GROUP BY risk_decile

ORDER BY risk_decile;


/* =========================================================
   11. LOAN-LEVEL RISK CLASSIFICATION
   ========================================================= */

SELECT
    loan_id,
    sector,
    loan_type,
    credit_score,
    pd_annual,
    lgd,
    ead,
    el AS expected_loss,
    defaulted,

    CASE

        WHEN credit_score < 600
             AND pd_annual >= 0.15
            THEN 'Critical Risk'

        WHEN credit_score < 650
             OR pd_annual >= 0.12
            THEN 'High Risk'

        WHEN credit_score < 700
             OR pd_annual >= 0.08
            THEN 'Medium Risk'

        ELSE 'Low Risk'

    END AS risk_category

FROM credit_risk_analytics.loan_portfolio;


/* =========================================================
   12. RISK CATEGORY SUMMARY
   ========================================================= */

WITH risk_classification AS (

    SELECT
        loan_id,
        credit_score,
        pd_annual,
        ead,
        el,
        defaulted,

        CASE

            WHEN credit_score < 600
                 AND pd_annual >= 0.15
                THEN 'Critical Risk'

            WHEN credit_score < 650
                 OR pd_annual >= 0.12
                THEN 'High Risk'

            WHEN credit_score < 700
                 OR pd_annual >= 0.08
                THEN 'Medium Risk'

            ELSE 'Low Risk'

        END AS risk_category

    FROM credit_risk_analytics.loan_portfolio
)

SELECT
    risk_category,

    COUNT(*) AS total_loans,

    SUM(defaulted) AS defaulted_loans,

    ROUND(
        100.0 * SUM(defaulted) / COUNT(*),
        2
    ) AS default_rate_pct,

    ROUND(SUM(ead), 2) AS total_ead,

    ROUND(SUM(el), 2) AS total_expected_loss,

    ROUND(AVG(el), 2) AS avg_expected_loss

FROM risk_classification

GROUP BY risk_category

ORDER BY total_expected_loss DESC;


/* =========================================================
   13. FINAL ANALYTICAL VIEW
   This view is used as the analytical layer for Power BI.
   ========================================================= */

CREATE OR REPLACE VIEW
credit_risk_analytics.vw_credit_risk_analysis AS

SELECT
    loan_id,
    sector,
    loan_type,
    credit_score,
    pd_annual,
    lgd,
    ead,
    el AS expected_loss,
    defaulted,

    CASE

        WHEN credit_score < 600
             AND pd_annual >= 0.15
            THEN 'Critical Risk'

        WHEN credit_score < 650
             OR pd_annual >= 0.12
            THEN 'High Risk'

        WHEN credit_score < 700
             OR pd_annual >= 0.08
            THEN 'Medium Risk'

        ELSE 'Low Risk'

    END AS risk_category

FROM credit_risk_analytics.loan_portfolio;


/* =========================================================
   14. FINAL VIEW VALIDATION
   ========================================================= */

SELECT *
FROM credit_risk_analytics.vw_credit_risk_analysis
LIMIT 10;


SELECT COUNT(*)
FROM credit_risk_analytics.vw_credit_risk_analysis;
