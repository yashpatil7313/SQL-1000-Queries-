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

-- Q134: Rank employees department-wise
SELECT emp_id, employee_name, dept_id, salary,
RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank
FROM staff;

-- Q135: Running total of salary
SELECT emp_id, employee_name, salary,
SUM(salary) OVER (ORDER BY emp_id) AS running_total
FROM staff;

-- Q136: Company average salary
SELECT emp_id, employee_name, salary,
AVG(salary) OVER () AS company_avg_salary
FROM staff;

-- Q137: Department-wise average salary
SELECT emp_id, employee_name, dept_id, salary,
AVG(salary) OVER (PARTITION BY dept_id) AS dept_avg_salary
FROM staff;

-- Q138: Previous salary using LAG
SELECT emp_id, employee_name, salary,
LAG(salary) OVER (ORDER BY emp_id) AS previous_salary
FROM staff;

-- Q139: Next salary using LEAD
SELECT emp_id, employee_name, salary,
LEAD(salary) OVER (ORDER BY emp_id) AS next_salary
FROM staff;

-- Q140: Difference between current and previous salary
SELECT emp_id, employee_name, salary,
salary - LAG(salary) OVER (ORDER BY emp_id) AS salary_difference
FROM staff;







