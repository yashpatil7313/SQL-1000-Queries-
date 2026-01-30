-- Day 05: GROUP BY & HAVING
-- Queries: Q41 to Q50
-- Database: MySQL / PostgreSQL

-- Q41: Display total salary of all employees grouped by department
SELECT department, SUM(salary) AS total_salary
FROM employee
GROUP BY department;

-- Q42: Display average salary of employees in each department
SELECT department, AVG(salary) AS average_salary
FROM employee
GROUP BY department;

-- Q43: Count number of employees in each department
SELECT department, COUNT(*) AS employees
FROM employee
GROUP BY department;

-- Q44: Display maximum salary in each department
SELECT department, MAX(salary) AS maximum_salary
FROM employee
GROUP BY department;

-- Q45: Display minimum salary in each department
SELECT department, MIN(salary) AS minimum_salary
FROM employee
GROUP BY department;

-- Q46: Display departments having more than 3 employees
SELECT department, COUNT(*) AS total_employees
FROM employee
GROUP BY department
HAVING COUNT(*) > 3;

-- Q47: Display departments where total salary is greater than 100000
SELECT department, SUM(salary) AS total_salary
FROM employee
GROUP BY department
HAVING Salary > 100000;

-- Q48: Display departments with average salary greater than 40000
SELECT department, AVG(salary) AS avg_salary
FROM employee
GROUP BY department
HAVING AVG(salary) > 40000;

-- Q49: Display departments with minimum salary less than 20000
SELECT department, MIN(salary) AS min_salary
FROM employee
GROUP BY department
HAVING MIN(salary) < 20000;

-- Q50: Display departments with maximum salary greater than 60000
SELECT department, MAX(salary) AS max_salary
FROM employee
GROUP BY department
HAVING MAX(salary) > 60000;


















