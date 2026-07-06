-- Day 33: Advanced Subqueries
-- Queries: Q321 to Q330
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- staff(emp_id, employee_name, dept_id, salary)
-- department(dept_id, dept_name)

-- =========================================
-- Q321: Find employees working in departments that have employees earning more than 70000
-- =========================================
SELECT *
FROM staff
WHERE dept_id IN (
    SELECT dept_id
    FROM staff
    WHERE salary > 70000
);

-- =========================================
-- Q322: Find departments that have at least one employee
-- =========================================
SELECT *
FROM department d
WHERE EXISTS (
    SELECT 1
    FROM staff s
    WHERE s.dept_id = d.dept_id
);

-- =========================================
-- Q323: Find departments with no employees
-- =========================================
SELECT *
FROM department d
WHERE NOT EXISTS (
    SELECT 1
    FROM staff s
    WHERE s.dept_id = d.dept_id
);

-- =========================================
-- Q324: Find employees earning more than ANY employee in department 1
-- =========================================
SELECT *
FROM staff
WHERE salary > ANY (
    SELECT salary
    FROM staff
    WHERE dept_id = 1
);

-- =========================================
-- Q325: Find employees earning more than ALL employees in department 1
-- =========================================
SELECT *
FROM staff
WHERE salary > ALL (
    SELECT salary
    FROM staff
    WHERE dept_id = 1
);

-- =========================================
-- Q326: Find employees whose department exists in department table
-- =========================================
SELECT *
FROM staff s
WHERE EXISTS (
    SELECT 1
    FROM department d
    WHERE d.dept_id = s.dept_id
);

-- =========================================
-- Q327: Find employees whose department does not exist
-- =========================================
SELECT *
FROM staff s
WHERE NOT EXISTS (
    SELECT 1
    FROM department d
    WHERE d.dept_id = s.dept_id
);

-- =========================================
-- Q328: Find employees earning above their department average
-- =========================================
SELECT *
FROM staff s
WHERE salary > (
    SELECT AVG(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);

-- =========================================
-- Q329: Find departments where the maximum salary is greater than 80000
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
HAVING MAX(salary) > 80000;

-- =========================================
-- Q330: Find employees with the lowest salary in each department
-- =========================================
SELECT *
FROM staff s
WHERE salary = (
    SELECT MIN(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);
