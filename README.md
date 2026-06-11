# Tech Layoffs: Advanced Data Cleaning & Exploratory Data Analysis (EDA) in MySQL

This repository contains a comprehensive data engineering and data analysis project focused on global tech industry layoffs from 2020 onward. The project is structured into two sequential SQL scripts: the first dedicated to deep raw data transformation and cleaning, and the second focused on extracting business metrics and historical trends.

## Tech Stack
* **Database Engine**: MySQL v8.0.45 (Ubuntu 24.04 LTS)
* **Dialect**: MySQL SQL
* **Key Functions & Constructs**: CTE (Common Table Expressions), Window Functions (ROW_NUMBER, DENSE_RANK), Self-Join, Data Staging Workflow, Data Type Casting, String Manipulation.

---

## Phase 1: Data Cleaning Pipeline (data_cleaning.sql)

The raw data (layoffs.csv) contained structural anomalies, duplicates, and inconsistent formats. To preserve the original data integrity, a staging workflow was implemented across 4 main steps:

### 1. Duplicate Removal (Bypassing MySQL Limitations)
Since MySQL does not allow a direct DELETE statement on a CTE based on Window Functions, this limitation was bypassed using an advanced staging strategy:
* Unique row combinations were evaluated using ROW_NUMBER() OVER (PARTITION BY ...) across all columns in the dataset.
* A secondary target table (layoffs_staging2) was created to physically store the row_num column.
* All records with row_num > 1 were isolated and permanently deleted.

### 2. Data Standardization and Normalization
* **Textual Anomalies**: Applied TRIM() to the company column to remove leading and trailing white spaces.
* **Categorical Discrepancies**: Normalized variations within the industry column (e.g., unifying 'Crypto', 'Crypto Currency', and 'CryptoCurrency' under a single standard 'Crypto').
* **Geographical Typos**: Corrected a data-entry error for the United States (transforming 'United States.' to 'United States' using the LIKE operator).
* **Data Type Casting**: The date column, originally stored as TEXT, was converted into a real temporal object using the STR_TO_DATE() function. The table structure was then updated via ALTER TABLE ... MODIFY COLUMN ... DATE.

### 3. Handling Missing Values (Nulls & Blanks)
* Identified records with empty strings ('') in the industry column.
* Converted empty fields to NULL to standardize missing data management.
* Reconstructed missing data using a logical Self-Join: matching rows with null values against populated rows from the same company (e.g., recovering the 'Travel' industry for missing Airbnb records).

### 4. Structural Optimization
* Removed rows completely lacking analytical value, specifically those containing NULL in both total_laid_off and percentage_laid_off simultaneously.
* Dropped the row_num utility column using ALTER TABLE ... DROP COLUMN to leave the final dataset clean and optimized.

---

## Phase 2: Exploratory Data Analysis (eda.sql)

An exploratory data analysis was conducted on the cleaned dataset to map the macroeconomic trends of the tech sector crisis.

### Trend and Volume Analysis
* **Peak Analysis**: Identified records with a 100% layoff rate (percentage_laid_off = 1) ordered by funds raised, highlighting the most heavily capitalized failed startups.
* **Macro Aggregations**: Calculated total layoff volumes aggregated by Company, Industry, Country, and Funding Stage.

### Advanced Queries and Progressive Analysis
* **Time Series Analysis with Rolling Total**: Extracted historical year-month trends using string manipulation (SUBSTRING(date,1,7)). A CTE was implemented to calculate the cumulative progressive total (Rolling Total) of layoffs over time using the SUM() OVER (ORDER BY ...) aggregation function.
* **Complex Annual Rankings (Top 5)**: Developed a nested structure using dual combined CTEs. Leveraging the Window Function DENSE_RANK() OVER (PARTITION BY YEAR(date) ORDER BY SUM(total_laid_off) DESC), the query isolates and returns only the top 5 companies with the highest number of layoffs for each individual year, accurately handling any potential ties.

---
