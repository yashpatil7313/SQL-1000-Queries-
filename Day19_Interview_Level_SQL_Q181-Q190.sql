-- Day 19: Interview-Level SQL
-- Queries: Q181 to Q190
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q181: Find 3rd highest salary
-- =========================================
SELECT salary
FROM staff
ORDER BY salary DESC
LIMIT 1 OFFSET 2;

-- =========================================
-- Q182: Find 3rd highest salary using subquery
-- =========================================
SELECT MAX(salary)
FROM staff
WHERE salary < (
    SELECT MAX(salary)
    FROM staff
    WHERE salary < (
        SELECT MAX(salary) FROM staff
    )
);

-- =========================================
-- Q183: Find employees with top 3 salaries
-- =========================================
SELECT *
FROM (
    SELECT *, 
    DENSE_RANK() OVER (ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r <= 3;

