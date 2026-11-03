
-- ============================================================
-- Day 74: Advanced SQL Analytics
-- Queries: Q731-Q740
-- Database: MySQL 8.0+
--
-- Tables:
-- customers(customer_id, customer_name, city)
-- products(product_id, product_name, category, price, cost_price)
-- orders(order_id, customer_id, order_date, status)
-- order_items(order_id, product_id, quantity, price)
--
-- Revenue = quantity * selling price
-- Cost    = quantity * cost price
-- Profit  = revenue - cost
-- ============================================================


-- ============================================================
-- Q731: Customers Whose Order Value Increased
-- With Every Consecutive Purchase
-- ============================================================

WITH order_values AS (
    SELECT
        o.customer_id,
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.price) AS order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.customer_id,
        o.order_id,
        o.order_date
),
purchase_comparison AS (
    SELECT
        *,
        LAG(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_value
    FROM order_values
)
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    MIN(order_value) AS minimum_order_value,
    MAX(order_value) AS maximum_order_value
FROM purchase_comparison
GROUP BY customer_id
HAVING COUNT(*) >= 2
   AND SUM(
       CASE
           WHEN previous_order_value IS NOT NULL
            AND order_value <= previous_order_value
           THEN 1
           ELSE 0
       END
   ) = 0
ORDER BY customer_id;


-- ============================================================
-- Q732: Top 3 Customers by Total Spending in Each City
-- Include ties.
-- ============================================================

WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        SUM(oi.quantity * oi.price) AS total_spending
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
ranked_customers AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY total_spending DESC
        ) AS spending_rank
    FROM customer_spending
)
SELECT
    customer_id,
    customer_name,
    city,
    ROUND(total_spending, 2) AS total_spending,
    spending_rank
FROM ranked_customers
WHERE spending_rank <= 3
ORDER BY city, spending_rank, customer_name;


-- ============================================================
-- Q733: Monthly Product Revenue and Its Percentage
-- Contribution to That Month's Company Revenue
-- ============================================================

WITH product_monthly_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        SUM(oi.quantity * oi.price) AS product_revenue
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
monthly_comparison AS (
    SELECT
        *,
        SUM(product_revenue) OVER (
            PARTITION BY order_year, order_month
        ) AS monthly_company_revenue
    FROM product_monthly_revenue
)
SELECT
    product_id,
    product_name,
    category,
    order_year,
    order_month,
    ROUND(product_revenue, 2) AS product_revenue,
    ROUND(monthly_company_revenue, 2)
        AS monthly_company_revenue,
    ROUND(
        product_revenue * 100.0
        / NULLIF(monthly_company_revenue, 0),
        2
    ) AS revenue_contribution_percentage
FROM monthly_comparison
ORDER BY order_year, order_month, product_revenue DESC;


-- ============================================================
-- Q734: Products Generating Revenue in at Least
-- 6 Consecutive Calendar Months
-- ============================================================

WITH product_months AS (
    SELECT DISTINCT
        oi.product_id,
        EXTRACT(YEAR FROM o.order_date) * 12
            + EXTRACT(MONTH FROM o.order_date) AS month_index
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
),
numbered_months AS (
    SELECT
        product_id,
        month_index,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY month_index
        ) AS row_num
    FROM product_months
),
month_groups AS (
    SELECT
        product_id,
        month_index,
        month_index - row_num AS group_id
    FROM numbered_months
),
consecutive_periods AS (
    SELECT
        product_id,
        group_id,
        COUNT(*) AS consecutive_months,
        MIN(month_index) AS starting_month_index,
        MAX(month_index) AS ending_month_index
    FROM month_groups
    GROUP BY product_id, group_id
)
SELECT
    p.product_id,
    p.product_name,
    cp.consecutive_months,
    cp.starting_month_index,
    cp.ending_month_index
FROM consecutive_periods cp
JOIN products p
    ON cp.product_id = p.product_id
WHERE cp.consecutive_months >= 6
ORDER BY p.product_id, cp.starting_month_index;


-- ============================================================
-- Q735: Customers Who Purchased Products From
-- At Least 3 Different Categories
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT p.category) AS different_categories
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING COUNT(DISTINCT p.category) >= 3
ORDER BY different_categories DESC, c.customer_id;


-- ============================================================
-- Q736: Monthly Customer Retention
-- Customers Purchasing in Both Previous and Current Month
-- ============================================================

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        EXTRACT(YEAR FROM order_date) * 12
            + EXTRACT(MONTH FROM order_date) AS month_index
    FROM orders
),
monthly_retention AS (
    SELECT
        current_month.month_index,
        COUNT(DISTINCT current_month.customer_id)
            AS retained_customers
    FROM customer_months current_month
    JOIN customer_months previous_month
        ON current_month.customer_id =
           previous_month.customer_id
       AND current_month.month_index =
           previous_month.month_index + 1
    GROUP BY current_month.month_index
)
SELECT
    month_index,
    retained_customers
FROM monthly_retention
ORDER BY month_index;


-- ============================================================
-- Q737: Products With Profit Margin Greater Than
-- Their Category's Average Product Profit Margin
-- ============================================================

WITH product_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
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
),
category_comparison AS (
    SELECT
        *,
        AVG(profit_margin) OVER (
            PARTITION BY category
        ) AS category_average_margin
    FROM product_margins
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(profit_margin, 2) AS profit_margin,
    ROUND(category_average_margin, 2)
        AS category_average_margin
FROM category_comparison
WHERE profit_margin > category_average_margin
ORDER BY category, profit_margin DESC;


-- ============================================================
-- Q738: Each Customer's Longest Gap Between
-- Consecutive Purchases
-- MySQL 8.0+
-- ============================================================

WITH purchase_dates AS (
    SELECT DISTINCT
        customer_id,
        order_date
    FROM orders
),
purchase_gaps AS (
    SELECT
        customer_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_purchase_date
    FROM purchase_dates
),
gap_calculation AS (
    SELECT
        customer_id,
        order_date,
        previous_purchase_date,
        DATEDIFF(
            order_date,
            previous_purchase_date
        ) AS gap_days
    FROM purchase_gaps
)
SELECT
    customer_id,
    MAX(gap_days) AS longest_gap_days
FROM gap_calculation
WHERE gap_days IS NOT NULL
GROUP BY customer_id
ORDER BY longest_gap_days DESC, customer_id;


-- ============================================================
-- Q739: Monthly Category Profit and Category Ranking
-- ============================================================

WITH monthly_category_profit AS (
    SELECT
        p.category,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        SUM(
            oi.quantity * (oi.price - p.cost_price)
        ) AS total_profit
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        p.category,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),
category_ranking AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY order_year, order_month
            ORDER BY total_profit DESC
        ) AS profit_rank
    FROM monthly_category_profit
)
SELECT
    category,
    order_year,
    order_month,
    ROUND(total_profit, 2) AS total_profit,
    profit_rank
FROM category_ranking
ORDER BY order_year, order_month, profit_rank, category;


-- ============================================================
-- Q740: Complete Sales Performance Dashboard
-- One Row Per Product Category
--
-- Category-level revenue, cost, profit and margin.
-- Company-wide order count, units sold and average order value.
-- ============================================================

WITH category_metrics AS (
    SELECT
        p.category,
        SUM(oi.quantity * oi.price) AS total_revenue,
        SUM(oi.quantity * p.cost_price) AS total_cost,
        SUM(
            oi.quantity * (oi.price - p.cost_price)
        ) AS total_profit,
        COUNT(DISTINCT o.order_id) AS category_orders,
        SUM(oi.quantity) AS category_units_sold
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    GROUP BY p.category
),
company_order_metrics AS (
    SELECT
        COUNT(DISTINCT o.order_id) AS total_orders,
        COALESCE(SUM(oi.quantity), 0) AS total_products_sold,
        COALESCE(SUM(oi.quantity * oi.price), 0)
            AS company_revenue
    FROM orders o
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
),
company_metrics AS (
    SELECT
        total_orders,
        total_products_sold,
        company_revenue,
        company_revenue
            / NULLIF(total_orders, 0) AS average_order_value
    FROM company_order_metrics
)
SELECT
    cm.category,

    ROUND(cm.total_revenue, 2) AS category_revenue,
    ROUND(cm.total_cost, 2) AS category_cost,
    ROUND(cm.total_profit, 2) AS category_profit,

    ROUND(
        cm.total_profit * 100.0
        / NULLIF(cm.total_revenue, 0),
        2
    ) AS category_profit_margin_percentage,

    cm.category_orders,
    cm.category_units_sold,

    ROUND(
        cm.total_revenue * 100.0
        / NULLIF(company.company_revenue, 0),
        2
    ) AS revenue_contribution_percentage,

    company.total_orders AS company_total_orders,
    company.total_products_sold,
    ROUND(company.company_revenue, 2)
        AS company_total_revenue,
    ROUND(company.average_order_value, 2)
        AS company_average_order_value

FROM category_metrics cm
CROSS JOIN company_metrics company
ORDER BY cm.total_revenue DESC;


-- ============================================================
-- END OF DAY 74
-- Queries: Q731-Q740
-- Total Progress: 740 / 1000 = 74%
-- Remaining: 260 queries
-- ============================================================
