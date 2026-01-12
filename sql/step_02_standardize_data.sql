/* ============================================================
   STEP 02: STANDARDIZE DATA
   ------------------------------------------------------------
   This step standardizes text-based columns, normalizes
   categorical values, converts percentages, and fixes
   date formats for consistency.
   ============================================================ */


-- 1. Trim leading and trailing spaces from text columns
UPDATE layoffs_staging
SET company  = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    country  = TRIM(country),
    stage    = TRIM(stage);


-- 2. Standardize industry naming
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';


-- 3. Standardize percentage values
-- Convert decimal format (e.g., 0.12 → 12.00)
-- Applied only when value is <= 1 to avoid double conversion
UPDATE layoffs_staging
SET percentage_laid_off = ROUND(percentage_laid_off * 100, 2)
WHERE percentage_laid_off IS NOT NULL
  AND percentage_laid_off <= 1;


/* ============================================================
   DATE STANDARDIZATION
   ------------------------------------------------------------
   Convert date column from text to proper DATE format.
   Assumes original format: MM/DD/YYYY
   ============================================================ */

-- 4. Convert date strings to DATE
UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` IS NOT NULL;


-- 5. Change column data type to DATE
ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;
