-- Day 26: Advanced Interview SQL
-- Queries: Q251 to Q260
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q251: Find third highest salary
-- =========================================
SELECT MAX(salary)
FROM staff
WHERE salary < (
    SELECT MAX(salary)
    FROM staff
    WHERE salary < (
        SELECT MAX(salary)
        FROM staff
    )
);

-- =========================================
-- Q252: Find employees with third highest salary
-- =========================================
SELECT *
FROM staff
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
    WHERE salary < (
        SELECT MAX(salary)
        FROM staff
        WHERE salary < (
            SELECT MAX(salary)
            FROM staff
        )
    )
);

-- =========================================
-- Q253: Find employees whose salary is greater than department average
-- =========================================
SELECT *
FROM staff s
WHERE salary > (
    SELECT AVG(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);

-- =========================================
-- Q254: Find employee(s) with minimum salary
-- =========================================
SELECT *
FROM staff
WHERE salary = (
    SELECT MIN(salary)
    FROM staff
);

-- =========================================
-- Q255: Find department having maximum employees
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- =========================================
-- Q256: Find employees whose salary is higher than previous employee
-- =========================================
SELECT *
FROM (
    SELECT *,
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary > prev_salary;

-- =========================================
-- Q257: Find employees whose salary is lower than previous employee
-- =========================================
SELECT *
FROM (
    SELECT *,
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
) t
WHERE salary < prev_salary;

-- =========================================
-- Q258: Find department-wise employee count and average salary
-- =========================================
SELECT dept_id,
COUNT(*) AS total_employees,
AVG(salary) AS avg_salary
FROM staff
GROUP BY dept_id;

-- =========================================
-- Q259: Find departments where average salary is above 50000
-- =========================================
SELECT dept_id,
AVG(salary) AS avg_salary
FROM staff
GROUP BY dept_id
HAVING AVG(salary) > 50000;

-- =========================================
-- Q260: Find employees with highest salary in each department
-- =========================================
SELECT *
FROM (
    SELECT *,
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r = 1;
