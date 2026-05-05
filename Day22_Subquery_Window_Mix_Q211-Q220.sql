-- Day 22: Subqueries + Window Functions
-- Queries: Q211 to Q220
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q211: Employees earning more than overall average
-- =========================================
SELECT *
FROM staff
WHERE salary > (SELECT AVG(salary) FROM staff);

-- =========================================
-- Q212: Employees earning more than department average
-- =========================================
SELECT *
FROM staff s
WHERE salary > (
    SELECT AVG(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);

-- =========================================
-- Q213: Rank employees by salary (global)
-- =========================================
SELECT emp_id, employee_name, salary,
RANK() OVER (ORDER BY salary DESC) AS r
FROM staff;

-- =========================================
-- Q214: Rank employees department-wise
-- =========================================
SELECT emp_id, employee_name, dept_id, salary,
RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank
FROM staff;

-- =========================================
-- Q215: Employees with top 2 salary per department
-- =========================================
SELECT *
FROM (
    SELECT *, 
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r <= 2;

-- =========================================
-- Q216: Running total of salary
-- =========================================
SELECT emp_id, employee_name, salary,
SUM(salary) OVER (ORDER BY emp_id) AS running_total
FROM staff;

-- =========================================
-- Q217: Compare salary with previous employee
-- =========================================
SELECT emp_id, employee_name, salary,
LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
FROM staff;

-- =========================================
-- Q218: Employees with increasing salary compared to previous
-- =========================================
SELECT *
FROM (
    SELECT *, 
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary > prev_salary;

-- =========================================
-- Q219: Employees with salary equal to max salary in their department
-- =========================================
SELECT *
FROM staff s
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);

-- =========================================
-- Q220: Difference between current and next salary
-- =========================================
SELECT emp_id, employee_name, salary,
LEAD(salary) OVER (ORDER BY emp_id) - salary AS diff_next
FROM staff;
