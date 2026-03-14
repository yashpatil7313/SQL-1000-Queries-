-- Day 14: Window Functions
-- Queries: Q131 to Q140
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, salary, dept_id)

-- Q131: Assign row numbers to employees based on salary
SELECT emp_id, employee_name, salary,
ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_number
FROM staff;

-- Q132: Rank employees based on salary
SELECT emp_id, employee_name, salary,
RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM staff;

-- Q133: Dense rank employees based on salary
SELECT emp_id, employee_name, salary,
DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank
FROM staff;






