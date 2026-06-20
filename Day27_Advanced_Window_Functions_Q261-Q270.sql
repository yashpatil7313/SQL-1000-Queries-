-- Day 27: Advanced Window Functions
-- Queries: Q261 to Q270
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q261: Assign row number to each employee
-- =========================================
SELECT emp_id, employee_name, salary,
ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM staff;

-- =========================================
-- Q262: Rank employees by salary
-- =========================================
SELECT emp_id, employee_name, salary,
RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM staff;

-- =========================================
-- Q263: Dense rank employees by salary
-- =========================================
SELECT emp_id, employee_name, salary,
DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank
FROM staff;

-- =========================================
-- Q264: Department-wise row number
-- =========================================
SELECT emp_id, employee_name, dept_id, salary,
ROW_NUMBER() OVER (
    PARTITION BY dept_id
    ORDER BY salary DESC
) AS dept_row_num
FROM staff;

-- =========================================
-- Q265: Department-wise rank
-- =========================================
SELECT emp_id, employee_name, dept_id, salary,
RANK() OVER (
    PARTITION BY dept_id
    ORDER BY salary DESC
) AS dept_rank
FROM staff;

-- =========================================
-- Q266: Department-wise dense rank
-- =========================================
SELECT emp_id, employee_name, dept_id, salary,
DENSE_RANK() OVER (
    PARTITION BY dept_id
    ORDER BY salary DESC
) AS dept_dense_rank
FROM staff;

-- =========================================
-- Q267: Running total of salaries
-- =========================================
SELECT emp_id, employee_name, salary,
SUM(salary) OVER (ORDER BY emp_id) AS running_total
FROM staff;

-- =========================================
-- Q268: Running average salary
-- =========================================
SELECT emp_id, employee_name, salary,
AVG(salary) OVER (ORDER BY emp_id) AS running_avg
FROM staff;

-- =========================================
-- Q269: Previous employee salary
-- =========================================
SELECT emp_id, employee_name, salary,
LAG(salary) OVER (ORDER BY emp_id) AS previous_salary
FROM staff;

-- =========================================
-- Q270: Next employee salary
-- =========================================
SELECT emp_id, employee_name, salary,
LEAD(salary) OVER (ORDER BY emp_id) AS next_salary
FROM staff;
