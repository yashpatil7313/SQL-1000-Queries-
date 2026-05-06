-- Day 23: Complex Case Study SQL
-- Queries: Q221 to Q230
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- staff(emp_id, employee_name, dept_id, salary)
-- department(dept_id, dept_name)

-- =========================================
-- Q221: Top 3 highest paid employees in each department
-- =========================================
SELECT *
FROM (
    SELECT *, 
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r <= 3;

-- =========================================
-- Q222: Departments where average salary is above company average
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
HAVING AVG(salary) > (SELECT AVG(salary) FROM staff);

-- =========================================
-- Q223: Employees earning less than department average
-- =========================================
SELECT *
FROM (
    SELECT *, 
    AVG(salary) OVER (PARTITION BY dept_id) AS avg_sal
    FROM staff
) t
WHERE salary < avg_sal;

-- =========================================
-- Q224: Department with highest total salary
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
ORDER BY SUM(salary) DESC
LIMIT 1;

-- =========================================
-- Q225: Employees whose salary is same as previous employee
-- =========================================
SELECT *
FROM (
    SELECT *, 
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary = prev_salary;

-- =========================================
-- Q226: Employees with salary difference greater than 10000 from previous
-- =========================================
SELECT *
FROM (
    SELECT *, 
    salary - LAG(salary) OVER (ORDER BY emp_id) AS diff
    FROM staff
) t
WHERE diff > 10000;

-- =========================================
-- Q227: Departments having more than 3 employees
-- =========================================
SELECT dept_id, COUNT(*) AS total_emp
FROM staff
GROUP BY dept_id
HAVING COUNT(*) > 3;

-- =========================================
-- Q228: Employees with second highest salary in each department
-- =========================================
SELECT *
FROM (
    SELECT *, 
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r = 2;

-- =========================================
-- Q229: Employees not in any department
-- =========================================
SELECT s.*
FROM staff s
LEFT JOIN department d ON s.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- =========================================
-- Q230: Running total of salary department-wise
-- =========================================
SELECT emp_id, employee_name, dept_id, salary,
SUM(salary) OVER (PARTITION BY dept_id ORDER BY emp_id) AS running_total
FROM staff;
