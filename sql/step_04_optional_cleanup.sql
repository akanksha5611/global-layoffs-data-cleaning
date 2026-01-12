/* ============================================================
   STEP 04: OPTIONAL CLEANUP & FINAL VALIDATION
   ------------------------------------------------------------
   This step performs optional structural cleanup and runs
   final validation checks to ensure data quality.
   ============================================================ */


-- 1. Remove unnecessary columns (ONLY if not required)
-- Example: if a column is not useful for analysis, it can be dropped
-- (Keep commented unless you are sure)

-- ALTER TABLE layoffs_staging
-- DROP COLUMN example_column_name;


/* ============================================================
   2. Final data sanity checks
   ------------------------------------------------------------
   These queries validate the cleaned dataset.
   ============================================================ */

-- Total row count after cleaning
SELECT COUNT(*) AS total_rows
FROM layoffs_staging;

-- Date range check
SELECT
  MIN(`date`) AS earliest_date,
  MAX(`date`) AS latest_date
FROM layoffs_staging;

-- Check for negative or invalid numeric values
SELECT *
FROM layoffs_staging
WHERE total_laid_off < 0
   OR percentage_laid_off < 0;

-- Verify percentage values are within expected range (0–100)
SELECT *
FROM layoffs_staging
WHERE percentage_laid_off > 100;


/* ============================================================
   3. Final NULL audit (read-only)
   ------------------------------------------------------------
   Confirms remaining NULL values after all cleaning steps.
   ============================================================ */

SELECT
  SUM(company IS NULL)   AS company_nulls,
  SUM(location IS NULL)  AS location_nulls,
  SUM(industry IS NULL)  AS industry_nulls,
  SUM(stage IS NULL)     AS stage_nulls,
  SUM(country IS NULL)   AS country_nulls
FROM layoffs_staging;
