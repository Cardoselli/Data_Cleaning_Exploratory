-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- there is no column of total employee so can't use very much percentage_laid_off 

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- checking where company lost all employee and had bad management 

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- check the first and last date
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- checking which industry lost 
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- checking country, united states has the most
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- total_laid_off for year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- total_laid_off for the stage 
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- substring total_laid_off for year-month
SELECT SUBSTRING(`date`,1,7) AS `YEAR-MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `YEAR-MONTH`
ORDER BY 1 ASC
;

-- cte with year_month rolling_total that sum every month the total_off to the previous rolling_total
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `YEAR-MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `YEAR-MONTH`
ORDER BY 1 ASC
)
SELECT `YEAR-MONTH`, total_off, SUM(total_off) OVER(ORDER BY`YEAR-MONTH`) AS rolling_total
FROM Rolling_Total;

-- company x year 
SELECT company, YEAR (`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR (`date`)
ORDER BY 3 DESC;

-- cte with the company who laid_off most in the year with a top 5 for every year

WITH Company_Year ( company, years, total_laid_off) AS
(
SELECT company, YEAR (`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR (`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL 
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5
;