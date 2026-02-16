-- Day 09: ALTER, UPDATE, DELETE
-- Queries: Q81 to Q90
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, salary, department)

-- Q81: Add a new column 'age' to employee table
ALTER TABLE employee 
ADD AGE INT;

-- Q82: Add a new column 'city' with default value 'Mumbai'
ALTER TABLE employee
ADD city VARCHAR(30) DEFAULT 'Mumbai';

-- Q83: Modify salary column to BIGINT (MySQL)
ALTER TABLE employee
MODIFY salary BIGINT;

-- PostgreSQL version:
-- ALTER TABLE employee
-- ALTER COLUMN salary TYPE BIGINT;

-- Q84: Rename column emp_name to employee_name (PostgreSQL)
ALTER TABLE employee
RENAME COLUMN emp_name TO employee_name;

-- MySQL version:
-- ALTER TABLE employee
-- CHANGE emp_name employee_name VARCHAR(50);

-- Q85: Rename table employee to staff
ALTER TABLE employee
RENAME TO staff;

ALTER TABLE employee
RENAME TO staff;

-- Q86: Update salary of employee where emp_id = 101
UPDATE staff
SET salary = 50000
WHERE emp_id = 101;

-- Q87: Increase salary by 10% for employees in IT department
UPDATE staff
SET salary = salary + (salary * 0.10)
WHERE department = 'IT';

-- Q88: Delete employee whose emp_id = 105
DELETE FROM staff
WHERE emp_id = 105;

-- Q89: Delete employees who belong to HR department
DELETE FROM staff
WHERE department = 'HR';

-- Q90: Delete all records from staff table
DELETE FROM staff;
