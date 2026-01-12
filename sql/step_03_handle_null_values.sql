/* ============================================================
   STEP 03: HANDLE NULL / MISSING VALUES
   ------------------------------------------------------------
   This step handles missing data by standardizing NULLs,
   propagating known values where appropriate, and removing
   records that are not useful for analysis.
   ============================================================ */


-- 1. Convert blank strings to NULL
UPDATE layoffs_staging
SET company  = NULLIF(company, ''),
    location = NULLIF(location, ''),
    industry = NULLIF(industry, ''),
    stage    = NULLIF(stage, ''),
    country  = NULLIF(country, '');


/* ============================================================
   2. Populate missing industry using known company values
   ------------------------------------------------------------
   Uses self-join on company to infer industry where possible.
   ============================================================ */

-- Preview rows where industry can be populated (validation)
-- SELECT *
-- FROM layoffs_staging t1
-- JOIN layoffs_staging t2
--   ON t1.company = t2.company
-- WHERE t1.industry IS NULL
--   AND t2.industry IS NOT NULL;

UPDATE layoffs_staging t1
JOIN layoffs_staging t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


/* ============================================================
   3. Remove records with no layoff information
   ------------------------------------------------------------
   Rows with both total_laid_off and percentage_laid_off NULL
   do not contribute to analysis.
   ============================================================ */

DELETE
FROM layoffs_staging
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


/* ============================================================
   4. NULL audit (validation only)
   ------------------------------------------------------------
   Use this query to review remaining NULL values.
   ============================================================ */

-- SELECT
--   SUM(company IS NULL)   AS company_nulls,
--   SUM(location IS NULL)  AS location_nulls,
--   SUM(industry IS NULL)  AS industry_nulls,
--   SUM(stage IS NULL)     AS stage_nulls,
--   SUM(country IS NULL)   AS country_nulls
-- FROM layoffs_staging;
