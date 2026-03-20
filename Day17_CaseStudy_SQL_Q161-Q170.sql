-- Day 17: Case Study SQL (Real-world Problems)
-- Queries: Q161 to Q170
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)
-- department(dept_id, dept_name)

-- =========================================
-- Q161: Top 3 highest paid employees
-- =========================================
SELECT *
FROM staff
ORDER BY salary DESC
LIMIT 3;

-- =========================================
-- Q162: Highest paid employee in each department
-- =========================================
SELECT *
FROM (
    SELECT *, 
    RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r = 1;

-- =========================================
-- Q163: Employees earning more than their department average
-- =========================================
SELECT *
FROM (
    SELECT *, 
    AVG(salary) OVER (PARTITION BY dept_id) AS avg_sal
    FROM staff
) t
WHERE salary > avg_sal;

-- =========================================
-- Q164: Second highest salary in each department
-- =========================================
SELECT *
FROM (
    SELECT *, 
    DENSE_RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS r
    FROM staff
) t
WHERE r = 2;

-- =========================================
-- Q165: Total salary paid in each department
-- =========================================
SELECT dept_id, SUM(salary) AS total_salary
FROM staff
GROUP BY dept_id;

-- =========================================
-- Q166: Department with highest total salary
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
ORDER BY SUM(salary) DESC
LIMIT 1;

-- =========================================
-- Q167: Employees who share same salary
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
-- Q168: Employees not assigned to any department
-- =========================================
SELECT *
FROM staff s
LEFT JOIN department d ON s.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- =========================================
-- Q169: Running total of salary department-wise
-- =========================================
SELECT emp_id, employee_name, dept_id, salary,
SUM(salary) OVER (PARTITION BY dept_id ORDER BY emp_id) AS running_total
FROM staff;

-- =========================================
-- Q170: Rank employees globally based on salary
-- =========================================
SELECT emp_id, employee_name, salary,
RANK() OVER (ORDER BY salary DESC) AS global_rank
FROM staff;
