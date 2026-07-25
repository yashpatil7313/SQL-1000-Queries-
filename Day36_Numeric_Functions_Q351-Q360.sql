-- Day 36: Numeric Functions
-- Queries: Q351 to Q360
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, salary)

-- =========================================
-- Q351: Round salary to the nearest integer
-- =========================================
SELECT emp_name,
ROUND(salary) AS rounded_salary
FROM employee;

-- =========================================
-- Q352: Round salary to 2 decimal places
-- =========================================
SELECT emp_name,
ROUND(salary, 2) AS rounded_salary
FROM employee;

-- =========================================
-- Q353: Display the ceiling value of salary
-- =========================================
SELECT emp_name,
CEIL(salary) AS ceiling_salary
FROM employee;

-- =========================================
-- Q354: Display the floor value of salary
-- =========================================
SELECT emp_name,
FLOOR(salary) AS floor_salary
FROM employee;

-- =========================================
-- Q355: Display the absolute value of salary difference
-- =========================================
SELECT emp_name,
ABS(salary - 50000) AS salary_difference
FROM employee;

-- =========================================
-- Q356: Display salary raised to the power of 2
-- =========================================
SELECT emp_name,
POWER(salary, 2) AS salary_square
FROM employee;

-- =========================================
-- Q357: Display square root of salary
-- =========================================
SELECT emp_name,
SQRT(salary) AS salary_sqrt
FROM employee;

-- =========================================
-- Q358: Display remainder when salary is divided by 1000
-- =========================================
SELECT emp_name,
MOD(salary, 1000) AS remainder
FROM employee;

-- =========================================
-- Q359: Generate a random number
-- =========================================
SELECT RAND() AS random_number;

-- =========================================
-- Q360: Display the sign of salary
-- =========================================
SELECT emp_name,
SIGN(salary) AS salary_sign
FROM employee;
