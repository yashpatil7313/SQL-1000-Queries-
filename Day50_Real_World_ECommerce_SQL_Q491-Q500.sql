-- Day 50: Real-World E-Commerce SQL
-- Queries: Q491 to Q500
-- Database: MySQL / PostgreSQL

-- Assumed tables:
--
-- customers(
--     customer_id,
--     customer_name,
--     city
-- )
--
-- products(
--     product_id,
--     product_name,
--     category,
--     price
-- )
--
-- orders(
--     order_id,
--     customer_id,
--     order_date,
--     status
-- )
--
-- order_items(
--     order_id,
--     product_id,
--     quantity,
--     price
-- )


-- =========================================
-- Q491: Display all orders with customer names
-- =========================================
SELECT o.order_id,
       c.customer_name,
       o.order_date,
       o.status
FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id;


-- =========================================
-- Q492: Find total amount of each order
-- =========================================
SELECT order_id,
       SUM(quantity * price) AS order_total
FROM order_items
GROUP BY order_id;


-- =========================================
-- Q493: Find total spending of each customer
-- =========================================
SELECT o.customer_id,
       SUM(oi.quantity * oi.price) AS total_spending
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id;


-- =========================================
-- Q494: Find customers who spent more than 50000
-- =========================================
SELECT o.customer_id,
       SUM(oi.quantity * oi.price) AS total_spending
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
HAVING SUM(oi.quantity * oi.price) > 50000;


-- =========================================
-- Q495: Find the top 5 customers by spending
-- =========================================
SELECT o.customer_id,
       SUM(oi.quantity * oi.price) AS total_spending
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spending DESC
LIMIT 5;


-- =========================================
-- Q496: Find the best-selling products by quantity
-- =========================================
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity) AS total_quantity
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity DESC;


-- =========================================
-- Q497: Find total revenue for each product
-- =========================================
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;


-- =========================================
-- Q498: Find customers who have never placed an order
-- =========================================
SELECT c.customer_id,
       c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- =========================================
-- Q499: Find the highest-revenue product
-- =========================================
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity * oi.price) AS total_revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 1;


-- =========================================
-- Q500: Find monthly revenue
-- =========================================
SELECT YEAR(o.order_date) AS order_year,
       MONTH(o.order_date) AS order_month,
       SUM(oi.quantity * oi.price) AS monthly_revenue
FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY order_year, order_month;
