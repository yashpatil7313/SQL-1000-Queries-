-- Day 30: Stored Procedures & Triggers
-- Queries: Q291 to Q300
-- Database: MySQL

-- Assumed table:
-- staff(emp_id, employee_name, dept_id, salary)

-- =========================================
-- Q291: Create a procedure to display all employees
-- =========================================
DELIMITER //
CREATE PROCEDURE GetAllEmployees()
BEGIN
    SELECT * FROM staff;
END //
DELIMITER ;

-- =========================================
-- Q292: Execute the procedure
-- =========================================
CALL GetAllEmployees();

-- =========================================
-- Q293: Create a procedure to display employees by department
-- =========================================
DELIMITER //
CREATE PROCEDURE GetEmployeesByDept(IN p_dept_id INT)
BEGIN
    SELECT *
    FROM staff
    WHERE dept_id = p_dept_id;
END //
DELIMITER ;

-- =========================================
-- Q294: Execute procedure for department 1
-- =========================================
CALL GetEmployeesByDept(1);

-- =========================================
-- Q295: Create a procedure to count employees
-- =========================================
DELIMITER //
CREATE PROCEDURE GetEmployeeCount()
BEGIN
    SELECT COUNT(*) AS total_employees
    FROM staff;
END //
DELIMITER ;

-- =========================================
-- Q296: Create trigger before insert
-- =========================================
CREATE TRIGGER check_salary
BEFORE INSERT ON staff
FOR EACH ROW
SET NEW.salary = IF(NEW.salary < 0, 0, NEW.salary);

-- =========================================
-- Q297: Create trigger after insert
-- =========================================
CREATE TRIGGER employee_insert_log
AFTER INSERT ON staff
FOR EACH ROW
INSERT INTO employee_log(emp_id, action_type)
VALUES (NEW.emp_id, 'INSERT');

-- =========================================
-- Q298: Show all triggers
-- =========================================
SHOW TRIGGERS;

-- =========================================
-- Q299: Drop trigger
-- =========================================
DROP TRIGGER employee_insert_log;

-- =========================================
-- Q300: Drop procedure
-- =========================================
DROP PROCEDURE GetAllEmployees;
