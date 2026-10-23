
-- ============================================================
-- Day 73: Advanced SQL Analytics
-- Queries: Q721-Q730
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
-- Q721: Customers Whose Spending Increased Over
-- 3 Consecutive Calendar Months
-- ============================================================

WITH monthly_spending AS (
    SELECT
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date) * 12
            + EXTRACT(MONTH FROM o.order_date) AS month_index,
        SUM(oi.quantity * oi.price) AS monthly_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),
monthly_comparison AS (
    SELECT
        *,
        LAG(monthly_revenue, 1) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS previous_revenue,
        LAG(monthly_revenue, 2) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS revenue_two_months_ago,
        LAG(month_index, 1) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS previous_month,
        LAG(month_index, 2) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS month_two_months_ago
    FROM monthly_spending
)
SELECT DISTINCT customer_id
FROM monthly_comparison
WHERE monthly_revenue > previous_revenue
  AND previous_revenue > revenue_two_months_ago
  AND month_index - previous_month = 1
  AND month_index - month_two_months_ago = 2
ORDER BY customer_id;


-- ============================================================
-- Q722: Top 3 Products by Revenue in Each Category
-- Include ties.
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
WHERE revenue_rank <= 3
ORDER BY category, revenue_rank, product_name;


-- ============================================================
-- Q723: Customer Running Spending and Each Order's
-- Percentage Contribution to Lifetime Spending
-- ============================================================

WITH order_values AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.price) AS order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
),
customer_spending AS (
    SELECT
        *,
        SUM(order_value) OVER (
            PARTITION BY customer_id
        ) AS lifetime_spending,
        SUM(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_spending
    FROM order_values
)
SELECT
    customer_id,
    order_id,
    order_date,
    ROUND(order_value, 2) AS order_value,
    ROUND(running_spending, 2) AS running_spending,
    ROUND(lifetime_spending, 2) AS lifetime_spending,
    ROUND(
        order_value * 100.0
        / NULLIF(lifetime_spending, 0),
        2
    ) AS lifetime_spending_percentage
FROM customer_spending
ORDER BY customer_id, order_date, order_id;


-- ============================================================
-- Q724: Customers Who Purchased in at Least
-- 3 Consecutive Calendar Months
-- ============================================================

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        EXTRACT(YEAR FROM order_date) * 12
            + EXTRACT(MONTH FROM order_date) AS month_index
    FROM orders
),
month_comparison AS (
    SELECT
        customer_id,
        month_index,
        LAG(month_index, 1) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS previous_month,
        LAG(month_index, 2) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS month_two_periods_ago
    FROM customer_months
)
SELECT DISTINCT customer_id
FROM month_comparison
WHERE month_index - previous_month = 1
  AND month_index - month_two_periods_ago = 2
ORDER BY customer_id;


-- ============================================================
-- Q725: Highest-Profit Product in Each Category
-- With Profit Margin Percentage
-- ============================================================

WITH product_profit AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(
            oi.quantity * (oi.price - p.cost_price)
        ) AS total_profit,
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
            ORDER BY total_profit DESC
        ) AS profit_rank
    FROM product_profit
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(
        total_profit * 100.0 / NULLIF(total_revenue, 0),
        2
    ) AS profit_margin_percentage
FROM ranked_products
WHERE profit_rank = 1
ORDER BY category, product_name;


-- ============================================================
-- Q726: Monthly Revenue and Change From Previous
-- Calendar Month, Including Months With No Sales
-- MySQL 8.0+ recursive CTE
-- ============================================================

WITH RECURSIVE
monthly_revenue AS (
    SELECT
        CAST(
            DATE_FORMAT(order_date, '%Y-%m-01') AS DATE
        ) AS month_start,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        DATE_FORMAT(order_date, '%Y-%m-01')
),
month_calendar AS (
    SELECT MIN(month_start) AS month_start
    FROM monthly_revenue

    UNION ALL

    SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM month_calendar
    WHERE month_start < (
        SELECT MAX(month_start)
        FROM monthly_revenue
    )
),
complete_monthly_revenue AS (
    SELECT
        mc.month_start,
        COALESCE(mr.revenue, 0) AS revenue
    FROM month_calendar mc
    LEFT JOIN monthly_revenue mr
        ON mc.month_start = mr.month_start
),
revenue_comparison AS (
    SELECT
        month_start,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month_start
        ) AS previous_month_revenue
    FROM complete_monthly_revenue
)
SELECT
    month_start,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2)
        AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS month_over_month_growth_percentage
FROM revenue_comparison
ORDER BY month_start;


-- ============================================================
-- Q727: Orders Above Both Customer Average
-- and Overall Average Order Value
-- ============================================================

WITH order_values AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.price) AS order_value
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
        *,
        AVG(order_value) OVER (
            PARTITION BY customer_id
        ) AS customer_average,
        AVG(order_value) OVER () AS overall_average
    FROM order_values
)
SELECT
    order_id,
    customer_id,
    order_date,
    ROUND(order_value, 2) AS order_value,
    ROUND(customer_average, 2) AS customer_average,
    ROUND(overall_average, 2) AS overall_average
FROM order_comparison
WHERE order_value > customer_average
  AND order_value > overall_average
ORDER BY order_value DESC;


-- ============================================================
-- Q728: Every Product's Revenue Contribution to
-- Total Company Revenue, Including Unsold Products
-- ============================================================

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(
            SUM(oi.quantity * oi.price),
            0
        ) AS total_revenue
    FROM products p
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
revenue_contribution AS (
    SELECT
        *,
        SUM(total_revenue) OVER () AS company_revenue
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(company_revenue, 2) AS company_revenue,
    ROUND(
        total_revenue * 100.0
        / NULLIF(company_revenue, 0),
        2
    ) AS company_revenue_percentage
FROM revenue_contribution
ORDER BY total_revenue DESC, product_id;


-- ============================================================
-- Q729: Customers Whose Second Purchase Happened
-- Within 30 Days of Their First Purchase
-- MySQL 8.0+
-- ============================================================

WITH ranked_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS purchase_number
    FROM orders
),
first_two_purchases AS (
    SELECT
        customer_id,
        MAX(
            CASE
                WHEN purchase_number = 1
                THEN order_date
            END
        ) AS first_purchase_date,
        MAX(
            CASE
                WHEN purchase_number = 2
                THEN order_date
            END
        ) AS second_purchase_date
    FROM ranked_orders
    WHERE purchase_number <= 2
    GROUP BY customer_id
)
SELECT
    customer_id,
    first_purchase_date,
    second_purchase_date,
    DATEDIFF(
        second_purchase_date,
        first_purchase_date
    ) AS days_between_purchases
FROM first_two_purchases
WHERE second_purchase_date IS NOT NULL
  AND DATEDIFF(
      second_purchase_date,
      first_purchase_date
  ) BETWEEN 0 AND 30
ORDER BY days_between_purchases, customer_id;


-- ============================================================
-- Q730: Customer Performance Dashboard
-- Include Customers Who Have Never Ordered
-- ============================================================

WITH order_values AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.price) AS order_value
    FROM orders o
    JOIN order_items oi
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
        COUNT(ov.order_id) AS total_orders,
        COALESCE(SUM(ov.order_value), 0) AS total_spending,
        AVG(ov.order_value) AS average_order_value,
        MAX(ov.order_date) AS most_recent_order_date
    FROM customers c
    LEFT JOIN order_values ov
        ON c.customer_id = ov.customer_id
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
        ) AS spending_rank
    FROM customer_metrics
)
SELECT
    customer_id,
    customer_name,
    city,
    total_orders,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(average_order_value, 2) AS average_order_value,
    most_recent_order_date,
    spending_rank
FROM ranked_customers
ORDER BY spending_rank, customer_id;


-- ============================================================
-- END OF DAY 73
-- Completed: Q721-Q730
-- Total progress: 730 / 1000 = 73%
-- Remaining: 270 queries
-- ============================================================
