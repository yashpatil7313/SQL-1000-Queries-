-- Day 11: Advanced JOINS & SELF JOIN
-- Queries: Q101 to Q110
-- Database: MySQL / PostgreSQL

-- Assumed Tables:
-- staff(emp_id, employee_name, salary, dept_id, manager_id)
-- department(dept_id, dept_name)

-- Q101: INNER JOIN to show employee with department name
SELECT s.employee_name, d.dept_name
FROM staff s
INNER JOIN department d
ON s.dept_id = d.dept_id;

-- Q102: LEFT JOIN to show all employees even if department not assigned
SELECT s.employee_name, d.dept_name
FROM staff s
LEFT JOIN department d
ON s.dept_id = d.dept_id;

-- Q103: RIGHT JOIN to show all departments even if no employees
SELECT s.employee_name, d.dept_name
FROM staff s
RIGHT JOIN department d
ON s.dept_id = d.dept_id;

-- Q104: FULL OUTER JOIN (PostgreSQL)
SELECT s.employee_name, d.dept_name
FROM staff s
FULL OUTER JOIN department d
ON s.dept_id = d.dept_id;

-- MySQL alternative for FULL OUTER JOIN:
-- SELECT s.employee_name, d.dept_name
-- FROM staff s
-- LEFT JOIN department d ON s.dept_id = d.dept_id
-- UNION
-- SELECT s.employee_name, d.dept_name
-- FROM staff s
-- RIGHT JOIN department d ON s.dept_id = d.dept_id;

-- Q105: Count employees in each department
SELECT d.dept_name, COUNT(s.emp_id) AS total_employees
FROM department d
LEFT JOIN staff s
ON s.dept_id = d.dept_id
GROUP BY d.dept_name;










