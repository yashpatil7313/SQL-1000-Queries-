-- Day 12: Subqueries
-- Queries: Q111 to Q120
-- Database: MySQL / PostgreSQL

-- Assumed tables:
-- staff(emp_id, employee_name, salary, dept_id)
-- department(dept_id, dept_name)

-- Q111: Display employees whose salary is greater than the average salary
SELECT *
FROM staff
WHERE salary > (SELECT AVG(salary) FROM staff);

-- Q112: Find employees in the department with dept_id = 2
SELECT *
FROM staff
WHERE dept_id = (SELECT dept_id FROM department WHERE dept_name = 'IT');

-- Q113: Display employees whose salary is equal to maximum salary
SELECT *
FROM staff
WHERE salary = (SELECT MAX(salary) FROM staff);

-- Q114: List departments having more than 2 employees using subquery
SELECT *
FROM department
WHERE dept_id IN (
    SELECT dept_id
    FROM staff
    GROUP BY dept_id
    HAVING COUNT(emp_id) > 2
);

-- Q115: Display employees earning more than the employee with emp_id = 101
SELECT *
FROM staff
WHERE salary > (SELECT salary FROM staff WHERE emp_id = 101);

-- Q116: Display employees not in IT department using subquery
SELECT *
FROM staff
WHERE dept_id NOT IN (SELECT dept_id FROM department WHERE dept_name = 'IT');

-- Q117: Display employee names along with department names using subquery in SELECT
SELECT employee_name,
       (SELECT dept_name FROM department d WHERE d.dept_id = s.dept_id) AS department_name
FROM staff s;

-- Q118: Display employees whose salary is between min and max salary
SELECT *
FROM staff
WHERE salary BETWEEN 
      (SELECT MIN(salary) FROM staff) 
      AND 
      (SELECT MAX(salary) FROM staff);

-- Q119: Find employees whose salary is greater than the average salary of their department
SELECT *
FROM staff s
WHERE salary > (SELECT AVG(salary) FROM staff WHERE dept_id = s.dept_id);

-- Q120: Count employees in each department using subquery
SELECT dept_name,
       (SELECT COUNT(*) FROM staff s WHERE s.dept_id = d.dept_id) AS total_employees
FROM department d;







