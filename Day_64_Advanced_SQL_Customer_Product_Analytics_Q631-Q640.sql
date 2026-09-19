-- ============================================================
-- Day 64: Advanced SQL Customer & Product Analytics
-- Queries: Q631 to Q640
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
-- Q631: Customer First & Latest Purchase Gap
-- ============================================================
-- Task:
-- Find the first order date, latest order date,
-- total orders, and number of days between the
-- first and latest order for every customer.
--
-- Concepts:
-- MIN()
-- MAX()
-- COUNT()
-- Date Difference
-- Customer Lifetime Analysis
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,

    MIN(o.order_date) AS first_order_date,

    MAX(o.order_date) AS latest_order_date,

    COUNT(DISTINCT o.order_id) AS total_orders,

    DATEDIFF(
        MAX(o.order_date),
        MIN(o.order_date)
    ) AS customer_lifetime_days

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY
    customer_lifetime_days DESC;


-- ============================================================
-- Q632: Customers With Increasing Monthly Spending
-- ============================================================
-- Task:
-- Find customers whose monthly spending increased
-- compared with their previous month.
--
-- Example:
--
-- January  = 1000
-- February = 1500
-- March    = 2000
--
-- This customer qualifies.
--
-- Concepts:
-- Monthly Aggregation
-- LAG()
-- Window Functions
-- Customer Spending Analysis
-- ============================================================

WITH monthly_spending AS (

    SELECT
        o.customer_id,

        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,

        SUM(
            oi.quantity * oi.price
        ) AS monthly_spending

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),

spending_comparison AS (

    SELECT
        customer_id,
        order_year,
        order_month,
        monthly_spending,

        LAG(monthly_spending) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS previous_month_spending

    FROM monthly_spending
),

qualified_customers AS (

    SELECT
        customer_id

    FROM spending_comparison

    WHERE previous_month_spending IS NOT NULL

    GROUP BY
        customer_id

    HAVING
        MIN(
            CASE
                WHEN monthly_spending > previous_month_spending
                THEN 1
                ELSE 0
            END
        ) = 1
)

SELECT
    c.customer_id,
    c.customer_name

FROM customers c

JOIN qualified_customers q
    ON c.customer_id = q.customer_id

ORDER BY
    c.customer_id;


-- ============================================================
-- Q633: Top 3 Products by Revenue in Each Category
-- ============================================================
-- Task:
-- Find the top 3 products by revenue
-- within every product category.
--
-- If products have the same revenue,
-- they receive the same rank.
--
-- Concepts:
-- DENSE_RANK()
-- PARTITION BY
-- Ranking
-- Category Analysis
-- ============================================================

WITH product_revenue AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity * oi.price
        ) AS revenue

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
    revenue,
    revenue_rank

FROM ranked_products

WHERE revenue_rank <= 3

ORDER BY
    category,
    revenue_rank;


-- ============================================================
-- Q634: Revenue Difference From Category Average
-- ============================================================
-- Task:
-- Calculate each product's revenue and compare it
-- with the average revenue of its category.
--
-- Difference:
--
-- Product Revenue - Category Average Revenue
--
-- Concepts:
-- AVG() OVER()
-- PARTITION BY
-- Window Functions
-- Business Comparison
-- ============================================================

WITH product_revenue AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity * oi.price
        ) AS revenue

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
)

SELECT
    product_id,
    product_name,
    category,
    revenue,

    ROUND(
        AVG(revenue) OVER (
            PARTITION BY category
        ),
        2
    ) AS category_average_revenue,

    ROUND(
        revenue -
        AVG(revenue) OVER (
            PARTITION BY category
        ),
        2
    ) AS difference_from_category_average

FROM product_revenue

ORDER BY
    category,
    difference_from_category_average DESC;


-- ============================================================
-- Q635: Customers With Above-Average Order Frequency
-- ============================================================
-- Task:
-- Find customers whose number of orders is greater
-- than the average number of orders per customer.
--
-- Concepts:
-- COUNT()
-- AVG() OVER()
-- CTE
-- Customer Behavior Analysis
-- ============================================================

WITH customer_orders AS (

    SELECT
        c.customer_id,
        c.customer_name,

        COUNT(DISTINCT o.order_id) AS total_orders

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_id,
        c.customer_name
),

with_average AS (

    SELECT
        customer_id,
        customer_name,
        total_orders,

        AVG(total_orders) OVER ()
            AS average_orders

    FROM customer_orders
)

SELECT
    customer_id,
    customer_name,
    total_orders,

    ROUND(
        average_orders,
        2
    ) AS average_orders

FROM with_average

WHERE total_orders > average_orders

ORDER BY
    total_orders DESC;


-- ============================================================
-- Q636: Product Revenue Growth Month-over-Month
-- ============================================================
-- Task:
-- Calculate monthly revenue for each product and
-- compare it with the previous month's revenue.
--
-- Also calculate growth percentage.
--
-- Formula:
--
-- Growth % =
-- (Current Revenue - Previous Revenue)
-- / Previous Revenue * 100
--
-- Concepts:
-- LAG()
-- Monthly Revenue
-- Growth Percentage
-- Time-Series Analysis
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

revenue_growth AS (

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
    product_id,
    order_year,
    order_month,
    revenue,
    previous_month_revenue,

    ROUND(
        (
            revenue - previous_month_revenue
        ) * 100.0
        /
        NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_percentage

FROM revenue_growth

ORDER BY
    product_id,
    order_year,
    order_month;


-- ============================================================
-- Q637: Customers Who Purchased in Every Quarter
-- ============================================================
-- Task:
-- Find customers who placed at least one order
-- in every quarter of a year.
--
-- A year contains:
--
-- Q1 = January - March
-- Q2 = April - June
-- Q3 = July - September
-- Q4 = October - December
--
-- Concepts:
-- EXTRACT()
-- CASE
-- COUNT(DISTINCT)
-- HAVING
-- Customer Retention Analysis
-- ============================================================

WITH customer_quarters AS (

    SELECT DISTINCT
        customer_id,

        EXTRACT(YEAR FROM order_date) AS order_year,

        CASE
            WHEN EXTRACT(MONTH FROM order_date) BETWEEN 1 AND 3
                THEN 1

            WHEN EXTRACT(MONTH FROM order_date) BETWEEN 4 AND 6
                THEN 2

            WHEN EXTRACT(MONTH FROM order_date) BETWEEN 7 AND 9
                THEN 3

            ELSE 4
        END AS quarter_number

    FROM orders
)

SELECT
    customer_id,
    order_year,

    COUNT(DISTINCT quarter_number) AS quarters_purchased

FROM customer_quarters

GROUP BY
    customer_id,
    order_year

HAVING
    COUNT(DISTINCT quarter_number) = 4

ORDER BY
    customer_id,
    order_year;


-- ============================================================
-- Q638: Most Profitable Category
-- ============================================================
-- Task:
-- Calculate total profit for every category and
-- identify the category or categories with the
-- highest total profit.
--
-- Profit =
-- Revenue - Cost
--
-- Concepts:
-- SUM()
-- Profit Analysis
-- MAX()
-- CTE
-- ============================================================

WITH category_profit AS (

    SELECT
        p.category,

        SUM(
            oi.quantity *
            (oi.price - p.cost_price)
        ) AS total_profit

    FROM products p

    JOIN order_items oi
        ON p.product_id = oi.product_id

    GROUP BY
        p.category
),

maximum_profit AS (

    SELECT
        MAX(total_profit) AS highest_profit

    FROM category_profit
)

SELECT
    cp.category,
    cp.total_profit

FROM category_profit cp

JOIN maximum_profit mp
    ON cp.total_profit = mp.highest_profit

ORDER BY
    cp.category;


-- ============================================================
-- Q639: Customer Revenue Contribution to City
-- ============================================================
-- Task:
-- Calculate each customer's revenue and
-- determine what percentage of their city's
-- total revenue they contributed.
--
-- Formula:
--
-- Customer Contribution % =
-- Customer Revenue / City Revenue * 100
--
-- Concepts:
-- SUM() OVER()
-- PARTITION BY
-- Percentage Contribution
-- Customer Analytics
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
)

SELECT
    customer_id,
    customer_name,
    city,
    revenue,

    ROUND(
        SUM(revenue) OVER (
            PARTITION BY city
        ),
        2
    ) AS city_total_revenue,

    ROUND(
        revenue * 100.0
        /
        NULLIF(
            SUM(revenue) OVER (
                PARTITION BY city
            ),
            0
        ),
        2
    ) AS city_revenue_contribution_percentage

FROM customer_revenue

ORDER BY
    city,
    city_revenue_contribution_percentage DESC;


-- ============================================================
-- Q640: Customer Churn Detection
-- ============================================================
-- Task:
-- Identify customers whose latest order was more
-- than 90 days after their previous order.
--
-- This can be used as a simple churn-risk indicator.
--
-- Concepts:
-- LAG()
-- MAX()
-- Customer Churn
-- Date Analysis
-- CTE
--
-- NOTE:
-- This query detects a 90+ day gap between the
-- customer's latest order and previous order.
-- It does not prove that the customer has permanently
-- stopped purchasing.
-- ============================================================

WITH customer_orders AS (

    SELECT
        customer_id,
        order_id,
        order_date,

        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_order_date

    FROM orders
),

latest_orders AS (

    SELECT
        customer_id,
        order_id,
        order_date,
        previous_order_date,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS order_rank

    FROM customer_orders
)

SELECT
    c.customer_id,
    c.customer_name,

    lo.order_date AS latest_order_date,

    lo.previous_order_date,

    DATEDIFF(
        lo.order_date,
        lo.previous_order_date
    ) AS days_since_previous_order

FROM latest_orders lo

JOIN customers c
    ON lo.customer_id = c.customer_id

WHERE lo.order_rank = 1

  AND lo.previous_order_date IS NOT NULL

  AND DATEDIFF(
        lo.order_date,
        lo.previous_order_date
      ) > 90

ORDER BY
    days_since_previous_order DESC;


-- ============================================================
-- END OF DAY 64
-- Queries: Q631 - Q640
-- Progress: 640 / 1000 = 64%
-- ============================================================
