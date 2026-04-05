-- Day 20: Mixed Revision + Advanced Queries
-- Queries: Q191 to Q200
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q191: Find second highest salary
-- =========================================
SELECT MAX(salary)
FROM staff
WHERE salary < (SELECT MAX(salary) FROM staff);

-- =========================================
-- Q192: Find employees with second highest salary
-- =========================================
SELECT *
FROM staff
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
    WHERE salary < (SELECT MAX(salary) FROM staff)
);

-- =========================================
-- Q193: Find top 5 highest salaries
-- =========================================
SELECT DISTINCT salary
FROM staff
ORDER BY salary DESC
LIMIT 5;

-- =========================================
-- Q194: Find employees whose salary is above overall average
-- =========================================
SELECT *
FROM staff
WHERE salary > (SELECT AVG(salary) FROM staff);

-- =========================================
-- Q195: Find department with lowest average salary
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
ORDER BY AVG(salary) ASC
LIMIT 1;

-- =========================================
-- Q196: Find employees whose salary is higher than previous and lower than next
-- =========================================
SELECT *
FROM (
    SELECT *, 
    LAG(salary) OVER (ORDER BY emp_id) AS prev_salary,
    LEAD(salary) OVER (ORDER BY emp_id) AS next_salary
    FROM staff
) t
WHERE salary > prev_salary AND salary < next_salary;

-- =========================================
-- Q197: Find employees with no duplicate salary
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
-- Q198: Find departments with exactly 2 employees
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
HAVING COUNT(*) = 2;

-- =========================================
-- Q199: Find highest salary in each department
-- =========================================
SELECT dept_id, MAX(salary) AS max_salary
FROM staff
GROUP BY dept_id;

-- =========================================
-- Q200: Find employees whose salary is equal to department max salary
-- =========================================
SELECT *
FROM staff s
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);
