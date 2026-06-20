-- Day 29: CTE (Common Table Expression)
-- Queries: Q281 to Q290
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q281: Display all employees using CTE
-- =========================================
WITH employee_cte AS (
    SELECT *
    FROM staff
)
SELECT *
FROM employee_cte;

-- =========================================
-- Q282: Find employees earning above average salary
-- =========================================
WITH avg_salary AS (
    SELECT AVG(salary) AS avg_sal
    FROM staff
)
SELECT *
FROM staff
WHERE salary > (SELECT avg_sal FROM avg_salary);

-- =========================================
-- Q283: Find highest salary employee
-- =========================================
WITH max_salary AS (
    SELECT MAX(salary) AS max_sal
    FROM staff
)
SELECT *
FROM staff
WHERE salary = (SELECT max_sal FROM max_salary);

-- =========================================
-- Q284: Find department-wise average salary
-- =========================================
WITH dept_avg AS (
    SELECT dept_id,
           AVG(salary) AS avg_salary
    FROM staff
    GROUP BY dept_id
)
SELECT *
FROM dept_avg;

-- =========================================
-- Q285: Find employees earning above department average
-- =========================================
WITH dept_avg AS (
    SELECT dept_id,
           AVG(salary) AS avg_salary
    FROM staff
    GROUP BY dept_id
)
SELECT s.*
FROM staff s
JOIN dept_avg d
ON s.dept_id = d.dept_id
WHERE s.salary > d.avg_salary;

-- =========================================
-- Q286: Find total salary department-wise
-- =========================================
WITH dept_total AS (
    SELECT dept_id,
           SUM(salary) AS total_salary
    FROM staff
    GROUP BY dept_id
)
SELECT *
FROM dept_total;

-- =========================================
-- Q287: Find departments with more than 3 employees
-- =========================================
WITH dept_count AS (
    SELECT dept_id,
           COUNT(*) AS total_employees
    FROM staff
    GROUP BY dept_id
)
SELECT *
FROM dept_count
WHERE total_employees > 3;

-- =========================================
-- Q288: Find top salary in each department
-- =========================================
WITH ranked_emp AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY dept_id
               ORDER BY salary DESC
           ) AS r
    FROM staff
)
SELECT *
FROM ranked_emp
WHERE r = 1;

-- =========================================
-- Q289: Find second highest salary in each department
-- =========================================
WITH ranked_emp AS (
    SELECT *,
           DENSE_RANK() OVER (
               PARTITION BY dept_id
               ORDER BY salary DESC
           ) AS r
    FROM staff
)
SELECT *
FROM ranked_emp
WHERE r = 2;

-- =========================================
-- Q290: Find top 3 salaries in company
-- =========================================
WITH ranked_emp AS (
    SELECT *,
           DENSE_RANK() OVER (
               ORDER BY salary DESC
           ) AS r
    FROM staff
)
SELECT *
FROM ranked_emp
WHERE r <= 3;
