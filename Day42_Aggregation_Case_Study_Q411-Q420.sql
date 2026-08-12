-- Day 42: Aggregation Case Study
-- Queries: Q411 to Q420
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, department, salary, city)

-- =========================================
-- Q411: Find total salary paid to all employees
-- =========================================
SELECT SUM(salary) AS total_salary
FROM employee;

-- =========================================
-- Q412: Find average salary of all employees
-- =========================================
SELECT AVG(salary) AS average_salary
FROM employee;

-- =========================================
-- Q413: Find highest and lowest salary
-- =========================================
SELECT
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary
FROM employee;

-- =========================================
-- Q414: Find total employees in each department
-- =========================================
SELECT department,
       COUNT(*) AS total_employees
FROM employee
GROUP BY department;

-- =========================================
-- Q415: Find average salary in each department
-- =========================================
SELECT department,
       AVG(salary) AS average_salary
FROM employee
GROUP BY department;

-- =========================================
-- Q416: Find departments where average salary is above 50000
-- =========================================
SELECT department,
       AVG(salary) AS average_salary
FROM employee
GROUP BY department
HAVING AVG(salary) > 50000;

-- =========================================
-- Q417: Find departments where total salary is above 200000
-- =========================================
SELECT department,
       SUM(salary) AS total_salary
FROM employee
GROUP BY department
HAVING SUM(salary) > 200000;

-- =========================================
-- Q418: Find the department with the highest average salary
-- =========================================
SELECT department,
       AVG(salary) AS average_salary
FROM employee
GROUP BY department
ORDER BY average_salary DESC
LIMIT 1;

-- =========================================
-- Q419: Find the department with the most employees
-- =========================================
SELECT department,
       COUNT(*) AS total_employees
FROM employee
GROUP BY department
ORDER BY total_employees DESC
LIMIT 1;

-- =========================================
-- Q420: Find salary statistics department-wise
-- =========================================
SELECT department,
       COUNT(*) AS total_employees,
       SUM(salary) AS total_salary,
       AVG(salary) AS average_salary,
       MAX(salary) AS highest_salary,
       MIN(salary) AS lowest_salary
FROM employee
GROUP BY department;
