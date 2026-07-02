-- Day 32: Advanced Interview SQL
-- Queries: Q311 to Q320
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q311: Find employees with the second highest salary in each department
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
-- Q312: Find employees whose salary is above the company average
-- =========================================
SELECT *
FROM staff
WHERE salary > (
    SELECT AVG(salary)
    FROM staff
);

-- =========================================
-- Q313: Find the department with the maximum number of employees
-- =========================================
SELECT dept_id,
       COUNT(*) AS total_employees
FROM staff
GROUP BY dept_id
ORDER BY total_employees DESC
LIMIT 1;

-- =========================================
-- Q314: Find employees whose salary is below the company average
-- =========================================
SELECT *
FROM staff
WHERE salary < (
    SELECT AVG(salary)
    FROM staff
);

-- =========================================
-- Q315: Find the top 3 highest-paid employees in each department
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
WHERE r <= 3;

-- =========================================
-- Q316: Find the total salary paid by each department
-- =========================================
SELECT dept_id,
       SUM(salary) AS total_salary
FROM staff
GROUP BY dept_id;

-- =========================================
-- Q317: Find departments where total salary exceeds 200000
-- =========================================
SELECT dept_id,
       SUM(salary) AS total_salary
FROM staff
GROUP BY dept_id
HAVING SUM(salary) > 200000;

-- =========================================
-- Q318: Find employees whose salary is equal to the department maximum
-- =========================================
SELECT *
FROM staff s
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);

-- =========================================
-- Q319: Find employees whose salary is equal to the department minimum
-- =========================================
SELECT *
FROM staff s
WHERE salary = (
    SELECT MIN(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);

-- =========================================
-- Q320: Find the average salary of each department
-- =========================================
SELECT dept_id,
       AVG(salary) AS average_salary
FROM staff
GROUP BY dept_id;
