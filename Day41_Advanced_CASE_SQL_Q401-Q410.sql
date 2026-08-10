-- Day 41: Advanced CASE SQL
-- Queries: Q401 to Q410
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- employee(emp_id, emp_name, department, salary, age, city)

-- =========================================
-- Q401: Categorize employees by salary and age
-- =========================================
SELECT emp_name,
       salary,
       age,
       CASE
           WHEN salary >= 60000 AND age >= 30 THEN 'Senior High Earner'
           WHEN salary >= 60000 THEN 'High Earner'
           WHEN age >= 30 THEN 'Experienced'
           ELSE 'Junior'
       END AS employee_category
FROM employee;

-- =========================================
-- Q402: Calculate bonus based on salary
-- =========================================
SELECT emp_name,
       salary,
       CASE
           WHEN salary >= 80000 THEN salary * 0.20
           WHEN salary >= 50000 THEN salary * 0.15
           WHEN salary >= 30000 THEN salary * 0.10
           ELSE salary * 0.05
       END AS bonus
FROM employee;

-- =========================================
-- Q403: Calculate salary after bonus
-- =========================================
SELECT emp_name,
       salary,
       salary +
       CASE
           WHEN salary >= 80000 THEN salary * 0.20
           WHEN salary >= 50000 THEN salary * 0.15
           ELSE salary * 0.10
       END AS final_salary
FROM employee;

-- =========================================
-- Q404: Categorize employees by department
-- =========================================
SELECT emp_name,
       department,
       CASE department
           WHEN 'IT' THEN 'Technical'
           WHEN 'HR' THEN 'Management'
           WHEN 'Sales' THEN 'Business'
           ELSE 'Other'
       END AS department_type
FROM employee;

-- =========================================
-- Q405: Determine promotion eligibility
-- =========================================
SELECT emp_name,
       salary,
       age,
       CASE
           WHEN salary >= 70000 AND age >= 30 THEN 'Eligible'
           WHEN salary >= 50000 AND age >= 25 THEN 'Consider'
           ELSE 'Not Eligible'
       END AS promotion_status
FROM employee;

-- =========================================
-- Q406: Categorize employees by salary range
-- =========================================
SELECT emp_name,
       salary,
       CASE
           WHEN salary < 25000 THEN 'Below 25K'
           WHEN salary < 50000 THEN '25K-49K'
           WHEN salary < 75000 THEN '50K-74K'
           ELSE '75K+'
       END AS salary_range
FROM employee;

-- =========================================
-- Q407: Count employees in each salary category
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
-- Q408: Calculate tax based on salary
-- =========================================
SELECT emp_name,
       salary,
       CASE
           WHEN salary >= 100000 THEN salary * 0.20
           WHEN salary >= 60000 THEN salary * 0.15
           WHEN salary >= 30000 THEN salary * 0.10
           ELSE 0
       END AS estimated_tax
FROM employee;

-- =========================================
-- Q409: Display employee experience category
-- =========================================
SELECT emp_name,
       age,
       CASE
           WHEN age >= 40 THEN 'Highly Experienced'
           WHEN age >= 30 THEN 'Experienced'
           WHEN age >= 25 THEN 'Intermediate'
           ELSE 'Fresher'
       END AS experience_category
FROM employee;

-- =========================================
-- Q410: Create an overall employee status
-- =========================================
SELECT emp_name,
       salary,
       age,
       department,
       CASE
           WHEN salary >= 80000 AND age >= 30
                THEN 'Top Performer'
           WHEN salary >= 50000 AND age >= 25
                THEN 'Good Performer'
           WHEN salary >= 30000
                THEN 'Average Performer'
           ELSE 'Needs Improvement'
       END AS employee_status
FROM employee;
