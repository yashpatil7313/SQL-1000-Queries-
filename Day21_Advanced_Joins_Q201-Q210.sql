-- Day 21: Advanced Joins & Real-world SQL
-- Queries: Q201 to Q210
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- employee(emp_id, emp_name, dept_id, salary)
-- department(dept_id, dept_name)

-- =========================================
-- Q201: Display employee name with department name
-- =========================================
SELECT e.emp_name, d.dept_name
FROM employee e
INNER JOIN department d
ON e.dept_id = d.dept_id;

-- =========================================
-- Q202: Display all employees even if no department assigned
-- =========================================
SELECT e.emp_name, d.dept_name
FROM employee e
LEFT JOIN department d
ON e.dept_id = d.dept_id;

-- =========================================
-- Q203: Display departments even if no employees
-- =========================================
SELECT e.emp_name, d.dept_name
FROM employee e
RIGHT JOIN department d
ON e.dept_id = d.dept_id;

-- =========================================
-- Q204: Find employees without department
-- =========================================
SELECT e.*
FROM employee e
LEFT JOIN department d
ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- =========================================
-- Q205: Find departments with no employees
-- =========================================
SELECT d.*
FROM department d
LEFT JOIN employee e
ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;

-- =========================================
-- Q206: Count employees in each department
-- =========================================
SELECT d.dept_name, COUNT(e.emp_id) AS total_employees
FROM department d
LEFT JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- =========================================
-- Q207: Total salary per department
-- =========================================
SELECT d.dept_name, SUM(e.salary) AS total_salary
FROM department d
LEFT JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- =========================================
-- Q208: Average salary per department
-- =========================================
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM department d
LEFT JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

-- =========================================
-- Q209: Departments where total salary > 100000
-- =========================================
SELECT d.dept_name, SUM(e.salary) AS total_salary
FROM department d
LEFT JOIN employee e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING SUM(e.salary) > 100000;

-- =========================================
-- Q210: Employees with department and salary > 50000
-- =========================================
SELECT e.emp_name, d.dept_name, e.salary
FROM employee e
INNER JOIN department d
ON e.dept_id = d.dept_id
WHERE e.salary > 50000;
