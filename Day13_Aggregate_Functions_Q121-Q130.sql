-- Day 13: Aggregate Functions Deep Dive
-- Queries: Q121 to Q130
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- staff(emp_id, employee_name, salary, dept_id)
-- department(dept_id, dept_name)

-- Q121: Find total salary of all employees
SELECT SUM(salary) AS total_salary
FROM staff;

-- Q122: Find average salary in each department
SELECT dept_id, AVG(salary) AS avg_salary
FROM staff
GROUP BY dept_id;

-- Q123: Find highest salary in each department
SELECT dept_id, MAX(salary) AS highest_salary
FROM staff
GROUP BY dept_id;

-- Q124: Find lowest salary in each department
SELECT dept_id, MIN(salary) AS lowest_salary
FROM staff
GROUP BY dept_id;

-- Q125: Count total employees in each department
SELECT dept_id, COUNT(emp_id) AS total_employees
FROM staff
GROUP BY dept_id;

-- Q126: Display departments having average salary greater than 60000
SELECT dept_id, AVG(salary) AS avg_salary
FROM staff
GROUP BY dept_id
HAVING AVG(salary) > 60000;


-- Q127: Find total salary department-wise and sort by highest total salary
SELECT dept_id, SUM(salary) AS total_salary
FROM staff
GROUP BY dept_id
ORDER BY total_salary DESC;

-- Q128: Find departments with more than 3 employees
SELECT dept_id, COUNT(*) AS employee_count
FROM staff
GROUP BY dept_id
HAVING COUNT(*) > 3;

-- Q129: Find difference between highest and lowest salary in company
SELECT MAX(salary) - MIN(salary) AS salary_difference
FROM staff;

-- Q130: Count employees and show department name using JOIN
SELECT d.dept_name, COUNT(s.emp_id) AS total_employees
FROM department d
LEFT JOIN staff s ON d.dept_id = s.dept_id
GROUP BY d.dept_name;








