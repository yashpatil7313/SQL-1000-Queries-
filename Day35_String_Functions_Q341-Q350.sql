-- Day 35: String Functions
-- Queries: Q341 to Q350
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, department, city)

-- =========================================
-- Q341: Display employee names in uppercase
-- =========================================
SELECT emp_name,
UPPER(emp_name) AS upper_name
FROM employee;

-- =========================================
-- Q342: Display employee names in lowercase
-- =========================================
SELECT emp_name,
LOWER(emp_name) AS lower_name
FROM employee;

-- =========================================
-- Q343: Display length of each employee name
-- =========================================
SELECT emp_name,
LENGTH(emp_name) AS name_length
FROM employee;

-- =========================================
-- Q344: Concatenate employee name and city
-- =========================================
SELECT CONCAT(emp_name, ' - ', city) AS employee_details
FROM employee;

-- =========================================
-- Q345: Display first 3 characters of employee name
-- =========================================
SELECT emp_name,
SUBSTRING(emp_name, 1, 3) AS first_three_letters
FROM employee;

-- =========================================
-- Q346: Remove leading and trailing spaces
-- =========================================
SELECT TRIM('   SQL Practice   ') AS trimmed_text;

-- =========================================
-- Q347: Replace 'Mumbai' with 'Pune'
-- =========================================
SELECT emp_name,
REPLACE(city, 'Mumbai', 'Pune') AS updated_city
FROM employee;

-- =========================================
-- Q348: Display first character of employee name
-- =========================================
SELECT emp_name,
LEFT(emp_name, 1) AS first_character
FROM employee;

-- =========================================
-- Q349: Display last 2 characters of employee name
-- =========================================
SELECT emp_name,
RIGHT(emp_name, 2) AS last_two_characters
FROM employee;

-- =========================================
-- Q350: Find employees whose names start with 'A'
-- =========================================
SELECT *
FROM employee
WHERE emp_name LIKE 'A%';
