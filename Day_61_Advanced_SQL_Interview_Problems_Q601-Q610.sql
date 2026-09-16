-- ============================================================
-- Day 61: Advanced SQL Interview Problems & Complex Business Cases
-- Queries: Q601 to Q610
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
-- Q601: Customers With Continuously Increasing Order Values
-- ============================================================
-- Task:
-- Find customers whose order value increased compared
-- with every previous consecutive order.
--
-- Concepts:
-- LAG()
-- CTE
-- Aggregation
-- Window Functions
-- ============================================================

WITH order_values AS (

    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,

        SUM(oi.quantity * oi.price) AS order_value,

        LAG(SUM(oi.quantity * oi.price))
            OVER (
                PARTITION BY o.customer_id
                ORDER BY o.order_date, o.order_id
            ) AS previous_order_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.customer_id,
        o.order_id,
        o.order_date
),

comparison AS (

    SELECT
        customer_id,
        order_id,
        order_date,
        order_value,
        previous_order_value,

        CASE
            WHEN previous_order_value IS NULL THEN 1
            WHEN order_value > previous_order_value THEN 1
            ELSE 0
        END AS is_increasing

    FROM order_values
)

SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM comparison
GROUP BY customer_id
HAVING MIN(is_increasing) = 1
   AND COUNT(*) >= 2;


-- ============================================================
-- Q602: Second-Highest Revenue Product in Each Category
-- ============================================================
-- Task:
-- Find the product having the second-highest revenue
-- within every category.
--
-- Concepts:
-- DENSE_RANK()
-- PARTITION BY
-- Aggregation
-- CTE
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

ranked_products AS (

    SELECT
        product_id,
        product_name,
        category,
        revenue,

        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM product_revenue
)

SELECT
    product_id,
    product_name,
    category,
    revenue

FROM ranked_products

WHERE revenue_rank = 2

ORDER BY
    category,
    revenue DESC;


-- ============================================================
-- Q603: Products Contributing to the First 80% of Revenue
-- ============================================================
-- Task:
-- Perform Pareto analysis.
--
-- Find products that together contribute to the first
-- 80% of total revenue.
--
-- Concepts:
-- Running Total
-- Window SUM()
-- Cumulative Percentage
-- Pareto Analysis
-- ============================================================

WITH product_revenue AS (

    SELECT
        p.product_id,
        p.product_name,

        SUM(oi.quantity * oi.price) AS revenue

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.product_id,
        p.product_name
),

revenue_analysis AS (

    SELECT
        product_id,
        product_name,
        revenue,

        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        ) AS cumulative_revenue,

        SUM(revenue) OVER () AS total_revenue

    FROM product_revenue
)

SELECT
    product_id,
    product_name,
    revenue,

    cumulative_revenue,

    total_revenue,

    ROUND(
        cumulative_revenue * 100.0
        / NULLIF(total_revenue, 0),
        2
    ) AS cumulative_percentage

FROM revenue_analysis

WHERE cumulative_revenue <= total_revenue * 0.80

ORDER BY revenue DESC;


-- ============================================================
-- Q604: Customers Who Bought Every Product in a Category
-- ============================================================
-- Task:
-- Find customers who purchased EVERY product belonging
-- to the 'Electronics' category.
--
-- Concepts:
-- NOT EXISTS
-- Nested Subquery
-- Relational Division
-- Advanced Filtering
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name

FROM customers c

WHERE NOT EXISTS (

    SELECT 1

    FROM products p

    WHERE p.category = 'Electronics'

      AND NOT EXISTS (

          SELECT 1

          FROM orders o

          JOIN order_items oi
              ON o.order_id = oi.order_id

          WHERE o.customer_id = c.customer_id

            AND oi.product_id = p.product_id
      )
)

ORDER BY
    c.customer_id;


-- ============================================================
-- Q605: Frequently Purchased Product Pairs
-- ============================================================
-- Task:
-- Find pairs of products that were purchased together
-- in the same order.
--
-- Only display product pairs purchased together at least
-- 5 times.
--
-- Concepts:
-- Self Join
-- Many-to-Many Analysis
-- COUNT(DISTINCT)
-- Market Basket Analysis
-- ============================================================

SELECT
    oi1.product_id AS product_1,
    oi2.product_id AS product_2,

    COUNT(DISTINCT oi1.order_id)
        AS times_purchased_together

FROM order_items oi1

JOIN order_items oi2
    ON oi1.order_id = oi2.order_id

   -- Prevent:
   -- Product A + Product A
   -- Product B + Product A duplicates

   AND oi1.product_id < oi2.product_id

GROUP BY
    oi1.product_id,
    oi2.product_id

HAVING COUNT(DISTINCT oi1.order_id) >= 5

ORDER BY
    times_purchased_together DESC;


-- ============================================================
-- Q606: Most Frequently Purchased Category Per Customer
-- ============================================================
-- Task:
-- Find the product category purchased in the highest
-- quantity by each customer.
--
-- If two categories have the same quantity, both are returned.
--
-- Concepts:
-- SUM()
-- DENSE_RANK()
-- PARTITION BY
-- Customer Behavior Analysis
-- ============================================================

WITH category_purchases AS (

    SELECT
        o.customer_id,
        p.category,

        SUM(oi.quantity) AS total_quantity

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        o.customer_id,
        p.category
),

ranked_categories AS (

    SELECT
        customer_id,
        category,
        total_quantity,

        DENSE_RANK() OVER (
            PARTITION BY customer_id
            ORDER BY total_quantity DESC
        ) AS category_rank

    FROM category_purchases
)

SELECT
    customer_id,
    category,
    total_quantity

FROM ranked_categories

WHERE category_rank = 1

ORDER BY
    customer_id;


-- ============================================================
-- Q607: Monthly Revenue and Month-over-Month Growth
-- ============================================================
-- Task:
-- Calculate:
--
-- 1. Monthly revenue
-- 2. Previous month's revenue
-- 3. Revenue difference
-- 4. Month-over-month growth percentage
--
-- Concepts:
-- Time-Series Analysis
-- LAG()
-- CTE
-- Percentage Growth
-- ============================================================

WITH monthly_revenue AS (

    SELECT

        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        SUM(oi.quantity * oi.price)
            AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),

revenue_comparison AS (

    SELECT

        order_year,
        order_month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY order_year, order_month
        ) AS previous_month_revenue

    FROM monthly_revenue
)

SELECT

    order_year,
    order_month,

    revenue,

    previous_month_revenue,

    revenue - previous_month_revenue
        AS revenue_difference,

    ROUND(
        (
            revenue - previous_month_revenue
        ) * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_percentage

FROM revenue_comparison

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q608: Months With Higher Revenue Than Previous Month
-- ============================================================
-- Task:
-- Find months where revenue was greater than the
-- immediately previous month.
--
-- Concepts:
-- LAG()
-- Time-Series Analysis
-- CTE
-- Comparison
-- ============================================================

WITH monthly_revenue AS (

    SELECT

        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        SUM(oi.quantity * oi.price)
            AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),

comparison AS (

    SELECT

        order_year,
        order_month,
        revenue,

        LAG(revenue) OVER (
            ORDER BY order_year, order_month
        ) AS previous_revenue

    FROM monthly_revenue
)

SELECT

    order_year,
    order_month,

    revenue,

    previous_revenue,

    revenue - previous_revenue
        AS revenue_increase

FROM comparison

WHERE revenue > previous_revenue

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q609: Latest Order Is Also Highest-Value Order
-- ============================================================
-- Task:
-- Find customers whose latest order is also their
-- highest-value order.
--
-- Concepts:
-- ROW_NUMBER()
-- MAX() OVER()
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

order_analysis AS (

    SELECT

        customer_id,
        order_id,
        order_date,
        order_value,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS latest_order_rank,

        MAX(order_value) OVER (
            PARTITION BY customer_id
        ) AS highest_order_value

    FROM order_values
)

SELECT

    customer_id,
    order_id,
    order_date,
    order_value

FROM order_analysis

WHERE latest_order_rank = 1

  AND order_value = highest_order_value

ORDER BY
    customer_id;


-- ============================================================
-- Q610: Advanced RFM Customer Segmentation
-- ============================================================
-- RFM means:
--
-- R = Recency
-- F = Frequency
-- M = Monetary
--
-- Recency:
-- How recently the customer placed an order.
--
-- Frequency:
-- How many orders the customer placed.
--
-- Monetary:
-- How much money the customer spent.
--
-- NTILE(5) divides customers into 5 groups.
--
-- Concepts:
-- NTILE()
-- Customer Segmentation
-- Window Functions
-- CTE
-- RFM Analysis
-- ============================================================

WITH customer_metrics AS (

    SELECT

        c.customer_id,
        c.customer_name,

        MAX(o.order_date)
            AS last_order_date,

        COUNT(DISTINCT o.order_id)
            AS frequency,

        SUM(oi.quantity * oi.price)
            AS monetary

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.customer_name
),

rfm_scores AS (

    SELECT

        customer_id,
        customer_name,
        last_order_date,
        frequency,
        monetary,

        -- More recent customer = better score
        NTILE(5) OVER (
            ORDER BY last_order_date DESC
        ) AS recency_score,

        -- More orders = better score
        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS frequency_score,

        -- More spending = better score
        NTILE(5) OVER (
            ORDER BY monetary ASC
        ) AS monetary_score

    FROM customer_metrics
)

SELECT

    customer_id,
    customer_name,

    last_order_date,

    frequency,

    monetary,

    recency_score,

    frequency_score,

    monetary_score,

    (
        recency_score
        + frequency_score
        + monetary_score
    ) AS rfm_score

FROM rfm_scores

ORDER BY
    rfm_score DESC,
    monetary DESC;


-- ============================================================
-- END OF DAY 61
-- Q601 - Q610
-- ============================================================
