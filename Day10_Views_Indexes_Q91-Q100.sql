-- Day 10: Views & Indexes
-- Queries: Q91 to Q100
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- staff(emp_id, employee_name, salary, department, city)

-- Q91: Create a view to display all employees from IT department
CREATE VIEW it_employees AS
SELECT *
FROM staff
WHERE department = 'IT';

-- Q92: Create a view showing employee name and salary only
CREATE VIEW employee_salary_view AS
SELECT employee_name, salary
FROM staff;

-- Q93: Display data from it_employees view
SELECT * FROM it_employees;

-- Q94: Update salary using view (if updatable)
UPDATE it_employees
SET salary = 60000
WHERE emp_id = 101;

-- Q97: Create a composite index on department and salary
CREATE INDEX idx_department_salary
ON staff(department, salary);

-- Q98: Drop index idx_employee_name (PostgreSQL)
DROP INDEX idx_employee_name;

-- MySQL version:
-- DROP INDEX idx_employee_name ON staff;

-- Q99: Create a unique index on employee_name
CREATE UNIQUE INDEX idx_unique_employee_name
ON staff(employee_name);

-- Q100: Show indexes on staff table (MySQL)
SHOW INDEX FROM staff;

-- ==============================
-- WHY WE USE VIEWS
-- ==============================

-- 1) Security:
-- Views help restrict access to sensitive columns.
-- Example: We can hide salary column and allow users to see only employee_name and department.

-- 2) Simplify Complex Queries:
-- Instead of writing long JOIN queries repeatedly,
-- we can store the query inside a view and reuse it like a virtual table.

-- 3) Logical Abstraction:
-- A view does NOT store data.
-- It stores only the SELECT query.
-- It behaves like a virtual table.

-- 4) Reusability:
-- Frequently used reports or filtered data can be saved as a view.


-- ==============================
-- WHY WE USE INDEXES
-- ==============================

-- 1) Improve Query Performance:
-- Index helps the database find data faster.
-- Without index → Full Table Scan (checks every row).
-- With index → Direct lookup (like book index).

-- 2) Speeds Up:
-- SELECT
-- WHERE
-- JOIN
-- ORDER BY
-- GROUP BY

-- 3) Important Note:
-- Index improves read performance (SELECT)
-- But slightly slows down INSERT, UPDATE, DELETE
-- because index also needs to be updated.

-- 4) Best Practice:
-- Create index on:
-- Frequently searched columns
-- Foreign key columns
-- Columns used in JOIN conditions


-- ==============================
-- INTERVIEW SUMMARY
-- ==============================

-- VIEW  → Used for security and simplifying queries.
-- INDEX → Used for improving performance.



