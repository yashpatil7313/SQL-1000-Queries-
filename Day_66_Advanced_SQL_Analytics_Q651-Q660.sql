-- ============================================================
-- Day 66: Advanced SQL Analytics & Interview Challenges
-- Queries: Q651 to Q660
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
-- Q651: Customer Revenue Growth
-- ============================================================
-- Task:
-- Compare each customer's current order value
-- with their previous order value.
--
-- Calculate the percentage growth between orders.
--
-- Concepts:
-- LAG()
-- Window Functions
-- Revenue Growth
-- Customer Analytics
-- ============================================================

WITH order_values AS (

    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        SUM(
            oi.quantity * oi.price
        ) AS order_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
),

order_comparison AS (

    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        LAG(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_value

    FROM order_values
)

SELECT
    c.customer_id,
    c.customer_name,

    oc.order_id,
    oc.order_date,

    oc.order_value,
    oc.previous_order_value,

    ROUND(
        (
            oc.order_value -
            oc.previous_order_value
        ) * 100.0
        /
        NULLIF(
            oc.previous_order_value,
            0
        ),
        2
    ) AS growth_percentage

FROM order_comparison oc

JOIN customers c
    ON oc.customer_id = c.customer_id

WHERE oc.previous_order_value IS NOT NULL

ORDER BY
    c.customer_id,
    oc.order_date;


-- ============================================================
-- Q652: Highest-Value Order per Customer
-- ============================================================
-- Task:
-- Find the highest-value order placed by every customer.
--
-- If a customer has multiple orders with the same
-- highest value, return all tied orders.
--
-- Concepts:
-- DENSE_RANK()
-- PARTITION BY
-- Ranking
-- Customer Order Analysis
-- ============================================================

WITH order_values AS (

    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        SUM(
            oi.quantity * oi.price
        ) AS order_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
),

ranked_orders AS (

    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        DENSE_RANK() OVER (
            PARTITION BY customer_id
            ORDER BY order_value DESC
        ) AS order_rank

    FROM order_values
)

SELECT
    c.customer_id,
    c.customer_name,

    ro.order_id,
    ro.order_date,
    ro.order_value

FROM ranked_orders ro

JOIN customers c
    ON ro.customer_id = c.customer_id

WHERE ro.order_rank = 1

ORDER BY
    c.customer_id;


-- ============================================================
-- Q653: Products Never Purchased
-- ============================================================
-- Task:
-- Find products that have never appeared
-- in any order.
--
-- Concepts:
-- LEFT JOIN
-- NULL Filtering
-- NOT EXISTS
-- Data Quality Analysis
-- ============================================================

SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price

FROM products p

LEFT JOIN order_items oi
    ON p.product_id = oi.product_id

WHERE oi.product_id IS NULL

ORDER BY
    p.product_id;


-- ============================================================
-- Q654: Category With Highest Average Order Value
-- ============================================================
-- Task:
-- Calculate the average order value for each category.
--
-- An order can contain products from multiple categories,
-- so calculate the category's value within each order first.
--
-- Then calculate the average category order value.
--
-- Concepts:
-- CTE
-- AVG()
-- GROUP BY
-- Category Analytics
-- ============================================================

WITH category_order_values AS (

    SELECT
        p.category,
        oi.order_id,

        SUM(
            oi.quantity * oi.price
        ) AS category_order_value

    FROM order_items oi

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        p.category,
        oi.order_id
),

category_averages AS (

    SELECT
        category,

        AVG(
            category_order_value
        ) AS average_order_value

    FROM category_order_values

    GROUP BY
        category
)

SELECT
    category,

    ROUND(
        average_order_value,
        2
    ) AS average_order_value

FROM category_averages

ORDER BY
    average_order_value DESC;


-- ============================================================
-- Q655: Customers With Consecutive Orders
-- ============================================================
-- Task:
-- Find customers whose consecutive orders were placed
-- within 7 days of each other.
--
-- Example:
--
-- Order 1: January 1
-- Order 2: January 5
--
-- Gap = 4 days
--
-- Concepts:
-- LAG()
-- Date Difference
-- Customer Behavior
-- Repeat Purchase Analysis
-- ============================================================

WITH customer_orders AS (

    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,

        LAG(o.order_date) OVER (
            PARTITION BY o.customer_id
            ORDER BY o.order_date, o.order_id
        ) AS previous_order_date

    FROM orders o
)

SELECT
    c.customer_id,
    c.customer_name,

    co.order_id,
    co.order_date,

    co.previous_order_date,

    DATEDIFF(
        co.order_date,
        co.previous_order_date
    ) AS days_between_orders

FROM customer_orders co

JOIN customers c
    ON co.customer_id = c.customer_id

WHERE co.previous_order_date IS NOT NULL

  AND DATEDIFF(
        co.order_date,
        co.previous_order_date
      ) <= 7

ORDER BY
    c.customer_id,
    co.order_date;


-- ============================================================
-- Q656: Monthly Customer Retention
-- ============================================================
-- Task:
-- For every month, calculate:
--
-- 1. Total customers active in that month
-- 2. Customers who also purchased in the previous month
-- 3. Retention percentage
--
-- Concepts:
-- Monthly Cohorts
-- LAG()
-- Self Join
-- Customer Retention
-- ============================================================

WITH customer_months AS (

    SELECT DISTINCT
        customer_id,

        EXTRACT(YEAR FROM order_date)
            AS order_year,

        EXTRACT(MONTH FROM order_date)
            AS order_month

    FROM orders
),

current_month_customers AS (

    SELECT
        order_year,
        order_month,

        COUNT(DISTINCT customer_id)
            AS total_customers

    FROM customer_months

    GROUP BY
        order_year,
        order_month
),

retained_customers AS (

    SELECT
        current_month.order_year,
        current_month.order_month,

        COUNT(
            DISTINCT current_month.customer_id
        ) AS retained_customers

    FROM customer_months current_month

    JOIN customer_months previous_month

        ON current_month.customer_id =
           previous_month.customer_id

        AND (
            (
                current_month.order_year =
                previous_month.order_year
                AND current_month.order_month =
                    previous_month.order_month + 1
            )

            OR

            (
                current_month.order_year =
                previous_month.order_year + 1
                AND current_month.order_month = 1
                AND previous_month.order_month = 12
            )
        )

    GROUP BY
        current_month.order_year,
        current_month.order_month
)

SELECT
    cm.order_year,
    cm.order_month,

    cm.total_customers,

    COALESCE(
        rc.retained_customers,
        0
    ) AS retained_customers,

    ROUND(
        COALESCE(
            rc.retained_customers,
            0
        ) * 100.0
        /
        NULLIF(
            cm.total_customers,
            0
        ),
        2
    ) AS retention_percentage

FROM current_month_customers cm

LEFT JOIN retained_customers rc

    ON cm.order_year = rc.order_year
    AND cm.order_month = rc.order_month

ORDER BY
    cm.order_year,
    cm.order_month;


-- ============================================================
-- Q657: Products With Increasing Sales
-- ============================================================
-- Task:
-- Find products whose monthly revenue increased
-- for every available consecutive month.
--
-- Example:
--
-- January  = 1000
-- February = 1200
-- March    = 1500
--
-- Product qualifies.
--
-- Concepts:
-- LAG()
-- CTE
-- Window Functions
-- Trend Analysis
-- ============================================================

WITH monthly_product_sales AS (

    SELECT
        oi.product_id,

        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        SUM(
            oi.quantity * oi.price
        ) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        oi.product_id,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),

sales_comparison AS (

    SELECT
        product_id,
        order_year,
        order_month,
        revenue,

        LAG(revenue) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS previous_revenue

    FROM monthly_product_sales
),

product_check AS (

    SELECT
        product_id,

        COUNT(*) AS total_months,

        COUNT(previous_revenue)
            AS comparable_months,

        MIN(
            CASE
                WHEN previous_revenue IS NULL
                    THEN 1

                WHEN revenue > previous_revenue
                    THEN 1

                ELSE 0
            END
        ) AS increasing_flag

    FROM sales_comparison

    GROUP BY
        product_id
)

SELECT
    p.product_id,
    p.product_name,

    pc.total_months,
    pc.comparable_months

FROM product_check pc

JOIN products p
    ON pc.product_id = p.product_id

WHERE pc.total_months >= 2

  AND pc.comparable_months >= 1

  AND pc.increasing_flag = 1

ORDER BY
    p.product_id;


-- ============================================================
-- Q658: Top Customer by Revenue in Each Month
-- ============================================================
-- Task:
-- Find the customer who generated the highest
-- revenue in every month.
--
-- Ties should also be returned.
--
-- Concepts:
-- Monthly Aggregation
-- DENSE_RANK()
-- PARTITION BY
-- Customer Revenue Analysis
-- ============================================================

WITH monthly_customer_revenue AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        o.customer_id,

        SUM(
            oi.quantity * oi.price
        ) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date),
        o.customer_id
),

ranked_customers AS (

    SELECT
        order_year,
        order_month,
        customer_id,
        revenue,

        DENSE_RANK() OVER (
            PARTITION BY order_year, order_month
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM monthly_customer_revenue
)

SELECT
    rc.order_year,
    rc.order_month,

    rc.customer_id,
    c.customer_name,

    rc.revenue

FROM ranked_customers rc

JOIN customers c
    ON rc.customer_id = c.customer_id

WHERE rc.revenue_rank = 1

ORDER BY
    rc.order_year,
    rc.order_month;


-- ============================================================
-- Q659: Revenue Difference Between First and Latest Order
-- ============================================================
-- Task:
-- For every customer, find:
--
-- 1. First order value
-- 2. Latest order value
-- 3. Difference
-- 4. Percentage change
--
-- Concepts:
-- FIRST_VALUE()
-- LAST_VALUE()
-- Window Functions
-- Customer Growth
-- ============================================================

WITH order_values AS (

    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        SUM(
            oi.quantity * oi.price
        ) AS order_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
),

customer_order_values AS (

    SELECT
        customer_id,

        FIRST_VALUE(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS first_order_value,

        FIRST_VALUE(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS latest_order_value

    FROM order_values
),

customer_summary AS (

    SELECT DISTINCT
        customer_id,
        first_order_value,
        latest_order_value

    FROM customer_order_values
)

SELECT
    cs.customer_id,
    c.customer_name,

    cs.first_order_value,
    cs.latest_order_value,

    ROUND(
        cs.latest_order_value -
        cs.first_order_value,
        2
    ) AS value_difference,

    ROUND(
        (
            cs.latest_order_value -
            cs.first_order_value
        ) * 100.0
        /
        NULLIF(
            cs.first_order_value,
            0
        ),
        2
    ) AS percentage_change

FROM customer_summary cs

JOIN customers c
    ON cs.customer_id = c.customer_id

ORDER BY
    percentage_change DESC;


-- ============================================================
-- Q660: Advanced RFM Customer Segmentation
-- ============================================================
-- Task:
-- Segment customers using RFM analysis.
--
-- RFM:
--
-- R = Recency
-- F = Frequency
-- M = Monetary
--
-- Recency:
-- Days since customer's latest order.
--
-- Frequency:
-- Number of orders.
--
-- Monetary:
-- Total revenue.
--
-- NTILE(5) creates scores from 1 to 5.
--
-- Concepts:
-- RFM Analysis
-- NTILE()
-- CTE
-- Customer Segmentation
-- Business Intelligence
-- ============================================================

WITH customer_metrics AS (

    SELECT
        c.customer_id,
        c.customer_name,

        MAX(o.order_date)
            AS latest_order_date,

        COUNT(
            DISTINCT o.order_id
        ) AS frequency,

        SUM(
            oi.quantity * oi.price
        ) AS monetary

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.customer_name
),

reference_date AS (

    SELECT
        MAX(order_date) AS max_order_date

    FROM orders
),

rfm_values AS (

    SELECT
        cm.customer_id,
        cm.customer_name,

        DATEDIFF(
            rd.max_order_date,
            cm.latest_order_date
        ) AS recency,

        cm.frequency,

        cm.monetary

    FROM customer_metrics cm

    CROSS JOIN reference_date rd
),

rfm_scores AS (

    SELECT
        customer_id,
        customer_name,
        recency,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS monetary_score

    FROM rfm_values
)

SELECT
    customer_id,
    customer_name,

    recency,
    frequency,
    monetary,

    recency_score,
    frequency_score,
    monetary_score,

    CASE

        WHEN recency_score >= 4
         AND frequency_score >= 4
         AND monetary_score >= 4
        THEN 'Champions'

        WHEN frequency_score >= 4
         AND monetary_score >= 4
        THEN 'Loyal Customers'

        WHEN recency_score >= 4
         AND monetary_score >= 3
        THEN 'Potential Loyal Customers'

        WHEN recency_score <= 2
         AND frequency_score <= 2
         AND monetary_score <= 2
        THEN 'At Risk'

        ELSE 'Regular Customers'

    END AS rfm_segment

FROM rfm_scores

ORDER BY
    monetary DESC;


-- ============================================================
-- END OF DAY 66
-- Queries: Q651 - Q660
-- Progress: 660 / 1000 = 66%
-- ============================================================
