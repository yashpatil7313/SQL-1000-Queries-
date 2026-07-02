-- Day 31: Mixed Interview SQL
-- Queries: Q301 to Q310
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q301: Find employees earning more than the company average
-- =========================================
SELECT *
FROM staff
WHERE salary > (
    SELECT AVG(salary)
    FROM staff
);

-- =========================================
-- Q302: Find department with the highest average salary
-- =========================================
SELECT dept_id, AVG(salary) AS avg_salary
FROM staff
GROUP BY dept_id
ORDER BY avg_salary DESC
LIMIT 1;

-- =========================================
-- Q303: Find employees with the highest salary in each department
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
-- Q304: Find employees earning less than department average
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
-- Q305: Find duplicate employee names
-- =========================================
SELECT employee_name,
       COUNT(*) AS total
FROM staff
GROUP BY employee_name
HAVING COUNT(*) > 1;

-- =========================================
-- Q306: Find duplicate salaries
-- =========================================
SELECT salary,
       COUNT(*) AS total
FROM staff
GROUP BY salary
HAVING COUNT(*) > 1;

-- =========================================
-- Q307: Find employees whose salary is equal to the company maximum
-- =========================================
SELECT *
FROM staff
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
);

-- =========================================
-- Q308: Find employees whose salary is equal to the company minimum
-- =========================================
SELECT *
FROM staff
WHERE salary = (
    SELECT MIN(salary)
    FROM staff
);

-- =========================================
-- Q309: Find the top 5 highest-paid employees
-- =========================================
SELECT *
FROM staff
ORDER BY salary DESC
LIMIT 5;

-- =========================================
-- Q310: Find employees whose salary is between 40000 and 70000
-- =========================================
SELECT *
FROM staff
WHERE salary BETWEEN 40000 AND 70000;
