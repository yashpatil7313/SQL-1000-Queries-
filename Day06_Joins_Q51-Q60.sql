-- Day 06: JOINS (INNER, LEFT, RIGHT)
-- Queries: Q51 to Q60
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- employee(emp_id, emp_name, department, salary)
-- department(dept_id, department)

-- Q51: Display employee name and department name using INNER JOIN
SELECT e.emp_name,d.department
FROM employee e
INNER JOIN department d
ON e.employee = d.department

-- Q52: Display all employees with their department (LEFT JOIN)
SELECT e.emp_name,d.department
FROM employee e
LEFT JOIN department d
ON e.employee = d.department

-- Q53: Display all departments with employees (RIGHT JOIN)
SELECT e.emp_name,d.department
FROM employee e
RIGHT JOIN department d
ON e.department = d.department

-- Q54: Display employees working in IT department
SELECT e.emp_name,d.department
FROM employee e
INNER JOIN department d
ON e.department = d.department
WHERE d.department = 'IT';

-- Q55: Display employees with salary greater than 40000 and their department
SELECT e.emp_name,e.salary,d.department
FROM employee e
INNER JOIN department d
ON e.department = d.department
WHERE e.salary > 40000;

-- Q56: Display employee names and department names ordered by salary
SELECT e.emp_name,d.department,e.salary
FROM employee e
INNER JOIN department d
ON e.department = d.department
ORDER BY e.salary DESC;

-- Q57: Display total salary department-wise using JOIN

















