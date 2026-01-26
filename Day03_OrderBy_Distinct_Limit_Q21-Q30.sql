-- Day 03: ORDER BY, DISTINCT, LIMIT
-- Queries: Q21 to Q30
-- Database: MySQL / PostgreSQL

-- Q21: Display all students ordered by age in ascending order
SELECT * FROM student
ORDER BY age ASC;

-- Q22: Display all students ordered by age in descending order
SELECT * FROM student
ORDER BY age DESC;

-- Q23: Display distinct departments from student table
SELECT DISTINCT department FROM student;

-- Q24: Display students ordered by name alphabetically
SELECT * FROM student 
ORDER BY name ASC;

-- Q25: Display top 2 students based on age
SELECT * FROM student
ORDER BY AGE DESC
LIMIT 2;

-- Q26: Display all employees ordered by salary in ascending order
SELECT * FROM employee
ORDER BY salary ASC;

-- Q27: Display all employees ordered by salary in descending order
SELECT * FROM employee
ORDER BY salary DESC;

-- Q28: Display distinct cities from employee table
SELECT DISTINCT city FROM employee;

-- Q29: Display top 3 highest paid employees
SELECT * FROM employee
ORDER BY salary DESC
LIMIT 3;

-- Q30: Display employees ordered by name alphabetically
SELECT * FROM employee
ORDER BY emp_name ASC;








