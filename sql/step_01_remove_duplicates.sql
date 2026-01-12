/* ============================================================
   DATA CLEANING PROCESS
   ------------------------------------------------------------
   This script performs data cleaning on the layoffs dataset
   using a staging table. The raw data remains unchanged.
   ============================================================ */

-- 1. Remove duplicate records
--    Identify and delete exact duplicates using ROW_NUMBER()

-- 2. Standardize data
--    Clean and normalize text fields (company, industry, country, stage)

-- 3. Handle NULL and blank values
--    Convert blanks to NULLs and standardize missing categorical values

-- 4. Remove unnecessary columns (if required)
--    Drop columns that are not needed for analysis

SELECT * FROM layoffs;

-- Create a staging table to perform data cleaning.
-- Raw data remains unchanged to preserve data integrity.

CREATE TABLE layoffs_staging LIKE layoffs_raw;

INSERT INTO layoffs_staging
SELECT * FROM layoffs_raw;

SELECT * FROM layoffs_staging;

/* ============================================================
   STEP 1: IDENTIFY DUPLICATES 
   ------------------------------------------------------------
   Use ROW_NUMBER() to identify duplicate records.
   Rows with row_num > 1 are duplicates.
   ============================================================ */

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off,
                            percentage_laid_off, `date`, stage,
                            country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
) t
WHERE row_num > 1;


/* ============================================================
   STEP 2: DELETE DUPLICATES (PRIMARY METHOD – NULL SAFE)
   ------------------------------------------------------------
   This DELETE uses a JOIN with NULL-safe equality (<=>)
   to correctly remove duplicates even when NULL values exist.
   This is the recommended and production-safe approach.
   ============================================================ */

DELETE ls
FROM layoffs_staging ls
JOIN (
    SELECT company, location, industry, total_laid_off,
           percentage_laid_off, `date`, stage,
           country, funds_raised_millions
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY company, location, industry, total_laid_off,
                                percentage_laid_off, `date`, stage,
                                country, funds_raised_millions
               ) AS row_num
        FROM layoffs_staging
    ) t
    WHERE row_num > 1
) d
ON ls.company <=> d.company
AND ls.location <=> d.location
AND ls.industry <=> d.industry
AND ls.total_laid_off <=> d.total_laid_off
AND ls.percentage_laid_off <=> d.percentage_laid_off
AND ls.`date` <=> d.`date`
AND ls.stage <=> d.stage
AND ls.country <=> d.country
AND ls.funds_raised_millions <=> d.funds_raised_millions;


/* ============================================================
   STEP 3: VERIFY DUPLICATES ARE REMOVED
   ------------------------------------------------------------
   After deletion, this query should return ZERO rows.
   ============================================================ */

SELECT COUNT(*) AS duplicate_count
FROM (
    SELECT ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off,
                     percentage_laid_off, `date`, stage,
                     country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
) t
WHERE row_num > 1;


/* ============================================================
   STEP 4: SANITY CHECK FOR A KNOWN CASE (OPTIONAL)
   ------------------------------------------------------------
   Used to manually verify a specific record.
   ============================================================ */

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


/* ============================================================
   ALTERNATE METHOD (NOT USED – FOR REFERENCE ONLY)
   ------------------------------------------------------------
   This approach uses DELETE ... IN (...) with ROW_NUMBER().
   It DOES NOT handle NULL values correctly and may miss
   duplicate rows. Kept here only for learning/reference.
   ============================================================ */

-- DELETE FROM layoffs_staging
-- WHERE (company, location, industry, total_laid_off,
--        percentage_laid_off, `date`, stage,
--        country, funds_raised_millions) IN (
--     SELECT company, location, industry, total_laid_off,
--            percentage_laid_off, `date`, stage,
--            country, funds_raised_millions
--     FROM (
--         SELECT *,
--                ROW_NUMBER() OVER (
--                    PARTITION BY company, location, industry,
--                                 total_laid_off, percentage_laid_off,
--                                 `date`, stage, country,
--                                 funds_raised_millions
--                ) AS row_num
--         FROM layoffs_staging
--     ) rt
--     WHERE row_num > 1
-- );


/* ============================================================
   ALTERNATE VALIDATION METHOD (OPTIONAL)
   ------------------------------------------------------------
   GROUP BY + HAVING COUNT(*) > 1
   Useful for understanding duplicates but not ideal for
   deletion when NULL values are involved.
   ============================================================ */

-- SELECT company, location, industry, total_laid_off,
--        percentage_laid_off, `date`, stage,
--        country, funds_raised_millions,
--        COUNT(*) AS cnt
-- FROM layoffs_staging
-- GROUP BY company, location, industry, total_laid_off,
--          percentage_laid_off, `date`, stage,
--          country, funds_raised_millions
-- HAVING COUNT(*) > 1;













