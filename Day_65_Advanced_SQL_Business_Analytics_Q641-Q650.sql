-- ============================================================
-- Day 65: Advanced SQL Business Analytics
-- Queries: Q641 to Q650
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
-- Q641: Customer Average Order Value
-- ============================================================
-- Task:
-- Calculate the average order value for every customer.
--
-- Formula:
--
-- Average Order Value =
-- Total Customer Revenue / Total Orders
--
-- Concepts:
-- COUNT()
-- SUM()
-- AVG Order Value
-- CTE
-- Customer Analytics
-- ============================================================

WITH order_values AS (

    SELECT
        o.order_id,
        o.customer_id,

        SUM(
            oi.quantity * oi.price
        ) AS order_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.customer_id
),

customer_metrics AS (

    SELECT
        customer_id,

        COUNT(order_id) AS total_orders,

        SUM(order_value) AS total_revenue,

        AVG(order_value) AS average_order_value

    FROM order_values

    GROUP BY
        customer_id
)

SELECT
    c.customer_id,
    c.customer_name,

    cm.total_orders,
    cm.total_revenue,

    ROUND(
        cm.average_order_value,
        2
    ) AS average_order_value

FROM customers c

JOIN customer_metrics cm
    ON c.customer_id = cm.customer_id

ORDER BY
    average_order_value DESC;


-- ============================================================
-- Q642: Customers With Above-City-Average Spending
-- ============================================================
-- Task:
-- Find customers whose total revenue is greater
-- than the average customer revenue of their city.
--
-- Concepts:
-- Window AVG()
-- PARTITION BY
-- Customer Segmentation
-- CTE
-- ============================================================

WITH customer_revenue AS (

    SELECT
        c.customer_id,
        c.customer_name,
        c.city,

        SUM(
            oi.quantity * oi.price
        ) AS revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.customer_name,
        c.city
),

city_analysis AS (

    SELECT
        customer_id,
        customer_name,
        city,
        revenue,

        AVG(revenue) OVER (
            PARTITION BY city
        ) AS city_average_revenue

    FROM customer_revenue
)

SELECT
    customer_id,
    customer_name,
    city,
    revenue,

    ROUND(
        city_average_revenue,
        2
    ) AS city_average_revenue

FROM city_analysis

WHERE revenue > city_average_revenue

ORDER BY
    city,
    revenue DESC;


-- ============================================================
-- Q643: Top Revenue Product Each Month
-- ============================================================
-- Task:
-- Find the product with the highest revenue
-- in every month.
--
-- If multiple products have the same revenue,
-- return all tied products.
--
-- Concepts:
-- Monthly Aggregation
-- DENSE_RANK()
-- PARTITION BY
-- Time-Series Analysis
-- ============================================================

WITH monthly_product_revenue AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,

        p.product_id,
        p.product_name,

        SUM(
            oi.quantity * oi.price
        ) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date),
        p.product_id,
        p.product_name
),

ranked_products AS (

    SELECT
        order_year,
        order_month,
        product_id,
        product_name,
        revenue,

        DENSE_RANK() OVER (
            PARTITION BY order_year, order_month
            ORDER BY revenue DESC
        ) AS revenue_rank

    FROM monthly_product_revenue
)

SELECT
    order_year,
    order_month,
    product_id,
    product_name,
    revenue

FROM ranked_products

WHERE revenue_rank = 1

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q644: Products With Declining Monthly Sales
-- ============================================================
-- Task:
-- Find products whose latest month's revenue is
-- lower than their previous month's revenue.
--
-- Concepts:
-- LAG()
-- Monthly Revenue
-- Revenue Comparison
-- CTE
-- ============================================================

WITH monthly_product_revenue AS (

    SELECT
        oi.product_id,

        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,

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

revenue_comparison AS (

    SELECT
        product_id,
        order_year,
        order_month,
        revenue,

        LAG(revenue) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS previous_revenue,

        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY order_year DESC, order_month DESC
        ) AS latest_rank

    FROM monthly_product_revenue
)

SELECT
    p.product_id,
    p.product_name,

    rc.order_year,
    rc.order_month,

    rc.revenue,
    rc.previous_revenue,

    ROUND(
        (
            rc.revenue - rc.previous_revenue
        ) * 100.0
        /
        NULLIF(rc.previous_revenue, 0),
        2
    ) AS growth_percentage

FROM revenue_comparison rc

JOIN products p
    ON rc.product_id = p.product_id

WHERE rc.latest_rank = 1

  AND rc.previous_revenue IS NOT NULL

  AND rc.revenue < rc.previous_revenue

ORDER BY
    growth_percentage ASC;


-- ============================================================
-- Q645: Customer Purchase Frequency
-- ============================================================
-- Task:
-- Calculate:
--
-- 1. Total orders
-- 2. First order date
-- 3. Latest order date
-- 4. Number of active months
-- 5. Orders per active month
--
-- Concepts:
-- COUNT()
-- MIN()
-- MAX()
-- COUNT(DISTINCT)
-- Customer Behavior Analysis
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,

    COUNT(DISTINCT o.order_id)
        AS total_orders,

    MIN(o.order_date)
        AS first_order_date,

    MAX(o.order_date)
        AS latest_order_date,

    COUNT(
        DISTINCT
        EXTRACT(YEAR FROM o.order_date) * 100
        + EXTRACT(MONTH FROM o.order_date)
    ) AS active_months,

    ROUND(
        COUNT(DISTINCT o.order_id) * 1.0
        /
        NULLIF(
            COUNT(
                DISTINCT
                EXTRACT(YEAR FROM o.order_date) * 100
                + EXTRACT(MONTH FROM o.order_date)
            ),
            0
        ),
        2
    ) AS orders_per_active_month

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY
    orders_per_active_month DESC;


-- ============================================================
-- Q646: Category Profit Margin
-- ============================================================
-- Task:
-- Calculate total revenue, total cost,
-- total profit and profit margin for every category.
--
-- Formula:
--
-- Profit = Revenue - Cost
--
-- Profit Margin =
-- Profit / Revenue * 100
--
-- Concepts:
-- SUM()
-- Profit Analysis
-- NULLIF()
-- Business Metrics
-- ============================================================

SELECT
    p.category,

    SUM(
        oi.quantity * oi.price
    ) AS total_revenue,

    SUM(
        oi.quantity * p.cost_price
    ) AS total_cost,

    SUM(
        oi.quantity *
        (oi.price - p.cost_price)
    ) AS total_profit,

    ROUND(
        SUM(
            oi.quantity *
            (oi.price - p.cost_price)
        ) * 100.0
        /
        NULLIF(
            SUM(oi.quantity * oi.price),
            0
        ),
        2
    ) AS profit_margin_percentage

FROM products p

JOIN order_items oi
    ON p.product_id = oi.product_id

GROUP BY
    p.category

ORDER BY
    profit_margin_percentage DESC;


-- ============================================================
-- Q647: Month With Highest Customer Count
-- ============================================================
-- Task:
-- Find the month with the highest number of
-- unique customers.
--
-- Concepts:
-- COUNT(DISTINCT)
-- Monthly Aggregation
-- DENSE_RANK()
-- Business Intelligence
-- ============================================================

WITH monthly_customers AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        COUNT(
            DISTINCT o.customer_id
        ) AS unique_customers

    FROM orders o

    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),

ranked_months AS (

    SELECT
        order_year,
        order_month,
        unique_customers,

        DENSE_RANK() OVER (
            ORDER BY unique_customers DESC
        ) AS customer_rank

    FROM monthly_customers
)

SELECT
    order_year,
    order_month,
    unique_customers

FROM ranked_months

WHERE customer_rank = 1

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q648: Customers Who Repeatedly Purchased Same Product
-- ============================================================
-- Task:
-- Find customers who purchased the same product
-- more than once across different orders.
--
-- Concepts:
-- GROUP BY
-- COUNT(DISTINCT)
-- HAVING
-- Customer Product Behavior
-- ============================================================

SELECT
    o.customer_id,
    c.customer_name,

    oi.product_id,
    p.product_name,

    COUNT(
        DISTINCT o.order_id
    ) AS number_of_orders,

    SUM(
        oi.quantity
    ) AS total_quantity_purchased

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY
    o.customer_id,
    c.customer_name,
    oi.product_id,
    p.product_name

HAVING
    COUNT(DISTINCT o.order_id) > 1

ORDER BY
    number_of_orders DESC,
    total_quantity_purchased DESC;


-- ============================================================
-- Q649: Revenue Share of Top 20% Products
-- ============================================================
-- Task:
-- Calculate how much percentage of total revenue
-- is generated by the top 20% of products.
--
-- Concepts:
-- NTILE()
-- Window SUM()
-- Revenue Contribution
-- Pareto Analysis
-- ============================================================

WITH product_revenue AS (

    SELECT
        p.product_id,
        p.product_name,

        SUM(
            oi.quantity * oi.price
        ) AS revenue

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.product_id,
        p.product_name
),

ranked_products AS (

    SELECT
        product_id,
        product_name,
        revenue,

        NTILE(5) OVER (
            ORDER BY revenue DESC
        ) AS revenue_group

    FROM product_revenue
),

revenue_summary AS (

    SELECT
        SUM(
            CASE
                WHEN revenue_group = 1
                THEN revenue
                ELSE 0
            END
        ) AS top_20_revenue,

        SUM(revenue) AS total_revenue

    FROM ranked_products
)

SELECT
    top_20_revenue,
    total_revenue,

    ROUND(
        top_20_revenue * 100.0
        /
        NULLIF(total_revenue, 0),
        2
    ) AS top_20_revenue_percentage

FROM revenue_summary;


-- ============================================================
-- Q650: Advanced Customer Segmentation
-- ============================================================
-- Task:
-- Segment customers using three metrics:
--
-- 1. Total revenue
-- 2. Number of orders
-- 3. Average order value
--
-- Segments:
--
-- High Value:
-- Revenue and order count are above average.
--
-- Frequent:
-- Order count is above average but revenue is not.
--
-- High Spender:
-- Revenue is above average but order count is not.
--
-- Regular:
-- All remaining customers.
--
-- Concepts:
-- CTE
-- Window AVG()
-- CASE
-- Customer Segmentation
-- Business Intelligence
-- ============================================================

WITH customer_orders AS (

    SELECT
        c.customer_id,
        c.customer_name,

        COUNT(
            DISTINCT o.order_id
        ) AS total_orders,

        SUM(
            oi.quantity * oi.price
        ) AS total_revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.customer_name
),

customer_metrics AS (

    SELECT
        customer_id,
        customer_name,
        total_orders,
        total_revenue,

        total_revenue / NULLIF(total_orders, 0)
            AS average_order_value,

        AVG(total_orders) OVER ()
            AS average_customer_orders,

        AVG(total_revenue) OVER ()
            AS average_customer_revenue

    FROM customer_orders
)

SELECT
    customer_id,
    customer_name,

    total_orders,

    ROUND(
        total_revenue,
        2
    ) AS total_revenue,

    ROUND(
        average_order_value,
        2
    ) AS average_order_value,

    ROUND(
        average_customer_orders,
        2
    ) AS average_customer_orders,

    ROUND(
        average_customer_revenue,
        2
    ) AS average_customer_revenue,

    CASE

        WHEN total_revenue > average_customer_revenue
         AND total_orders > average_customer_orders
        THEN 'High Value'

        WHEN total_orders > average_customer_orders
         AND total_revenue <= average_customer_revenue
        THEN 'Frequent'

        WHEN total_revenue > average_customer_revenue
         AND total_orders <= average_customer_orders
        THEN 'High Spender'

        ELSE 'Regular'

    END AS customer_segment

FROM customer_metrics

ORDER BY
    total_revenue DESC;


-- ============================================================
-- END OF DAY 65
-- Queries: Q641 - Q650
-- Progress: 650 / 1000 = 65%
-- ============================================================
