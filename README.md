Data Cleaning Process

This project performs data cleaning on the layoffs dataset using a staging table.
The raw data remains unchanged to preserve data integrity.

The cleaning workflow is organized into the following steps:

1. Remove duplicate records
   Identify and remove exact duplicate rows using window functions.

2. Standardize data
   Clean and normalize text fields such as company, industry, country, and stage
   to ensure consistency.

3. Handle NULL and blank values
   Convert blank values to NULL and standardize missing categorical data.

4. Remove unnecessary columns (if required)
   Drop columns that are not needed for analysis or reporting.

Each step is implemented in a separate SQL file for clarity and maintainability.
