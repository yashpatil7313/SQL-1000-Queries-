-- Day 18: Advanced Case Study SQL
-- Queries: Q171 to Q180
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- staff(emp_id, employee_name, dept_id, salary)
-- department(dept_id, dept_name)

-- =========================================
-- Q171: Top 2 highest paid employees in each department
-- =========================================
SELECT *
FROM (
    SELECT *, 
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r <= 2;

-- =========================================
-- Q172: Employees whose salary is above overall average but below max salary
-- =========================================
SELECT *
FROM staff
WHERE salary > (SELECT AVG(salary) FROM staff)
AND salary < (SELECT MAX(salary) FROM staff);

-- =========================================
-- Q173: Find departments where average salary is greater than company average
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
HAVING AVG(salary) > (SELECT AVG(salary) FROM staff);

-- =========================================
-- Q174: Find employees with salary greater than previous employee (by emp_id)
-- =========================================
SELECT *
FROM (
    SELECT *, 
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary > prev_salary;

-- =========================================
-- Q175: Find salary difference between highest and lowest salary in each department
-- =========================================
SELECT dept_id,
MAX(salary) - MIN(salary) AS salary_difference
FROM staff
GROUP BY dept_id;

-- =========================================
-- Q176: Find employees who are earning the highest salary in the company
-- =========================================
SELECT *
FROM staff
WHERE salary = (SELECT MAX(salary) FROM staff);

-- =========================================
-- Q177: Find employees whose salary is less than department average
-- =========================================
SELECT *
FROM (
    SELECT *, 
    AVG(salary) OVER (PARTITION BY dept_id) AS avg_sal
    FROM staff
) t
WHERE salary < avg_sal;

-- =========================================
-- Q178: Find departments having more than 2 employees
-- =========================================
SELECT dept_id, COUNT(*) AS total_emp
FROM staff
GROUP BY dept_id
HAVING COUNT(*) > 2;

-- =========================================
-- Q179: Find employees whose salary is same as previous employee
-- =========================================
SELECT *
FROM (
    SELECT *, 
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary = prev_salary;

-- =========================================
-- Q180: Find employees with increasing salary trend
-- =========================================
SELECT *
FROM (
    SELECT *, 
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary > prev_salary;
