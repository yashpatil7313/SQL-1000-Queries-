-- Day 08: SQL Constraints
-- Queries: Q71 to Q80
-- Database: MySQL / PostgreSQL

-- Q71: Create student table with PRIMARY KEY
CREATE TABLE student (
    student_id INT PRIMARY KEY,  -- A PRIMARY KEY is a column, or a set of columns, in a table that uniquely identifies each row (record) in that table.
    name VARCHAR(50),
    age INT,
    department VARCHAR(30)
);

-- Q72: Create employee table with NOT NULL constraint
CREATE TABLE employee (
    emp_id INT,
    emp_name VARCHAR(50) NOT NULL,
    salary INT,
    department VARCHAR(30)
);

-- Q73: Create table with UNIQUE constraint on email
CREATE TABLE users (
    user_id INT,
    email VARCHAR(100) UNIQUE,
    password VARCHAR(50)
);

-- Q74: Create table with CHECK constraint on salary
CREATE TABLE staff (
    staff_id INT,
    staff_name VARCHAR(50),
    salary INT CHECK (salary > 0)
);

-- Q75: Create table with DEFAULT constraint
CREATE TABLE orders (
    order_id INT,
    order_date DATE DEFAULT CURRENT_DATE
);


-- Q76: Create table with FOREIGN KEY constraint
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(30)
);

CREATE TABLE employee_details (
    emp_id INT,
    emp_name VARCHAR(50),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- Q77: Add PRIMARY KEY constraint to existing table
ALTER TABLE employee
ADD PRIMARY KEY (emp_id);

-- Q78: Add UNIQUE constraint to emp_name column
ALTER TABLE employee
ADD UNIQUE (emp_name);

-- Q79: Drop UNIQUE constraint from emp_name
ALTER TABLE employee
DROP CONSTRAINT emp_name;

ALTER TABLE employee
DROP INDEX emp_name;

-- Q80: Drop table with constraints
DROP TABLE staff;






