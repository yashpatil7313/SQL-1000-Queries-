-- Day 07: Subqueries
-- Queries: Q61 to Q70
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, department, salary)

-- Q61: Display employees whose salary is greater than the average salary
SELECT *
FROM employee
WHERE salary > (
    SELECT AVG(salary)
    FROM employee
);

-- Q62: Display employees who earn the maximum salary
SELECT * 
FROM employee
WHERE salary = (
    SELECT MAX(salary)
    FROM employee
);

-- Q63: Display employees who belong to the same department as 'Rahul'
SELECT *
FROM employee
WHERE department = (
    SELECT department
    FROM employee
    WHERE emp_name = 'Rahul'
);

-- Q64: Display employees whose salary is less than the salary of 'Amit'
SELECT *
FROM employee
WHERE salary < (
    SELECT salary
    FROM employee
    WHERE emp_name = 'Amit'
);

-- Q65: Display employees who work in departments having more than 2 employees
SELECT *
FROM employee
WHERE department IN (
    SELECT department
    FROM employee
    GROUP BY department
    HAVING COUNT(*) > 2
);









