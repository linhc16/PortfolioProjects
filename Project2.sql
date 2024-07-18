/*
Global Suicide Rates Data Exploration and Data Cleaning
*/


SELECT * FROM Project2.dbo.suicide_rates 

-- Check whether there is any duplicate data

SELECT *, ROW_NUMBER() OVER(
	PARTITION BY country, year, sex, age
	ORDER BY country
	) row_num
FROM Project2.dbo.suicide_rates


-- Exploring data

SELECT DISTINCT age FROM Project2.dbo.suicide_rates
ORDER BY age ASC

	
SELECT year, SUM(suicides_no) AS suicide_no
FROM Project2.dbo.suicide_rates
WHERE year != 2016
GROUP BY year
ORDER BY year


SELECT year, sex, ROUND((SUM(suicides_no)/SUM(population) * 100000), 2) AS suicides_per_100k
FROM Project2.dbo.suicide_rates
WHERE year != 2016
GROUP BY year, sex
ORDER BY year, sex


SELECT year, sex, age, ROUND((SUM(suicides_no)/SUM(population) * 100000), 2) AS suicides_per_100k
FROM Project2.dbo.suicide_rates
WHERE year != 2016
GROUP BY year, sex, age
ORDER BY year, sex, age


SELECT * FROM Project2.dbo.countries_by_continent 
ORDER BY country


SELECT * FROM Project2.dbo.suicide_rates 
LEFT JOIN Project2.dbo.countries_by_continent 
ON suicide_rates.country = countries_by_continent.country 
ORDER BY suicide_rates.country, year, sex, age


-- Using CTE to join two seperate tables and select some features from there

WITH suicide_rates_CTE AS (
	SELECT suicide_rates.country, year, sex, age, suicides_no, population, [suicides/100k pop], [ gdp_for_year ($) ],[gdp_per_capita ($)],continent
	FROM Project2.dbo.suicide_rates
	LEFT JOIN Project2.dbo.countries_by_continent 
	ON suicide_rates.country = countries_by_continent.country 
)
SELECT * FROM suicide_rates_CTE
ORDER BY country, year, sex, age


GO
DROP VIEW IF EXISTS #suicide_rates_view

-- Create a view to store data needed to focus
	
GO
CREATE VIEW suicide_rates_view AS 
SELECT suicide_rates.country, year, sex, age, suicides_no, population, [suicides/100k pop], [ gdp_for_year ($) ],[gdp_per_capita ($)],continent
FROM Project2.dbo.suicide_rates
LEFT JOIN Project2.dbo.countries_by_continent 
ON suicide_rates.country = countries_by_continent.country 
WHERE year != 2016
 
-- Using aggregate functions to perform calculation 
	
GO
SELECT * FROM suicide_rates_view


SELECT year, age, continent, ROUND((SUM(suicides_no)/SUM(population) * 100000), 2) AS suicides_per_100k
FROM suicide_rates_view
WHERE year != 2016
GROUP BY year, age, continent
ORDER BY year, age, continent


SELECT country, continent, ROUND((SUM(suicides_no)/SUM(population) * 100000), 2) AS suicides_per_100k
FROM suicide_rates_view
WHERE year != 2016
GROUP BY country, continent 
ORDER BY suicides_per_100k DESC
OFFSET 0 ROWS
FETCH NEXT 20 ROWS ONLY


SELECT year, continent, ROUND((SUM(suicides_no)/SUM(population) * 100000), 2) AS suicides_per_100k, ROUND((SUM([ gdp_for_year ($) ])/SUM(population)), 2) AS [gdp_per_capita ($)]
FROM suicide_rates_view
WHERE year != 2016
GROUP BY year, continent
ORDER BY suicides_per_100k, [gdp_per_capita ($)]


SELECT year, continent, SUM(suicides_no) AS suicides_no, SUM([ gdp_for_year ($) ]) AS [gdp_for_year ($)]
FROM suicide_rates_view
WHERE year != 2016
GROUP BY year, continent
ORDER BY suicides_no, [gdp_for_year ($)]


