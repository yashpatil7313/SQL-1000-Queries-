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

-- Q106: Show departments having more than 3 employees
SELECT d.dept_name, COUNT(s.emp_id) AS total_employees
FROM department d
JOIN staff s
ON s.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING COUNT(s.emp_id) > 3;

-- Q107: SELF JOIN to show employee and their manager name
SELECT e.employee_name AS employee,
       m.employee_name AS manager
FROM staff e
LEFT JOIN staff m
ON e.manager_id = m.emp_id;

-- Q108: Find employees earning more than their manager
SELECT e.employee_name
FROM staff e
JOIN staff m
ON e.manager_id = m.emp_id
WHERE e.salary > m.salary;

-- Q109: Join three tables (example with project table)
-- project(project_id, project_name, emp_id)

SELECT s.employee_name, d.dept_name, p.project_name
FROM staff s
JOIN department d ON s.dept_id = d.dept_id
JOIN project p ON s.emp_id = p.emp_id;

-- Q110: Find highest salary in each department
SELECT d.dept_name, MAX(s.salary) AS highest_salary
FROM department d
JOIN staff s
ON s.dept_id = d.dept_id
GROUP BY d.dept_name;










