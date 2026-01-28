-- Day 04: WHERE, AND, OR, BETWEEN, IN
-- Queries: Q31 to Q40
-- Database: MySQL / PostgreSQL

-- Q31: Display all employees whose salary is greater than 30000
SELECT * FROM employee
WHERE salary > 30000;

-- Q32: Display employees who belong to IT department
SELECT * FROM employee
WHERE department = 'IT';

-- Q33: Display employees whose age is between 25 and 35
SELECT * FROM employee
WHERE age BETWEEN 25 AND 35;

-- Q34: Display employees who live in Mumbai or Pune
SELECT * FROM employee
WHERE city = 'Mumbai' OR city = 'Pune';

-- Q35: Display employees who are not from HR department
SELECT * FROM employee
WHERE department != 'HR';

-- Q36: Display employees whose salary is greater than 25000 and department is Sales
SELECT * FROM employee
WHERE salary > 25000 AND department = 'sales';

-- Q37: Display employees who belong to HR, IT, or Finance department
SELECT * FROM employee
WHERE department IN ('HR', 'IT', 'Finance');

-- Q38: Display employees whose salary is NOT between 20000 and 40000
SELECT * FROM employee
WHERE salary NOT BETWEEN 20000 AND 40000;

-- Q39: Display employees whose name starts with 'A'
SELECT * FROM employee
WHERE emp_name LIKE 'A%';

-- Q40: Display employees whose city is not Delhi
SELECT * FROM employee 
WHERE city <> 'Delhi';












