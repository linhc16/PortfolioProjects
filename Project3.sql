SELECT * FROM `carvana`;

-- Create a new table for deleting duplicate data purpose
CREATE TABLE `carnava2` (
		`Name` TEXT,
        `Year` INT,
        `Miles` INT,
        `Price` INT,
        `row_num` INT
);

INSERT INTO `carnava2`
SELECT *, ROW_NUMBER () OVER(
		PARTITION BY `Name`, `Year`, `Miles`, `Price`
        ORDER BY Name) AS `row_num`
FROM `carvana`
WHERE `Year` >=  2000 AND `Year`  <=  2030 ;

-- Check for duplicates
SELECT * FROM `carnava2`
WHERE `row_num`  > 1;

-- Remove duplicates
DELETE FROM `carnava2`
WHERE `row_num`  > 1;

-- Check for any missing values
SELECT * FROM `carnava2`
WHERE `Name` IS NULL
OR `Year` IS NULL
OR `Miles` IS NULL
OR `Price` IS NULL;

-- Standardize data
UPDATE `carnava2` SET `Name` = upper(`Name`);

-- Delete unused column
ALTER TABLE `carnava2`
DROP COLUMN `row_num`;

SELECT * FROM `carnava2`;