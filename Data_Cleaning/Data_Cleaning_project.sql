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

-- create a new table with "copy to clipboard" adn then "create statement"
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



