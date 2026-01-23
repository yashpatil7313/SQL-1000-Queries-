-- Q1: Create a student table
CREATE TABLE student (
    student_id INT PRIMARY KEY,   -- Unique student ID
    name VARCHAR(50),             -- Student name
    age INT,                      -- Student age
    department VARCHAR(30)        -- Student department
);

-- Q2: Insert one record into student table
INSERT INTO student VALUES (1, 'YASH', 21, 'CSE');

-- Q3: Insert multiple records into student table
INSERT INTO student VALUES
(2, 'ANIKET', 20, 'IT'),
(3, 'Rohit', 22, 'ENTC');

-- Q4: Display all records from student table
SELECT * FROM student;

-- Q5: Display only name and department
SELECT name,department FROM student;

-- Q6: Create an employee table
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,   -- Employee ID   
    emp_name VARCHAR(50),     -- Employee name
    salary INT,               -- Employee salary
    city VARCHAR(30)          -- Employee city
);

-- Q7: Insert data into employee table
INSERT INTO employee VALUES
(101, 'Rahul', 30000, 'Pune'),
(102, 'Sneha', 40000, 'Mumbai');

-- Q8: Display all employees
SELECT * FROM employee;

-- Q9: Display employees with salary greater than 35000
SELECT * FROM employee WHERE salary > 35000;

-- Q10: Count total employees
SELECT COUNT(*) AS total_employees FROM employee;








