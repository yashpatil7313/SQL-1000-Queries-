-- Day 02: WHERE Clause and Conditions
-- Queries: Q11 to Q20
-- Database: MySQL / PostgreSQL

-- Q11: Display students whose age is greater than 20
SELECT * FROM Student 
WHERE age > 20;

-- Q12: Display students from CSE department
SELECT * FROM Student
WHERE Department = 'CSE';

-- Q13: Display students whose age is less than or equal to 20
SELECT * FROM student
WHERE Age <= 20;

-- Q14: Display students whose department is IT or ENTC
SELECT * FROM Student
WHERE department = 'IT' OR department = 'ENTC';

-- Q15: Display students whose age is greater than 18 and department is CSE
SELECT * FROM Student 
WHERE age > 18 AND department = 'CSE';

-- Q16: Display employees from Pune city
SELECT * FROM employee
WHERE city = 'Pune';

-- Q17: Display employees with salary greater than 30000
SELECT * FROM employee
WHERE salary > 30000;

-- Q18: Display employees whose city is Mumbai or Pune
SELECT * FROM employee
WHERE city = 'Mumbai' OR city = 'Pune';

-- Q19: Display employees with salary between 30000 and 50000
SELECT * FROM employee
WHERE salary >= 30000 AND salary <= 50000;

-- Q20: Display employees whose salary is not equal to 40000
SELECT * FROM employee
WHERE salary <> 40000;





