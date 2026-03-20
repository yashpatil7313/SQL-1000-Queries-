-- Day 16: Subqueries & Advanced SQL
-- Queries: Q151 to Q160
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q151: Employees earning more than average salary
-- =========================================
SELECT *
FROM staff
WHERE salary > (SELECT AVG(salary) FROM staff);

-- =========================================
-- Q152: Employees with highest salary
-- =========================================
SELECT *
FROM staff
WHERE salary = (SELECT MAX(salary) FROM staff);



