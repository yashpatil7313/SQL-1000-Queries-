-- Day 34: Date & Time Functions
-- Queries: Q331 to Q340
-- Database: MySQL / PostgreSQL

-- Assumed table:
-- orders(order_id, customer_name, order_date, amount)

-- =========================================
-- Q331: Display today's date
-- =========================================
SELECT CURRENT_DATE;

-- =========================================
-- Q332: Display current date and time
-- =========================================
SELECT NOW();

-- =========================================
-- Q333: Display orders placed today
-- =========================================
SELECT *
FROM orders
WHERE order_date = CURRENT_DATE;

-- =========================================
-- Q334: Display orders placed in the last 7 days
-- =========================================
SELECT *
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL 7 DAY;

-- =========================================
-- Q335: Display year from order_date
-- =========================================
SELECT order_id,
YEAR(order_date) AS order_year
FROM orders;

-- =========================================
-- Q336: Display month from order_date
-- =========================================
SELECT order_id,
MONTH(order_date) AS order_month
FROM orders;

-- =========================================
-- Q337: Display day from order_date
-- =========================================
SELECT order_id,
DAY(order_date) AS order_day
FROM orders;

-- =========================================
-- Q338: Display number of days since each order
-- =========================================
SELECT order_id,
DATEDIFF(CURRENT_DATE, order_date) AS days_passed
FROM orders;

-- =========================================
-- Q339: Display orders placed in the current year
-- =========================================
SELECT *
FROM orders
WHERE YEAR(order_date) = YEAR(CURRENT_DATE);

-- =========================================
-- Q340: Display orders placed in the current month
-- =========================================
SELECT *
FROM orders
WHERE YEAR(order_date) = YEAR(CURRENT_DATE)
AND MONTH(order_date) = MONTH(CURRENT_DATE);
