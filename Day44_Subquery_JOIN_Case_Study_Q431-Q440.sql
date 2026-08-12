-- Day 44: Subquery + JOIN Case Study
-- Queries: Q431 to Q440
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- employee(emp_id, emp_name, department, salary)
-- department(dept_id, department)

-- =========================================
-- Q431: Find employees earning more than company average
-- =========================================
SELECT *
FROM employee
WHERE salary > (
    SELECT AVG(salary)
    FROM employee
);

-- =========================================
-- Q432: Find employees earning more than department average
-- =========================================
SELECT *
FROM employee e
WHERE salary > (
    SELECT AVG(salary)
    FROM employee
    WHERE department = e.department
);

-- =========================================
-- Q433: Find employees with the highest salary in their department
-- =========================================
SELECT *
FROM employee e
WHERE salary = (
    SELECT MAX(salary)
    FROM employee
    WHERE department = e.department
);

-- =========================================
-- Q434: Find employees with the lowest salary in their department
-- =========================================
SELECT *
FROM employee e
WHERE salary = (
    SELECT MIN(salary)
    FROM employee
    WHERE department = e.department
);

-- =========================================
-- Q435: Find departments having at least one employee earning above 80000
-- =========================================
SELECT DISTINCT d.department
FROM department d
INNER JOIN employee e
    ON e.department = d.department
WHERE e.salary > 80000;

-- =========================================
-- Q436: Find departments whose average salary is greater than company average
-- =========================================
SELECT d.department,
       AVG(e.salary) AS average_salary
FROM department d
INNER JOIN employee e
    ON e.department = d.department
GROUP BY d.department
HAVING AVG(e.salary) > (
    SELECT AVG(salary)
    FROM employee
);

-- =========================================
-- Q437: Find employees working in departments having more than 3 employees
-- =========================================
SELECT *
FROM employee
WHERE department IN (
    SELECT department
    FROM employee
    GROUP BY department
    HAVING COUNT(*) > 3
);

-- =========================================
-- Q438: Find employees whose salary is greater than every employee in IT
-- =========================================
SELECT *
FROM employee
WHERE salary > ALL (
    SELECT salary
    FROM employee
    WHERE department = 'IT'
);

-- =========================================
-- Q439: Find employees whose salary is greater than at least one employee in IT
-- =========================================
SELECT *
FROM employee
WHERE salary > ANY (
    SELECT salary
    FROM employee
    WHERE department = 'IT'
);

-- =========================================
-- Q440: Find departments with no employees
-- =========================================
SELECT d.department
FROM department d
LEFT JOIN employee e
    ON e.department = d.department
WHERE e.emp_id IS NULL;
