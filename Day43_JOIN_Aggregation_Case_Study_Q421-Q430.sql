-- Day 43: JOIN + Aggregation Case Study
-- Queries: Q421 to Q430
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- employee(emp_id, emp_name, department, salary)
-- department(dept_id, department)

-- =========================================
-- Q421: Display employee names with department names
-- =========================================
SELECT e.emp_name,
       d.department
FROM employee e
INNER JOIN department d
    ON e.department = d.department;

-- =========================================
-- Q422: Count employees in each department
-- =========================================
SELECT d.department,
       COUNT(e.emp_id) AS total_employees
FROM department d
LEFT JOIN employee e
    ON e.department = d.department
GROUP BY d.department;

-- =========================================
-- Q423: Calculate total salary of each department
-- =========================================
SELECT d.department,
       SUM(e.salary) AS total_salary
FROM department d
INNER JOIN employee e
    ON e.department = d.department
GROUP BY d.department;

-- =========================================
-- Q424: Calculate average salary of each department
-- =========================================
SELECT d.department,
       AVG(e.salary) AS average_salary
FROM department d
INNER JOIN employee e
    ON e.department = d.department
GROUP BY d.department;

-- =========================================
-- Q425: Find departments with more than 3 employees
-- =========================================
SELECT d.department,
       COUNT(e.emp_id) AS total_employees
FROM department d
INNER JOIN employee e
    ON e.department = d.department
GROUP BY d.department
HAVING COUNT(e.emp_id) > 3;

-- =========================================
-- Q426: Find departments with total salary above 200000
-- =========================================
SELECT d.department,
       SUM(e.salary) AS total_salary
FROM department d
INNER JOIN employee e
    ON e.department = d.department
GROUP BY d.department
HAVING SUM(e.salary) > 200000;

-- =========================================
-- Q427: Find highest salary in each department
-- =========================================
SELECT d.department,
       MAX(e.salary) AS highest_salary
FROM department d
INNER JOIN employee e
    ON e.department = d.department
GROUP BY d.department;

-- =========================================
-- Q428: Find lowest salary in each department
-- =========================================
SELECT d.department,
       MIN(e.salary) AS lowest_salary
FROM department d
INNER JOIN employee e
    ON e.department = d.department
GROUP BY d.department;

-- =========================================
-- Q429: Display departments having no employees
-- =========================================
SELECT d.department
FROM department d
LEFT JOIN employee e
    ON e.department = d.department
WHERE e.emp_id IS NULL;

-- =========================================
-- Q430: Display complete department salary statistics
-- =========================================
SELECT d.department,
       COUNT(e.emp_id) AS total_employees,
       SUM(e.salary) AS total_salary,
       AVG(e.salary) AS average_salary,
       MAX(e.salary) AS highest_salary,
       MIN(e.salary) AS lowest_salary
FROM department d
LEFT JOIN employee e
    ON e.department = d.department
GROUP BY d.department;
