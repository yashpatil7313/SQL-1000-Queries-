-- Day 37: Date & Time Case Study
-- Queries: Q361 to Q370
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, join_date, salary)

-- =========================================
-- Q361: Display employees who joined today
-- =========================================
SELECT *
FROM employee
WHERE join_date = CURRENT_DATE;

-- =========================================
-- Q362: Display employees who joined in the last 30 days
-- =========================================
SELECT *
FROM employee
WHERE join_date >= CURRENT_DATE - INTERVAL 30 DAY;

-- =========================================
-- Q363: Display employees who joined this year
-- =========================================
SELECT *
FROM employee
WHERE YEAR(join_date) = YEAR(CURRENT_DATE);

-- =========================================
-- Q364: Display employees who joined this month
-- =========================================
SELECT *
FROM employee
WHERE YEAR(join_date) = YEAR(CURRENT_DATE)
AND MONTH(join_date) = MONTH(CURRENT_DATE);

-- =========================================
-- Q365: Display years of service for each employee
-- =========================================
SELECT emp_name,
TIMESTAMPDIFF(YEAR, join_date, CURRENT_DATE) AS years_of_service
FROM employee;

-- =========================================
-- Q366: Display employees who joined before 2020
-- =========================================
SELECT *
FROM employee
WHERE join_date < '2020-01-01';

-- =========================================
-- Q367: Display employees who joined after 2022
-- =========================================
SELECT *
FROM employee
WHERE join_date > '2022-12-31';

-- =========================================
-- Q368: Count employees who joined in each year
-- =========================================
SELECT YEAR(join_date) AS join_year,
COUNT(*) AS total_employees
FROM employee
GROUP BY YEAR(join_date);

-- =========================================
-- Q369: Display the oldest employee based on join date
-- =========================================
SELECT *
FROM employee
ORDER BY join_date ASC
LIMIT 1;

-- =========================================
-- Q370: Display the most recently joined employee
-- =========================================
SELECT *
FROM employee
ORDER BY join_date DESC
LIMIT 1;
