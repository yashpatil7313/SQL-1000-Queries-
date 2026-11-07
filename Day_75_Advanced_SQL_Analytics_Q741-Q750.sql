
-- ============================================================
-- Day 75: Advanced SQL Analytics
-- Queries: Q741-Q750
-- Database: MySQL 8.0+
--
-- Tables:
-- customers(customer_id, customer_name, city)
-- products(product_id, product_name, category, price, cost_price)
-- orders(order_id, customer_id, order_date, status)
-- order_items(order_id, product_id, quantity, price)
--
-- Revenue = quantity * selling price
-- Profit = quantity * (selling price - cost price)
-- ============================================================


-- ============================================================
-- Q741: Customers Whose Average Order Value Is Greater
-- Than Their City's Average Customer Order Value
-- ============================================================

WITH order_values AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.quantity * oi.price) AS order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.customer_id
),
customer_averages AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        AVG(ov.order_value) AS average_order_value
    FROM customers c
    JOIN order_values ov
        ON c.customer_id = ov.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.city
),
city_comparison AS (
    SELECT
        *,
        AVG(average_order_value) OVER (
            PARTITION BY city
        ) AS city_average_order_value
    FROM customer_averages
)
SELECT
    customer_id,
    customer_name,
    city,
    ROUND(average_order_value, 2)
        AS customer_average_order_value,
    ROUND(city_average_order_value, 2)
        AS city_average_order_value
FROM city_comparison
WHERE average_order_value > city_average_order_value
ORDER BY city, average_order_value DESC;


-- ============================================================
-- Q742: Second-Highest Revenue-Generating Product
-- in Each Category. Include ties.
-- ============================================================

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.price) AS total_revenue
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
        *,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(total_revenue, 2) AS total_revenue,
    revenue_rank
FROM ranked_products
WHERE revenue_rank = 2
ORDER BY category, product_name;


-- ============================================================
-- Q743: Customer Monthly Spending and Cumulative Spending
-- ============================================================

WITH monthly_spending AS (
    SELECT
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        EXTRACT(YEAR FROM o.order_date) * 12
            + EXTRACT(MONTH FROM o.order_date) AS month_index,
        SUM(oi.quantity * oi.price) AS monthly_spending
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
)
SELECT
    customer_id,
    order_year,
    order_month,
    ROUND(monthly_spending, 2) AS monthly_spending,
    ROUND(
        SUM(monthly_spending) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_spending
FROM monthly_spending
ORDER BY customer_id, month_index;


-- ============================================================
-- Q744: Customers Who Purchased the Same Product
-- in at Least 3 Different Calendar Months
-- ============================================================

SELECT
    o.customer_id,
    p.product_id,
    p.product_name,
    COUNT(DISTINCT
        EXTRACT(YEAR FROM o.order_date) * 12
        + EXTRACT(MONTH FROM o.order_date)
    ) AS different_purchase_months
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    o.customer_id,
    p.product_id,
    p.product_name
HAVING COUNT(DISTINCT
    EXTRACT(YEAR FROM o.order_date) * 12
    + EXTRACT(MONTH FROM o.order_date)
) >= 3
ORDER BY
    o.customer_id,
    different_purchase_months DESC;


-- ============================================================
-- Q745: Top 5 Products by Profit Margin
-- Only Products With At Least 10 Units Sold
-- Include ties.
-- ============================================================

WITH product_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.price) AS total_revenue,
        SUM(
            oi.quantity * (oi.price - p.cost_price)
        ) AS total_profit
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
product_margins AS (
    SELECT
        *,
        total_profit * 100.0
            / NULLIF(total_revenue, 0) AS profit_margin
    FROM product_metrics
    WHERE total_units_sold >= 10
),
ranked_products AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY profit_margin DESC
        ) AS margin_rank
    FROM product_margins
)
SELECT
    product_id,
    product_name,
    category,
    total_units_sold,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(profit_margin, 2) AS profit_margin_percentage,
    margin_rank
FROM ranked_products
WHERE margin_rank <= 5
ORDER BY margin_rank, product_name;


-- ============================================================
-- Q746: Monthly Revenue Growth Compared With
-- the Same Month in the Previous Year
-- Includes Missing Calendar Months.
-- MySQL 8.0+ recursive CTE
-- ============================================================

WITH RECURSIVE
monthly_revenue AS (
    SELECT
        CAST(
            DATE_FORMAT(o.order_date, '%Y-%m-01') AS DATE
        ) AS month_start,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        DATE_FORMAT(o.order_date, '%Y-%m-01')
),
calendar_bounds AS (
    SELECT
        MIN(month_start) AS first_month,
        MAX(month_start) AS last_month
    FROM monthly_revenue
),
month_calendar AS (
    SELECT first_month AS month_start
    FROM calendar_bounds
    WHERE first_month IS NOT NULL

    UNION ALL

    SELECT DATE_ADD(mc.month_start, INTERVAL 1 MONTH)
    FROM month_calendar mc
    CROSS JOIN calendar_bounds cb
    WHERE mc.month_start < cb.last_month
),
complete_monthly_revenue AS (
    SELECT
        mc.month_start,
        YEAR(mc.month_start) * 12
            + MONTH(mc.month_start) AS month_index,
        COALESCE(mr.revenue, 0) AS revenue
    FROM month_calendar mc
    LEFT JOIN monthly_revenue mr
        ON mc.month_start = mr.month_start
),
year_comparison AS (
    SELECT
        current_month.month_start,
        current_month.month_index,
        current_month.revenue,
        previous_year.revenue AS previous_year_revenue
    FROM complete_monthly_revenue current_month
    LEFT JOIN complete_monthly_revenue previous_year
        ON current_month.month_index =
           previous_year.month_index + 12
)
SELECT
    month_start,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(previous_year_revenue, 2)
        AS previous_year_revenue,
    ROUND(
        (revenue - previous_year_revenue) * 100.0
        / NULLIF(previous_year_revenue, 0),
        2
    ) AS year_over_year_growth_percentage
FROM year_comparison
ORDER BY month_start;


-- ============================================================
-- Q747: Customers Who Purchased in Every Calendar
-- Quarter of 2026
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT QUARTER(o.order_date))
        AS quarters_purchased
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE YEAR(o.order_date) = 2026
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(DISTINCT QUARTER(o.order_date)) = 4
ORDER BY c.customer_id;


-- ============================================================
-- Q748: Products Whose Monthly Revenue Is Greater
-- Than Their Category's Average Monthly Product Revenue
-- ============================================================

WITH monthly_product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        SUM(oi.quantity * oi.price) AS monthly_revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),
category_comparison AS (
    SELECT
        *,
        AVG(monthly_revenue) OVER (
            PARTITION BY category, order_year, order_month
        ) AS category_average_monthly_revenue
    FROM monthly_product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    order_year,
    order_month,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(category_average_monthly_revenue, 2)
        AS category_average_monthly_revenue
FROM category_comparison
WHERE monthly_revenue > category_average_monthly_revenue
ORDER BY order_year, order_month, category, monthly_revenue DESC;


-- ============================================================
-- Q749: Customer First Purchase, Latest Purchase,
-- Total Orders and Days Between First and Latest Purchase
-- Include Customers With No Orders.
-- MySQL 8.0+
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    MIN(o.order_date) AS first_purchase_date,
    MAX(o.order_date) AS latest_purchase_date,
    CASE
        WHEN COUNT(o.order_id) = 0 THEN NULL
        ELSE DATEDIFF(
            MAX(o.order_date),
            MIN(o.order_date)
        )
    END AS days_between_purchases
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_orders DESC, c.customer_id;


-- ============================================================
-- Q750: Comprehensive Customer Sales Dashboard
-- Include Customers Who Have Never Ordered.
-- ============================================================

WITH order_metrics AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        COALESCE(
            SUM(oi.quantity),
            0
        ) AS order_quantity,
        COALESCE(
            SUM(oi.quantity * oi.price),
            0
        ) AS order_value
    FROM orders o
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
),
customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,

        COUNT(om.order_id) AS total_orders,

        COALESCE(
            SUM(om.order_quantity),
            0
        ) AS total_quantity_purchased,

        COALESCE(
            SUM(om.order_value),
            0
        ) AS total_spending,

        CASE
            WHEN COUNT(om.order_id) = 0 THEN NULL
            ELSE AVG(om.order_value)
        END AS average_order_value,

        MIN(om.order_date) AS first_order_date,
        MAX(om.order_date) AS latest_order_date

    FROM customers c
    LEFT JOIN order_metrics om
        ON c.customer_id = om.customer_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.city
),
ranked_customers AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY total_spending DESC
        ) AS customer_spending_rank,

        SUM(total_spending) OVER () AS company_total_revenue

    FROM customer_metrics
)
SELECT
    customer_id,
    customer_name,
    city,
    total_orders,
    total_quantity_purchased,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(average_order_value, 2) AS average_order_value,
    first_order_date,
    latest_order_date,
    customer_spending_rank,

    ROUND(
        total_spending * 100.0
        / NULLIF(company_total_revenue, 0),
        2
    ) AS company_revenue_contribution_percentage

FROM ranked_customers
ORDER BY customer_spending_rank, customer_id;


-- ============================================================
-- END OF DAY 75
-- Completed: Q741-Q750
-- Total Progress: 750 / 1000 = 75%
-- Remaining: 250 queries
-- ============================================================
