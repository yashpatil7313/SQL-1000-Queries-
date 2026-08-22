-- Day 46: Advanced Interview Case Study
-- Queries: Q451 to Q460
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, department, salary)

-- =========================================
-- Q451: Find the third highest distinct salary
-- =========================================
SELECT MAX(salary) AS third_highest_salary
FROM employee
WHERE salary < (
    SELECT MAX(salary)
    FROM employee
    WHERE salary < (
        SELECT MAX(salary)
        FROM employee
    )
);


-- =========================================
-- Q452: Find employees with the third highest salary
-- =========================================
WITH ranked_salary AS (
    SELECT *,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employee
)
SELECT *
FROM ranked_salary
WHERE salary_rank = 3;


-- =========================================
-- Q453: Find employees earning more than their department average
-- =========================================
SELECT *
FROM employee e
WHERE salary > (
    SELECT AVG(salary)
    FROM employee
    WHERE department = e.department
);


-- =========================================
-- Q454: Find the department with the highest total salary
-- =========================================
SELECT department,
       SUM(salary) AS total_salary
FROM employee
GROUP BY department
ORDER BY total_salary DESC
LIMIT 1;


-- =========================================
-- Q455: Find the department with the lowest average salary
-- =========================================
SELECT department,
       AVG(salary) AS average_salary
FROM employee
GROUP BY department
ORDER BY average_salary ASC
LIMIT 1;


-- =========================================
-- Q456: Find employees who have the same salary
-- =========================================
SELECT *
FROM employee
WHERE salary IN (
    SELECT salary
    FROM employee
    GROUP BY salary
    HAVING COUNT(*) > 1
);


-- =========================================
-- Q457: Find employees who have a unique salary
-- =========================================
SELECT *
FROM employee
WHERE salary IN (
    SELECT salary
    FROM employee
    GROUP BY salary
    HAVING COUNT(*) = 1
);


-- =========================================
-- Q458: Find employees whose salary is higher than the previous employee
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
-- Q459: Find employees whose salary is lower than the next employee
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


-- =========================================
-- Q460: Find top 2 highest-paid employees in each department
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
WHERE salary_rank <= 2;
