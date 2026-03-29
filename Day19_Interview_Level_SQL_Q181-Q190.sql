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

-- =========================================
-- Q184: Find employees with continuous increasing salary
-- =========================================
SELECT *
FROM (
    SELECT *, 
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary > prev_salary;

-- Q185: Find duplicate employee names
-- =========================================
SELECT employee_name, COUNT(*) AS count
FROM staff
GROUP BY employee_name
HAVING COUNT(*) > 1;

-- =========================================
-- Q186: Find employees whose salary is same as department average
-- =========================================
SELECT *
FROM (
    SELECT *, 
    AVG(salary) OVER (PARTITION BY dept_id) AS avg_sal
    FROM staff
) t
WHERE salary = avg_sal;

-- =========================================
-- Q187: Find employees earning more than all employees in their department except themselves
-- =========================================
SELECT *
FROM staff s1
WHERE salary > ALL (
    SELECT salary
    FROM staff s2
    WHERE s1.dept_id = s2.dept_id
    AND s1.emp_id <> s2.emp_id
);

-- =========================================
-- Q188: Find employees who have no salary increase compared to previous employee
-- =========================================
SELECT *
FROM (
    SELECT *, 
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary <= prev_salary;

-- =========================================
-- Q189: Find departments where all employees earn more than 50000
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
HAVING MIN(salary) > 50000;

-- =========================================
-- Q190: Find employees whose salary is multiple of 10000
-- =========================================
SELECT *
FROM staff
WHERE salary % 10000 = 0;
