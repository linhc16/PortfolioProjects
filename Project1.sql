/*
Transportation Public Financial Statistics Data Exploration and Data Cleaning
*/


SELECT * 
FROM Project1.dbo.tpfs


-- Check and update "0" data to "NUll" for consistency

SELECT value, chained_value FROM Project1.dbo.tpfs
WHERE value = 0 OR value IS NULL

UPDATE Project1.dbo.tpfs
SET value = NULL WHERE value = 0 

UPDATE Project1.dbo.tpfs
SET chained_value = NULL WHERE chained_value = 0


-- Check whether there is any duplicate data

SELECT *, ROW_NUMBER () 
OVER(
    PARTITION BY cash_flow, trust_fund, exp_type, gov_level, year, mode, value
    ORDER BY year
	)
	row_num
FROM Project1.dbo.tpfs


-- Exploring data to see trends

SELECT year, cash_flow, mode, ROUND(value,0) AS value, ROUND(chained_value,0) AS chained_value 
FROM Project1.dbo.tpfs
WHERE cash_flow = 'Expenditure'
AND trust_fund = 'Total'
AND exp_type = 'Total'
ORDER BY year, value


SELECT mode, ROUND(MAX(value),0) AS value, ROUND(MAX(chained_value),0) AS chained_value 
FROM Project1.dbo.tpfs
WHERE cash_flow = 'Expenditure'
AND trust_fund = 'Total'
AND exp_type = 'Total'
AND mode != 'Total'
GROUP BY mode
ORDER BY value DESC


SELECT year, cash_flow, mode, ROUND(value,0) AS value
FROM Project1.dbo.tpfs
WHERE mode LIKE 'Rail%'
AND cash_flow = 'Expenditure'
AND trust_fund = 'Total'
AND exp_type = 'Total'
ORDER BY year


SELECT year, cash_flow, ROUND(value,0) AS value, ROUND(chained_value,0) AS chained_value 
FROM Project1.dbo.tpfs
WHERE cash_flow = 'Transfer'
AND trust_fund = 'Total'
AND mode = 'Total'
ORDER BY year DESC


SELECT year, cash_flow, ROUND(value,0) AS value, ROUND(chained_value,0) AS chained_value 
FROM Project1.dbo.tpfs
WHERE cash_flow = 'Revenue'
AND own_supporting = 'Total'
AND mode = 'Total'
ORDER BY year;


-- Using CTE to perform calculation on revenue growth rates by year 

WITH revenue_growth_rates AS (
    SELECT year, cash_flow, mode, ROUND(value,0) AS value, ROUND(chained_value,0) AS chained_value 
	FROM Project1.dbo.tpfs
	WHERE cash_flow = 'Revenue'
	AND own_supporting = 'Total'
	AND mode = 'Total'
)
SELECT year, cash_flow, mode, value, ROUND(((value - LAG(value) OVER (ORDER BY year ASC))/LAG (value) OVER (ORDER BY year ASC))*100,2) AS revenue_growth_rates
FROM revenue_growth_rates


-- Create a table to store what data needed to focus 

DROP TABLE if exists tpfs_details
CREATE TABLE tpfs_details(
	cash_flow NVARCHAR(255),
	own_supporting NVARCHAR(255),
	user_other NVARCHAR(255),
	trust_fund NVARCHAR(255),
	exp_type NVARCHAR(255),
	gov_level NVARCHAR(255),
	description NVARCHAR(255),
	year NUMERIC,
	value FLOAT, 
	mode NVARCHAR(255),
	chained_value FLOAT,
	estimate_actual NVARCHAR(255),
	deflator FLOAT,
	gov_level_sort_order SMALLINT,
	mode_sort_order SMALLINT,
	user_other_grp NVARCHAR(255)
)

INSERT INTO tpfs_details
SELECT * 
FROM Project1.dbo.tpfs
WHERE gov_level != 'Total'
AND mode != 'Total'

SELECT * FROM tpfs_details
ORDER BY year, cash_flow

-- Delete some unused columns

ALTER TABLE tpfs_details
DROP COLUMN deflator, gov_level_sort_order, mode_sort_order, user_other_grp


GO
-- Create a view for visualization purpose

CREATE VIEW tpfs_view AS
SELECT * 
FROM Project1.dbo.tpfs
WHERE gov_level = 'Total'
AND mode != 'Total'
OR mode = 'Total'

SELECT * FROM tpfs_view
