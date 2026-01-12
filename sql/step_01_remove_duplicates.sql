/* ============================================================
   STEP 01: CREATE STAGING TABLE & REMOVE DUPLICATES
   ------------------------------------------------------------
   This step creates a staging table to safely perform data
   cleaning and removes duplicate records using ROW_NUMBER().
   Raw data remains unchanged.
   ============================================================ */


/* ============================================================
   1. CREATE STAGING TABLE
   ------------------------------------------------------------
   We work on a staging table to avoid modifying raw data.
   ============================================================ */

CREATE TABLE layoffs_staging LIKE layoffs_raw;

INSERT INTO layoffs_staging
SELECT * FROM layoffs_raw;


/* ============================================================
   2. IDENTIFY DUPLICATES (PREVIEW)
   ------------------------------------------------------------
   Rows with row_num > 1 are duplicate records.
   This query is for verification before deletion.
   ============================================================ */

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company,
                            location,
                            industry,
                            total_laid_off,
                            percentage_laid_off,
                            `date`,
                            stage,
                            country,
                            funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
) t
WHERE row_num > 1;


/* ============================================================
   3. DELETE DUPLICATES (PRIMARY METHOD – NULL SAFE)
   ------------------------------------------------------------
   Uses JOIN with NULL-safe equality (<=>) to correctly remove
   duplicates even when NULL values exist.
   ============================================================ */

DELETE ls
FROM layoffs_staging ls
JOIN (
    SELECT company,
           location,
           industry,
           total_laid_off,
           percentage_laid_off,
           `date`,
           stage,
           country,
           funds_raised_millions
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY company,
                                location,
                                industry,
                                total_laid_off,
                                percentage_laid_off,
                                `date`,
                                stage,
                                country,
                                funds_raised_millions
               ) AS row_num
        FROM layoffs_staging
    ) t
    WHERE row_num > 1
) d
ON  ls.company               <=> d.company
AND ls.location              <=> d.location
AND ls.industry              <=> d.industry
AND ls.total_laid_off        <=> d.total_laid_off
AND ls.percentage_laid_off   <=> d.percentage_laid_off
AND ls.`date`                <=> d.`date`
AND ls.stage                 <=> d.stage
AND ls.country               <=> d.country
AND ls.funds_raised_millions <=> d.funds_raised_millions;


/* ============================================================
   4. VERIFY DUPLICATES ARE REMOVED
   ------------------------------------------------------------
   This query should return ZERO rows.
   ============================================================ */

SELECT COUNT(*) AS duplicate_count
FROM (
    SELECT ROW_NUMBER() OVER (
        PARTITION BY company,
                     location,
                     industry,
                     total_laid_off,
                     percentage_laid_off,
                     `date`,
                     stage,
                     country,
                     funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
) t
WHERE row_num > 1;


/* ============================================================
   5. OPTIONAL SANITY CHECK (MANUAL VERIFICATION)
   ------------------------------------------------------------
   Used to manually verify a known edge case.
   ============================================================ */

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


/* ============================================================
   ALTERNATE METHOD (REFERENCE ONLY – NOT EXECUTED)
   ------------------------------------------------------------
   DELETE ... IN (...) approach.
   This method is NOT NULL-safe and may miss duplicates.
   Kept for learning/reference purposes only.
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
--                    PARTITION BY company,
--                                 location,
--                                 industry,
--                                 total_laid_off,
--                                 percentage_laid_off,
--                                 `date`,
--                                 stage,
--                                 country,
--                                 funds_raised_millions
--                ) AS row_num
--         FROM layoffs_staging
--     ) rt
--     WHERE row_num > 1
-- );
