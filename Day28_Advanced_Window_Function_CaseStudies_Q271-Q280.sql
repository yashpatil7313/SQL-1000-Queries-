-- Day 28: Advanced Window Function Case Studies
-- Queries: Q271 to Q280
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q271: Find top 3 highest paid employees in the company
-- =========================================
SELECT *
FROM (
    SELECT *,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r <= 3;

-- =========================================
-- Q272: Find highest paid employee in each department
-- =========================================
SELECT *
FROM (
    SELECT *,
    DENSE_RANK() OVER (
        PARTITION BY dept_id
        ORDER BY salary DESC
    ) AS r
    FROM staff
) t
WHERE r = 1;

-- =========================================
-- Q273: Find second highest salary in each department
-- =========================================
SELECT *
FROM (
    SELECT *,
    DENSE_RANK() OVER (
        PARTITION BY dept_id
        ORDER BY salary DESC
    ) AS r
    FROM staff
) t
WHERE r = 2;

-- =========================================
-- Q274: Find employees earning above department average
-- =========================================
SELECT *
FROM (
    SELECT *,
    AVG(salary) OVER (
        PARTITION BY dept_id
    ) AS avg_salary
    FROM staff
) t
WHERE salary > avg_salary;

-- =========================================
-- Q275: Find employees earning below department average
-- =========================================
SELECT *
FROM (
    SELECT *,
    AVG(salary) OVER (
        PARTITION BY dept_id
    ) AS avg_salary
    FROM staff
) t
WHERE salary < avg_salary;

-- =========================================
-- Q276: Find salary difference from previous employee
-- =========================================
SELECT emp_id,
employee_name,
salary,
salary - LAG(salary) OVER (ORDER BY emp_id) AS salary_difference
FROM staff;

-- =========================================
-- Q277: Find salary difference from next employee
-- =========================================
SELECT emp_id,
employee_name,
salary,
LEAD(salary) OVER (ORDER BY emp_id) - salary AS salary_difference
FROM staff;

-- =========================================
-- Q278: Find employees whose salary increased compared to previous employee
-- =========================================
SELECT *
FROM (
    SELECT *,
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary > prev_salary;

-- =========================================
-- Q279: Find employees whose salary decreased compared to previous employee
-- =========================================
SELECT *
FROM (
    SELECT *,
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary < prev_salary;

-- =========================================
-- Q280: Find running total salary department-wise
-- =========================================
SELECT emp_id,
employee_name,
dept_id,
salary,
SUM(salary) OVER (
    PARTITION BY dept_id
    ORDER BY emp_id
) AS running_total
FROM staff;
