-- Data Cleaning

SELECT * 
FROM layoffs_staging;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. NULL Values or blank values
-- 4. Remove any Columns
-- ---------------------------------START---------------------------------------------------------------------------------------------------------
-- Create a copy of the original so we can chill and do what we want on it
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;
-- -- -- -- -- -- - -- -- -- -- -- -- -- -- -- - - -- -- -- -
-- 1. Remove Duplicates

SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;
-- checking if it's a real duplicate
SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';
-- we would love to do this like in other sql but in mysql it doesn't work
WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- create a new table with "copy to clipboard" and then "create statement"
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- tablet is empty
SELECT *
FROM layoffs_staging2;
-- just do an instert into 
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;
-- check
SELECT *
FROM layoffs_staging2
WHERE row_num >1;
-- deleting duplicates
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;
-- ---------------------------------------------------------------------
-- 2. Standardize the Data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Crypto /  Crypto Currency/ CryptoCurrency are doubles

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- update all to Crypto
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry like 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- United States / United States. copy error with a dot after the country
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country like 'United States%';

-- date is in text format, not good need to change---- STR_TO_DATE change the format
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');
-- change the date format from text to date

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
-- -----------------------------------------------------------------
-- 3. NULL Values or blank values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT DISTINCT industry
FROM layoffs_staging2;
-- missing value and a null


SELECT *
FROM layoffs_staging2
WHERE industry IS NULl
OR Industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'AirBnb';

-- checked the industry column in aribnnb it has Travel so we can update

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL;

-- to see in what industry are the blank ones

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';
-- modify  all blank industry to null so it's easy to manage

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Bally's Iteractive has null on industry and it is the only one
-- total_laid_off   percentace_laid_off funds  funds_raised_millions has some null and can't adjust it

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- can we delete the columns of the nulls?

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- don't need anymore the row_num delete the total column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


