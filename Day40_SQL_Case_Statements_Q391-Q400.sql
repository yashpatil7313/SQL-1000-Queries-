-- Day 40: CASE Statements
-- Queries: Q391 to Q400
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, department, salary, age, city)

-- =========================================
-- Q391: Categorize employees based on salary
-- =========================================
SELECT emp_name,
       salary,
       CASE
           WHEN salary >= 80000 THEN 'High'
           WHEN salary >= 40000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employee;

-- =========================================
-- Q392: Categorize employees based on age
-- =========================================
SELECT emp_name,
       age,
       CASE
           WHEN age < 25 THEN 'Young'
           WHEN age BETWEEN 25 AND 35 THEN 'Adult'
           ELSE 'Senior'
       END AS age_category
FROM employee;

-- =========================================
-- Q393: Give salary bonus based on department
-- =========================================
SELECT emp_name,
       department,
       salary,
       CASE
           WHEN department = 'IT' THEN salary * 0.15
           WHEN department = 'Sales' THEN salary * 0.10
           WHEN department = 'HR' THEN salary * 0.08
           ELSE salary * 0.05
       END AS bonus
FROM employee;

-- =========================================
-- Q394: Display salary after department-wise increment
-- =========================================
SELECT emp_name,
       department,
       salary,
       CASE
           WHEN department = 'IT' THEN salary * 1.15
           WHEN department = 'Sales' THEN salary * 1.10
           ELSE salary * 1.05
       END AS revised_salary
FROM employee;

-- =========================================
-- Q395: Categorize employees based on city
-- =========================================
SELECT emp_name,
       city,
       CASE
           WHEN city IN ('Mumbai', 'Pune') THEN 'Maharashtra'
           WHEN city = 'Delhi' THEN 'Delhi'
           ELSE 'Other'
       END AS location_category
FROM employee;

-- =========================================
-- Q396: Check whether employees are eligible for promotion
-- =========================================
SELECT emp_name,
       salary,
       age,
       CASE
           WHEN salary >= 60000 AND age >= 25 THEN 'Eligible'
           ELSE 'Not Eligible'
       END AS promotion_status
FROM employee;

-- =========================================
-- Q397: Categorize salary as Low, Medium, or High
-- =========================================
SELECT emp_name,
       salary,
       CASE
           WHEN salary < 30000 THEN 'Low Salary'
           WHEN salary < 60000 THEN 'Medium Salary'
           ELSE 'High Salary'
       END AS salary_level
FROM employee;

-- =========================================
-- Q398: Count employees in each salary category
-- =========================================
SELECT
    CASE
        WHEN salary < 30000 THEN 'Low'
        WHEN salary < 60000 THEN 'Medium'
        ELSE 'High'
    END AS salary_category,
    COUNT(*) AS total_employees
FROM employee
GROUP BY
    CASE
        WHEN salary < 30000 THEN 'Low'
        WHEN salary < 60000 THEN 'Medium'
        ELSE 'High'
    END;

-- =========================================
-- Q399: Sort employees according to salary category
-- =========================================
SELECT emp_name,
       salary,
       CASE
           WHEN salary >= 80000 THEN 'High'
           WHEN salary >= 40000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employee
ORDER BY
    CASE
        WHEN salary >= 80000 THEN 1
        WHEN salary >= 40000 THEN 2
        ELSE 3
    END;

-- =========================================
-- Q400: Create a performance category using salary
-- =========================================
SELECT emp_name,
       salary,
       CASE
           WHEN salary >= 80000 THEN 'Excellent'
           WHEN salary >= 60000 THEN 'Good'
           WHEN salary >= 40000 THEN 'Average'
           ELSE 'Needs Improvement'
       END AS performance_category
FROM employee;
