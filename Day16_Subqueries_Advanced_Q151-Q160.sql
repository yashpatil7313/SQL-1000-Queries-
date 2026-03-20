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

-- =========================================
-- Q153: Employees with second highest salary
-- =========================================
SELECT *
FROM staff
WHERE salary = (
    SELECT MAX(salary)
    FROM staff
    WHERE salary < (SELECT MAX(salary) FROM staff)
);

-- =========================================
-- Q154: Employees earning more than department average
-- =========================================
SELECT *
FROM staff s
WHERE salary > (
    SELECT AVG(salary)
    FROM staff
    WHERE dept_id = s.dept_id
);

-- =========================================
-- Q155: Departments with highest average salary
-- =========================================
SELECT dept_id
FROM staff
GROUP BY dept_id
HAVING AVG(salary) = (
    SELECT MAX(avg_salary)
    FROM (
        SELECT AVG(salary) AS avg_salary
        FROM staff
        GROUP BY dept_id
    ) t
);

-- =========================================
-- Q156: Employees whose salary exists in another department
-- =========================================
SELECT *
FROM staff s1
WHERE EXISTS (
    SELECT 1
    FROM staff s2
    WHERE s1.salary = s2.salary
    AND s1.dept_id <> s2.dept_id
);

-- =========================================
-- Q157: Employees with salary greater than all employees in dept 10
-- =========================================
SELECT *
FROM staff
WHERE salary > ALL (
    SELECT salary
    FROM staff
    WHERE dept_id = 10
);

-- =========================================
-- Q158: Employees with salary greater than any employee in dept 10
-- =========================================
SELECT *
FROM staff
WHERE salary > ANY (
    SELECT salary
    FROM staff
    WHERE dept_id = 10
);

-- =========================================
-- Q159: Employees not in department table
-- =========================================
-- department(dept_id, dept_name)

SELECT *
FROM staff
WHERE dept_id NOT IN (
    SELECT dept_id FROM department
);

-- =========================================
-- Q160: Employees with duplicate salaries
-- =========================================
SELECT *
FROM staff
WHERE salary IN (
    SELECT salary
    FROM staff
    GROUP BY salary
    HAVING COUNT(*) > 1
);

