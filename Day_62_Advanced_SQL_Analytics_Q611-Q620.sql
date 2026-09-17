-- ============================================================
-- Day 62: Advanced SQL Analytics & Interview Challenges
-- Queries: Q611 to Q620
-- Database: MySQL / PostgreSQL
--
-- Assumed Tables:
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
--     price,
--     cost_price
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
-- ============================================================


-- ============================================================
-- Q611: Customers With More Than One Order on the Same Day
-- ============================================================
-- Task:
-- Find customers who placed more than one order
-- on the same day.
--
-- Concepts:
-- GROUP BY
-- HAVING
-- COUNT()
-- ============================================================

SELECT
    customer_id,
    order_date,
    COUNT(*) AS order_count

FROM orders

GROUP BY
    customer_id,
    order_date

HAVING COUNT(*) > 1

ORDER BY
    customer_id,
    order_date;


-- ============================================================
-- Q612: Highest-Revenue Category in Each Month
-- ============================================================
-- Task:
-- Find the category generating the highest revenue
-- in each month.
--
-- Concepts:
-- DENSE_RANK()
-- PARTITION BY
-- Monthly Revenue Analysis
-- CTE
-- ============================================================

WITH monthly_category_revenue AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        p.category,

        SUM(oi.quantity * oi.price) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date),
        p.category
),

ranked_categories AS (

    SELECT
        order_year,
        order_month,
        category,
        revenue,

        DENSE_RANK() OVER (
            PARTITION BY order_year, order_month
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM monthly_category_revenue
)

SELECT
    order_year,
    order_month,
    category,
    revenue

FROM ranked_categories

WHERE revenue_rank = 1

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q613: First and Second Order of Every Customer
-- ============================================================
-- Task:
-- Find the first and second order of every customer.
--
-- Concepts:
-- ROW_NUMBER()
-- CASE
-- Conditional Aggregation
-- CTE
-- ============================================================

WITH ranked_orders AS (

    SELECT
        customer_id,
        order_id,
        order_date,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS order_number

    FROM orders
)

SELECT
    customer_id,

    MAX(
        CASE
            WHEN order_number = 1
            THEN order_id
        END
    ) AS first_order_id,

    MAX(
        CASE
            WHEN order_number = 1
            THEN order_date
        END
    ) AS first_order_date,

    MAX(
        CASE
            WHEN order_number = 2
            THEN order_id
        END
    ) AS second_order_id,

    MAX(
        CASE
            WHEN order_number = 2
            THEN order_date
        END
    ) AS second_order_date

FROM ranked_orders

GROUP BY
    customer_id

ORDER BY
    customer_id;


-- ============================================================
-- Q614: Customers Who Returned After Their First Order
-- ============================================================
-- Task:
-- Find customers who placed at least one additional
-- order after their first order.
--
-- Concepts:
-- COUNT()
-- MIN()
-- MAX()
-- Customer Retention
-- ============================================================

WITH customer_orders AS (

    SELECT
        customer_id,

        COUNT(*) AS total_orders,

        MIN(order_date) AS first_order_date,

        MAX(order_date) AS latest_order_date

    FROM orders

    GROUP BY
        customer_id
)

SELECT
    customer_id,
    total_orders,
    first_order_date,
    latest_order_date

FROM customer_orders

WHERE total_orders > 1

ORDER BY
    customer_id;


-- ============================================================
-- Q615: Monthly Revenue Running Total
-- ============================================================
-- Task:
-- Calculate monthly revenue and cumulative revenue
-- from the beginning of the available data.
--
-- Concepts:
-- Window SUM()
-- Running Total
-- CTE
-- Time-Series Analysis
-- ============================================================

WITH monthly_revenue AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,

        SUM(oi.quantity * oi.price) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
)

SELECT
    order_year,
    order_month,
    revenue,

    SUM(revenue) OVER (
        ORDER BY order_year, order_month
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS cumulative_revenue

FROM monthly_revenue

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q616: Products With Revenue Above Category Average
-- ============================================================
-- Task:
-- Find products whose revenue is greater than
-- the average product revenue of their category.
--
-- Concepts:
-- Window AVG()
-- PARTITION BY
-- CTE
-- Category Benchmarking
-- ============================================================

WITH product_revenue AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(oi.quantity * oi.price) AS revenue

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),

category_analysis AS (

    SELECT
        product_id,
        product_name,
        category,
        revenue,

        AVG(revenue) OVER (
            PARTITION BY category
        ) AS category_average_revenue

    FROM product_revenue
)

SELECT
    product_id,
    product_name,
    category,
    revenue,
    category_average_revenue

FROM category_analysis

WHERE revenue > category_average_revenue

ORDER BY
    category,
    revenue DESC;


-- ============================================================
-- Q617: Customers Who Purchased From Multiple Categories
-- ============================================================
-- Task:
-- Find customers who purchased products from
-- at least 3 different categories.
--
-- Concepts:
-- COUNT(DISTINCT)
-- GROUP BY
-- HAVING
-- Customer Behavior Analysis
-- ============================================================

SELECT
    o.customer_id,

    COUNT(DISTINCT p.category)
        AS category_count

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY
    o.customer_id

HAVING COUNT(DISTINCT p.category) >= 3

ORDER BY
    category_count DESC;


-- ============================================================
-- Q618: Most Expensive Product Purchased by Each Customer
-- ============================================================
-- Task:
-- Find the most expensive product purchased by each
-- customer.
--
-- If multiple products have the same highest price,
-- return all tied products.
--
-- Concepts:
-- DENSE_RANK()
-- PARTITION BY
-- Customer-Level Ranking
-- ============================================================

WITH purchased_products AS (

    SELECT DISTINCT
        o.customer_id,
        p.product_id,
        p.product_name,
        p.price

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id
),

ranked_products AS (

    SELECT
        customer_id,
        product_id,
        product_name,
        price,

        DENSE_RANK() OVER (
            PARTITION BY customer_id
            ORDER BY price DESC
        ) AS price_rank

    FROM purchased_products
)

SELECT
    customer_id,
    product_id,
    product_name,
    price

FROM ranked_products

WHERE price_rank = 1

ORDER BY
    customer_id;


-- ============================================================
-- Q619: Latest Order Value Above Customer Average
-- ============================================================
-- Task:
-- Find customers whose latest order value is greater
-- than their average order value.
--
-- Concepts:
-- ROW_NUMBER()
-- AVG() OVER()
-- PARTITION BY
-- Multiple Window Functions
-- ============================================================

WITH order_values AS (

    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,

        SUM(oi.quantity * oi.price)
            AS order_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.customer_id,
        o.order_id,
        o.order_date
),

analysis AS (

    SELECT
        customer_id,
        order_id,
        order_date,
        order_value,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS latest_order_rank,

        AVG(order_value) OVER (
            PARTITION BY customer_id
        ) AS average_order_value

    FROM order_values
)

SELECT
    customer_id,
    order_id,
    order_date,
    order_value,
    average_order_value

FROM analysis

WHERE latest_order_rank = 1

  AND order_value > average_order_value

ORDER BY
    order_value DESC;


-- ============================================================
-- Q620: Customer Purchase Cohort by First Order Month
-- ============================================================
-- Task:
-- Assign every customer to the month in which they
-- placed their first order.
--
-- Then calculate the number of customers in each cohort.
--
-- Concepts:
-- MIN()
-- CTE
-- Cohort Analysis
-- Customer Retention
-- ============================================================

WITH customer_first_order AS (

    SELECT
        customer_id,

        MIN(order_date) AS first_order_date

    FROM orders

    GROUP BY
        customer_id
),

cohorts AS (

    SELECT
        customer_id,

        EXTRACT(YEAR FROM first_order_date)
            AS cohort_year,

        EXTRACT(MONTH FROM first_order_date)
            AS cohort_month

    FROM customer_first_order
)

SELECT
    cohort_year,
    cohort_month,

    COUNT(*) AS customers_in_cohort

FROM cohorts

GROUP BY
    cohort_year,
    cohort_month

ORDER BY
    cohort_year,
    cohort_month;


-- ============================================================
-- END OF DAY 62
-- Queries: Q611 - Q620
-- Progress: 620 / 1000 = 62%
-- ============================================================
