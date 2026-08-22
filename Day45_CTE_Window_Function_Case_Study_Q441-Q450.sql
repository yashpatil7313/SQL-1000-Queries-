-- Day 45: CTE + Window Function Case Study
-- Queries: Q441 to Q450
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, department, salary)

-- =========================================
-- Q441: Find employees earning above company average using CTE
-- =========================================
WITH company_avg AS (
    SELECT AVG(salary) AS avg_salary
    FROM employee
)
SELECT e.*
FROM employee e
CROSS JOIN company_avg c
WHERE e.salary > c.avg_salary;


-- =========================================
-- Q442: Find employees earning above department average
-- =========================================
WITH dept_avg AS (
    SELECT department,
           AVG(salary) AS avg_salary
    FROM employee
    GROUP BY department
)
SELECT e.*
FROM employee e
JOIN dept_avg d
    ON e.department = d.department
WHERE e.salary > d.avg_salary;


-- =========================================
-- Q443: Rank employees by salary
-- =========================================
WITH ranked_employees AS (
    SELECT *,
           RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employee
)
SELECT *
FROM ranked_employees;


-- =========================================
-- Q444: Find top 3 highest-paid employees
-- =========================================
WITH ranked_employees AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employee
)
SELECT *
FROM ranked_employees
WHERE salary_rank <= 3;


-- =========================================
-- Q445: Find highest-paid employee in each department
-- =========================================
WITH ranked_employees AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY department
               ORDER BY salary DESC
           ) AS salary_rank
    FROM employee
)
SELECT *
FROM ranked_employees
WHERE salary_rank = 1;


-- =========================================
-- Q446: Find second highest-paid employee in each department
-- =========================================
WITH ranked_employees AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY department
               ORDER BY salary DESC
           ) AS salary_rank
    FROM employee
)
SELECT *
FROM ranked_employees
WHERE salary_rank = 2;


-- =========================================
-- Q447: Calculate running total of salary
-- =========================================
WITH salary_running_total AS (
    SELECT emp_id,
           emp_name,
           salary,
           SUM(salary) OVER (
               ORDER BY emp_id
           ) AS running_total
    FROM employee
)
SELECT *
FROM salary_running_total;


-- =========================================
-- Q448: Calculate department-wise running total
-- =========================================
WITH department_running_total AS (
    SELECT emp_id,
           emp_name,
           department,
           salary,
           SUM(salary) OVER (
               PARTITION BY department
               ORDER BY emp_id
           ) AS running_total
    FROM employee
)
SELECT *
FROM department_running_total;


-- =========================================
-- Q449: Compare salary with previous employee
-- =========================================
WITH salary_comparison AS (
    SELECT *,
           LAG(salary) OVER (
               ORDER BY emp_id
           ) AS previous_salary
    FROM employee
)
SELECT *
FROM salary_comparison
WHERE salary > previous_salary;


-- =========================================
-- Q450: Compare salary with next employee
-- =========================================
WITH salary_comparison AS (
    SELECT *,
           LEAD(salary) OVER (
               ORDER BY emp_id
           ) AS next_salary
    FROM employee
)
SELECT *
FROM salary_comparison
WHERE salary < next_salary;
