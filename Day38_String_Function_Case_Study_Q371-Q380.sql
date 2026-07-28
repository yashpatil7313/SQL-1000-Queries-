-- Day 38: String Function Case Study
-- Queries: Q371 to Q380
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, email, city)

-- =========================================
-- Q371: Display employee names in uppercase
-- =========================================
SELECT emp_name,
UPPER(emp_name) AS upper_name
FROM employee;

-- =========================================
-- Q372: Display employee names in lowercase
-- =========================================
SELECT emp_name,
LOWER(emp_name) AS lower_name
FROM employee;

-- =========================================
-- Q373: Display the length of each employee name
-- =========================================
SELECT emp_name,
LENGTH(emp_name) AS name_length
FROM employee;

-- =========================================
-- Q374: Display the first 4 characters of employee names
-- =========================================
SELECT emp_name,
LEFT(emp_name, 4) AS first_four_characters
FROM employee;

-- =========================================
-- Q375: Display the last 3 characters of employee names
-- =========================================
SELECT emp_name,
RIGHT(emp_name, 3) AS last_three_characters
FROM employee;

-- =========================================
-- Q376: Display employee names without leading or trailing spaces
-- =========================================
SELECT TRIM(emp_name) AS cleaned_name
FROM employee;

-- =========================================
-- Q377: Replace 'gmail.com' with 'company.com' in email addresses
-- =========================================
SELECT email,
REPLACE(email, 'gmail.com', 'company.com') AS updated_email
FROM employee;

-- =========================================
-- Q378: Display full employee details using CONCAT()
-- =========================================
SELECT CONCAT(emp_name, ' | ', city, ' | ', email) AS employee_details
FROM employee;

-- =========================================
-- Q379: Display employees whose names start with 'S'
-- =========================================
SELECT *
FROM employee
WHERE emp_name LIKE 'S%';

-- =========================================
-- Q380: Display the email domain of each employee
-- =========================================
SELECT email,
SUBSTRING_INDEX(email, '@', -1) AS email_domain
FROM employee;
