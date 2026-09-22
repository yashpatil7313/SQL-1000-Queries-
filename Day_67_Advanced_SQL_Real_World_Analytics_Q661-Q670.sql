-- ============================================================
-- Day 67: Advanced SQL & Real-World Analytics
-- Queries: Q661 to Q670
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
-- Q661: Customer Monthly Revenue Rank
-- ============================================================
-- Task:
-- Calculate monthly revenue for every customer
-- and rank customers within each month.
--
-- Concepts:
-- GROUP BY
-- DENSE_RANK()
-- PARTITION BY
-- Monthly Analytics
-- ============================================================

WITH monthly_customer_revenue AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,

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
    r.order_year,
    r.order_month,
    r.customer_id,
    c.customer_name,
    r.revenue,
    r.revenue_rank

FROM ranked_customers r

JOIN customers c
    ON r.customer_id = c.customer_id

ORDER BY
    r.order_year,
    r.order_month,
    r.revenue_rank;


-- ============================================================
-- Q662: Products With Revenue Above Previous Month
-- ============================================================
-- Task:
-- Find products whose revenue increased compared
-- with the previous month.
--
-- Concepts:
-- LAG()
-- Monthly Revenue
-- Growth Analysis
-- Window Functions
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
        ) AS previous_month_revenue

    FROM monthly_product_revenue
)

SELECT
    p.product_id,
    p.product_name,

    rc.order_year,
    rc.order_month,

    rc.revenue,
    rc.previous_month_revenue,

    ROUND(
        (
            rc.revenue -
            rc.previous_month_revenue
        ) * 100.0
        /
        NULLIF(
            rc.previous_month_revenue,
            0
        ),
        2
    ) AS growth_percentage

FROM revenue_comparison rc

JOIN products p
    ON rc.product_id = p.product_id

WHERE rc.previous_month_revenue IS NOT NULL

  AND rc.revenue > rc.previous_month_revenue

ORDER BY
    growth_percentage DESC;


-- ============================================================
-- Q663: First-Time Customers Per Month
-- ============================================================
-- Task:
-- Find the number of customers who placed their
-- first-ever order in each month.
--
-- Concepts:
-- MIN()
-- CTE
-- First Purchase Analysis
-- Customer Acquisition
-- ============================================================

WITH first_orders AS (

    SELECT
        customer_id,

        MIN(order_date) AS first_order_date

    FROM orders

    GROUP BY
        customer_id
)

SELECT
    EXTRACT(YEAR FROM first_order_date)
        AS order_year,

    EXTRACT(MONTH FROM first_order_date)
        AS order_month,

    COUNT(*) AS first_time_customers

FROM first_orders

GROUP BY
    EXTRACT(YEAR FROM first_order_date),
    EXTRACT(MONTH FROM first_order_date)

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q664: Repeat Customer Percentage by Month
-- ============================================================
-- Task:
-- Calculate monthly:
--
-- 1. Total customers
-- 2. Repeat customers
-- 3. Repeat customer percentage
--
-- A repeat customer is a customer who had
-- purchased before the current month.
--
-- Concepts:
-- CTE
-- MIN()
-- COUNT(DISTINCT)
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

monthly_customer_activity AS (

    SELECT DISTINCT
        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        o.customer_id,

        cfo.first_order_date

    FROM orders o

    JOIN customer_first_order cfo
        ON o.customer_id = cfo.customer_id
)

SELECT
    order_year,
    order_month,

    COUNT(DISTINCT customer_id)
        AS total_customers,

    COUNT(
        DISTINCT
        CASE
            WHEN
                EXTRACT(YEAR FROM first_order_date) <
                    order_year

                OR

                (
                    EXTRACT(YEAR FROM first_order_date) =
                        order_year
                    AND
                    EXTRACT(MONTH FROM first_order_date) <
                        order_month
                )

            THEN customer_id
        END
    ) AS repeat_customers,

    ROUND(
        COUNT(
            DISTINCT
            CASE
                WHEN
                    EXTRACT(YEAR FROM first_order_date) <
                        order_year

                    OR

                    (
                        EXTRACT(YEAR FROM first_order_date) =
                            order_year
                        AND
                        EXTRACT(MONTH FROM first_order_date) <
                            order_month
                    )

                THEN customer_id
            END
        ) * 100.0
        /
        NULLIF(
            COUNT(DISTINCT customer_id),
            0
        ),
        2
    ) AS repeat_customer_percentage

FROM monthly_customer_activity

GROUP BY
    order_year,
    order_month

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q665: Highest-Profit Product Each Month
-- ============================================================
-- Task:
-- Find the most profitable product in every month.
--
-- Profit:
--
-- Quantity * (Selling Price - Cost Price)
--
-- If products have equal profit, return all ties.
--
-- Concepts:
-- Profit Analysis
-- DENSE_RANK()
-- PARTITION BY
-- Monthly Business Intelligence
-- ============================================================

WITH monthly_product_profit AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        p.product_id,
        p.product_name,

        SUM(
            oi.quantity *
            (oi.price - p.cost_price)
        ) AS profit

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
        profit,

        DENSE_RANK() OVER (
            PARTITION BY order_year, order_month
            ORDER BY profit DESC
        ) AS profit_rank

    FROM monthly_product_profit
)

SELECT
    order_year,
    order_month,
    product_id,
    product_name,
    profit

FROM ranked_products

WHERE profit_rank = 1

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q666: Customers With No Purchase in the Last 90 Days
-- ============================================================
-- Task:
-- Find customers whose latest order is more than
-- 90 days before the latest order date in the dataset.
--
-- This is a simple inactivity/churn indicator.
--
-- Concepts:
-- MAX()
-- DATEDIFF()
-- CTE
-- Customer Churn Analysis
-- ============================================================

WITH customer_last_order AS (

    SELECT
        customer_id,

        MAX(order_date) AS latest_order_date

    FROM orders

    GROUP BY
        customer_id
),

dataset_latest_date AS (

    SELECT
        MAX(order_date) AS latest_dataset_date

    FROM orders
)

SELECT
    c.customer_id,
    c.customer_name,

    clo.latest_order_date,

    DATEDIFF(
        dld.latest_dataset_date,
        clo.latest_order_date
    ) AS inactive_days

FROM customers c

JOIN customer_last_order clo
    ON c.customer_id = clo.customer_id

CROSS JOIN dataset_latest_date dld

WHERE
    DATEDIFF(
        dld.latest_dataset_date,
        clo.latest_order_date
    ) > 90

ORDER BY
    inactive_days DESC;


-- ============================================================
-- Q667: Category Month-over-Month Profit Growth
-- ============================================================
-- Task:
-- Calculate monthly profit for each category and
-- compare it with the previous month's profit.
--
-- Concepts:
-- LAG()
-- Profit Growth
-- Monthly Aggregation
-- Window Functions
-- ============================================================

WITH monthly_category_profit AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        p.category,

        SUM(
            oi.quantity *
            (oi.price - p.cost_price)
        ) AS profit

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

profit_comparison AS (

    SELECT
        order_year,
        order_month,
        category,
        profit,

        LAG(profit) OVER (
            PARTITION BY category
            ORDER BY order_year, order_month
        ) AS previous_month_profit

    FROM monthly_category_profit
)

SELECT
    order_year,
    order_month,
    category,

    profit,
    previous_month_profit,

    ROUND(
        (
            profit -
            previous_month_profit
        ) * 100.0
        /
        NULLIF(
            previous_month_profit,
            0
        ),
        2
    ) AS profit_growth_percentage

FROM profit_comparison

WHERE previous_month_profit IS NOT NULL

ORDER BY
    category,
    order_year,
    order_month;


-- ============================================================
-- Q668: Orders Larger Than Customer Average
-- ============================================================
-- Task:
-- Find orders whose value is greater than the
-- average order value of that customer.
--
-- Concepts:
-- CTE
-- AVG() OVER()
-- PARTITION BY
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

customer_averages AS (

    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        AVG(order_value) OVER (
            PARTITION BY customer_id
        ) AS customer_average_order_value

    FROM order_values
)

SELECT
    oa.order_id,

    c.customer_id,
    c.customer_name,

    oa.order_date,
    oa.order_value,

    ROUND(
        oa.customer_average_order_value,
        2
    ) AS customer_average_order_value

FROM customer_averages oa

JOIN customers c
    ON oa.customer_id = c.customer_id

WHERE
    oa.order_value >
    oa.customer_average_order_value

ORDER BY
    c.customer_id,
    oa.order_value DESC;


-- ============================================================
-- Q669: Top 10% Products by Profit
-- ============================================================
-- Task:
-- Find products belonging to the top 10%
-- based on total profit.
--
-- Concepts:
-- NTILE()
-- Profit Ranking
-- CTE
-- Percentile Analysis
-- ============================================================

WITH product_profit AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity *
            (oi.price - p.cost_price)
        ) AS total_profit

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
        total_profit,

        NTILE(10) OVER (
            ORDER BY total_profit DESC
        ) AS profit_decile

    FROM product_profit
)

SELECT
    product_id,
    product_name,
    category,
    total_profit,
    profit_decile

FROM ranked_products

WHERE profit_decile = 1

ORDER BY
    total_profit DESC;


-- ============================================================
-- Q670: Customer Lifetime Value Segmentation
-- ============================================================
-- Task:
-- Calculate Customer Lifetime Value (CLV) and
-- divide customers into segments based on revenue.
--
-- Segments:
--
-- High Value:
-- Top revenue group
--
-- Medium Value:
-- Middle revenue group
--
-- Low Value:
-- Remaining customers
--
-- NTILE(3):
-- 1 = Highest revenue
-- 2 = Middle revenue
-- 3 = Lowest revenue
--
-- Concepts:
-- NTILE()
-- Customer Lifetime Value
-- CASE
-- Customer Segmentation
-- Business Intelligence
-- ============================================================

WITH customer_revenue AS (

    SELECT
        c.customer_id,
        c.customer_name,

        COUNT(
            DISTINCT o.order_id
        ) AS total_orders,

        SUM(
            oi.quantity * oi.price
        ) AS lifetime_revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.customer_name
),

customer_groups AS (

    SELECT
        customer_id,
        customer_name,
        total_orders,
        lifetime_revenue,

        NTILE(3) OVER (
            ORDER BY lifetime_revenue DESC
        ) AS revenue_group

    FROM customer_revenue
)

SELECT
    customer_id,
    customer_name,
    total_orders,
    lifetime_revenue,
    revenue_group,

    CASE

        WHEN revenue_group = 1
            THEN 'High Value'

        WHEN revenue_group = 2
            THEN 'Medium Value'

        ELSE 'Low Value'

    END AS customer_segment

FROM customer_groups

ORDER BY
    lifetime_revenue DESC;


-- ============================================================
-- END OF DAY 67
-- Queries: Q661 - Q670
-- Progress: 670 / 1000 = 67%
-- ============================================================
