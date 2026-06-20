-- Day 25: Scenario-Based SQL
-- Queries: Q241 to Q250
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- staff(emp_id, employee_name, dept_id, salary)
-- department(dept_id, dept_name)

-- =========================================
-- Q241: Find highest paid employee in the company
-- =========================================
SELECT *
FROM staff
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
);

-- =========================================
-- Q242: Find employees earning more than company average
-- =========================================
SELECT *
FROM staff
WHERE salary > (
    SELECT AVG(salary)
    FROM staff
);

-- =========================================
-- Q243: Find department having highest average salary
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
ORDER BY AVG(salary) DESC
LIMIT 1;

-- =========================================
-- Q244: Find employee count department-wise
-- =========================================
SELECT dept_id,
COUNT(*) AS total_employees
FROM staff
GROUP BY dept_id;

-- =========================================
-- Q245: Find employees earning the same salary
-- =========================================
SELECT *
FROM staff
WHERE salary IN (
    SELECT salary
    FROM staff
    GROUP BY salary
    HAVING COUNT(*) > 1
);

-- =========================================
-- Q246: Find departments having more than 5 employees
-- =========================================
SELECT dept_id,
COUNT(*) AS total_employees
FROM staff
GROUP BY dept_id
HAVING COUNT(*) > 5;

-- =========================================
-- Q247: Find top 3 highest paid employees
-- =========================================
SELECT *
FROM staff
ORDER BY salary DESC
LIMIT 3;

-- =========================================
-- Q248: Find employees whose salary is above department average
-- =========================================
SELECT *
FROM (
    SELECT *,
    AVG(salary) OVER (PARTITION BY dept_id) AS avg_salary
    FROM staff
) t
WHERE salary > avg_salary;

-- =========================================
-- Q249: Find department-wise maximum salary
-- =========================================
SELECT dept_id,
MAX(salary) AS max_salary
FROM staff
GROUP BY dept_id;

-- =========================================
-- Q250: Find employees with second highest salary in company
-- =========================================
SELECT *
FROM staff
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
    WHERE salary < (
        SELECT MAX(salary)
        FROM staff
    )
);
