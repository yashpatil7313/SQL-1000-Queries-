-- Day 15: CTE (Common Table Expressions)
-- Queries: Q141 to Q150
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q141: Basic CTE to display all employees
-- =========================================
WITH employee_cte AS (
    SELECT * FROM staff
)
SELECT * FROM employee_cte;


-- =========================================
-- Q142: CTE to filter employees with salary > 50000
-- =========================================
WITH high_salary AS (
    SELECT * FROM staff WHERE salary > 50000
)
SELECT * FROM high_salary;


-- =========================================
-- Q143: CTE with JOIN
-- =========================================
-- department(dept_id, dept_name)
WITH emp_dept AS (
    SELECT s.employee_name, d.dept_name, s.salary
    FROM staff s
    JOIN department d ON s.dept_id = d.dept_id
)
SELECT * FROM emp_dept;


-- =========================================
-- Q144: CTE with aggregate function
-- =========================================
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM staff
    GROUP BY dept_id
)
SELECT * FROM dept_avg;


-- =========================================
-- Q145: Employees earning more than department average
-- =========================================
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) AS avg_salary
    FROM staff
    GROUP BY dept_id
)
SELECT s.*
FROM staff s
JOIN dept_avg d ON s.dept_id = d.dept_id
WHERE s.salary > d.avg_salary;


-- =========================================
-- Q146: Multiple CTEs
-- =========================================
WITH high_salary AS (
    SELECT * FROM staff WHERE salary > 50000
),
low_salary AS (
    SELECT * FROM staff WHERE salary <= 50000
)
SELECT * FROM high_salary
UNION
SELECT * FROM low_salary;


-- =========================================
-- Q147: CTE with ranking (Top 3 salaries)
-- =========================================
WITH ranked_emp AS (
    SELECT emp_id, employee_name, salary,
    RANK() OVER (ORDER BY salary DESC) AS r
    FROM staff
)
SELECT * FROM ranked_emp WHERE r <= 3;


-- =========================================
-- Q148: CTE for running total
-- =========================================
WITH running_total_cte AS (
    SELECT emp_id, employee_name, salary,
    SUM(salary) OVER (ORDER BY emp_id) AS total
    FROM staff
)
SELECT * FROM running_total_cte;


-- =========================================
-- Q149: CTE with LAG function
-- =========================================
WITH lag_cte AS (
    SELECT emp_id, employee_name, salary,
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary
    FROM staff
)
SELECT * FROM lag_cte;


-- =========================================
-- Q150: Recursive CTE (Basic Example)
-- =========================================
WITH RECURSIVE numbers AS (
    SELECT 1 AS num
    UNION ALL
    SELECT num + 1 FROM numbers WHERE num < 5
)
SELECT * FROM numbers;

