-- Day 24: Ultra Advanced SQL
-- Queries: Q231 to Q240
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- staff(emp_id, employee_name, dept_id, salary)
-- department(dept_id, dept_name)

-- =========================================
-- Q231: Find employees whose salary is greater than previous and next employee
-- =========================================
SELECT *
FROM (
    SELECT *,
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary,
    LEAD(salary) OVER (ORDER BY emp_id) AS next_salary
    FROM staff
) t
WHERE salary > prev_salary
AND salary > next_salary;

-- =========================================
-- Q232: Find department-wise highest salary employee
-- =========================================
SELECT *
FROM (
    SELECT *,
    RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r = 1;

-- =========================================
-- Q233: Find employees whose salary is equal to previous employee
-- =========================================
SELECT *
FROM (
    SELECT *,
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary = prev_salary;

-- =========================================
-- Q234: Find employees whose salary is lower than both previous and next employee
-- =========================================
SELECT *
FROM (
    SELECT *,
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary,
    LEAD(salary) OVER (ORDER BY emp_id) AS next_salary
    FROM staff
) t
WHERE salary < prev_salary
AND salary < next_salary;

-- =========================================
-- Q235: Find departments where average salary is greater than 60000
-- =========================================
SELECT dept_id, AVG(salary) AS avg_salary
FROM staff
GROUP BY dept_id
HAVING AVG(salary) > 60000;

-- =========================================
-- Q236: Find employees with unique salary
-- =========================================
SELECT *
FROM staff
WHERE salary IN (
    SELECT salary
    FROM staff
    GROUP BY salary
    HAVING COUNT(*) = 1
);

-- =========================================
-- Q237: Find employees with duplicate salary
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
-- Q238: Find second highest salary department-wise
-- =========================================
SELECT *
FROM (
    SELECT *,
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r = 2;

-- =========================================
-- Q239: Find employees whose salary is above department average
-- =========================================
SELECT *
FROM (
    SELECT *,
    AVG(salary) OVER (PARTITION BY dept_id) AS avg_salary
    FROM staff
) t
WHERE salary > avg_salary;

-- =========================================
-- Q240: Find running total of salary globally
-- =========================================
SELECT emp_id, employee_name, salary,
SUM(salary) OVER (ORDER BY emp_id) AS running_total
FROM staff;
