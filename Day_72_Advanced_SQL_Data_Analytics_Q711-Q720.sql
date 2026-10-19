-- ============================================================
-- Day 72: Advanced SQL & Real-World Data Analytics
-- Queries: Q711 to Q720
-- Database: MySQL 8.0+ / PostgreSQL
--
-- Assumed tables:
-- customers(customer_id, customer_name, city)
-- products(product_id, product_name, category, price, cost_price)
-- orders(order_id, customer_id, order_date, status)
-- order_items(order_id, product_id, quantity, price)
--
-- Revenue = quantity * selling price
-- Profit  = quantity * (selling price - cost price)
-- ============================================================


-- ============================================================
-- Q711: Customers Whose Monthly Revenue Increased
-- for 3 Consecutive Calendar Months
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        EXTRACT(YEAR FROM o.order_date) * 12
            + EXTRACT(MONTH FROM o.order_date) AS month_index,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),
comparisons AS (
    SELECT
        *,
        LAG(revenue, 1) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS previous_revenue,
        LAG(revenue, 2) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS revenue_two_months_ago,
        LAG(month_index, 1) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS previous_month_index,
        LAG(month_index, 2) OVER (
            PARTITION BY customer_id
            ORDER BY month_index
        ) AS two_months_ago_index
    FROM monthly_revenue
)
SELECT DISTINCT
    customer_id
FROM comparisons
WHERE
    revenue > previous_revenue
    AND previous_revenue > revenue_two_months_ago
    AND month_index - previous_month_index = 1
    AND month_index - two_months_ago_index = 2
ORDER BY customer_id;


-- ============================================================
-- Q712: Top 5 Products by Profit in Each Category
-- Include ties.
-- ============================================================

WITH product_profit AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
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
    profit_rank
FROM ranked_products
WHERE profit_rank <= 5
ORDER BY category, profit_rank, product_name;


-- ============================================================
-- Q713: Customer Cumulative Spending Across Orders
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
)
SELECT
    customer_id,
    order_id,
    order_date,
    ROUND(order_value, 2) AS order_value,
    ROUND(
        SUM(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_spending
FROM order_values
ORDER BY customer_id, order_date, order_id;


-- ============================================================
-- Q714: Customers Who Purchased in One Month
-- but Not in the Following Calendar Month
-- ============================================================

WITH customer_months AS (
    SELECT DISTINCT
        customer_id,
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        EXTRACT(YEAR FROM order_date) * 12
            + EXTRACT(MONTH FROM order_date) AS month_index
    FROM orders
)
SELECT
    cm.customer_id,
    c.customer_name,
    cm.order_year,
    cm.order_month
FROM customer_months cm
JOIN customers c
    ON cm.customer_id = c.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM customer_months next_month
    WHERE next_month.customer_id = cm.customer_id
      AND next_month.month_index = cm.month_index + 1
)
ORDER BY
    cm.order_year,
    cm.order_month,
    cm.customer_id;


-- ============================================================
-- Q715: Most Frequently Purchased Product in Each City
-- Frequency = number of distinct orders containing the product.
-- Include ties.
-- ============================================================

WITH product_city_frequency AS (
    SELECT
        c.city,
        p.product_id,
        p.product_name,
        COUNT(DISTINCT o.order_id) AS order_frequency
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        c.city,
        p.product_id,
        p.product_name
),
ranked_products AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY order_frequency DESC
        ) AS product_rank
    FROM product_city_frequency
)
SELECT
    city,
    product_id,
    product_name,
    order_frequency,
    product_rank
FROM ranked_products
WHERE product_rank = 1
ORDER BY city, product_name;


-- ============================================================
-- Q716: Product Contribution to Category Quantity Sold
-- ============================================================

WITH product_quantity AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS quantity_sold
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
    quantity_sold,
    SUM(quantity_sold) OVER (
        PARTITION BY category
    ) AS category_quantity,
    ROUND(
        quantity_sold * 100.0
        / NULLIF(
            SUM(quantity_sold) OVER (
                PARTITION BY category
            ),
            0
        ),
        2
    ) AS category_quantity_percentage
FROM product_quantity
ORDER BY category, quantity_sold DESC;


-- ============================================================
-- Q717: Orders Above Both Customer Average
-- and Overall Average
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
order_averages AS (
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
FROM order_averages
WHERE order_value > customer_average
  AND order_value > overall_average
ORDER BY order_value DESC;


-- ============================================================
-- Q718: Monthly Revenue, Previous Month Revenue,
-- and Year-over-Year Growth
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        EXTRACT(YEAR FROM o.order_date) * 12
            + EXTRACT(MONTH FROM o.order_date) AS month_index,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),
revenue_comparison AS (
    SELECT
        *,
        LAG(revenue, 1) OVER (
            ORDER BY month_index
        ) AS previous_month_revenue,
        LAG(revenue, 12) OVER (
            ORDER BY month_index
        ) AS previous_year_revenue
    FROM monthly_revenue
)
SELECT
    order_year,
    order_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(previous_month_revenue, 2)
        AS previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS month_over_month_growth_percentage,
    ROUND(previous_year_revenue, 2)
        AS previous_year_revenue,
    ROUND(
        (revenue - previous_year_revenue) * 100.0
        / NULLIF(previous_year_revenue, 0),
        2
    ) AS year_over_year_growth_percentage
FROM revenue_comparison
ORDER BY order_year, order_month;


-- ============================================================
-- Q719: Customers Whose Every Order Contains
-- at Least 3 Different Products
-- ============================================================

WITH order_product_counts AS (
    SELECT
        o.customer_id,
        o.order_id,
        COUNT(DISTINCT oi.product_id) AS distinct_products
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.customer_id,
        o.order_id
)
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(*) AS total_orders,
    MIN(opc.distinct_products) AS minimum_products_in_an_order
FROM order_product_counts opc
JOIN customers c
    ON opc.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name
HAVING MIN(opc.distinct_products) >= 3
ORDER BY c.customer_id;


-- ============================================================
-- Q720: Comprehensive Product Performance Dashboard
-- ============================================================

WITH product_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.quantity * oi.price) AS total_revenue,
        SUM(oi.quantity * p.cost_price) AS total_cost,
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
product_analysis AS (
    SELECT
        *,
        total_profit * 100.0
            / NULLIF(total_revenue, 0) AS profit_margin_percentage,
        SUM(total_revenue) OVER (
            PARTITION BY category
        ) AS category_revenue,
        SUM(total_profit) OVER () AS company_total_profit,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS overall_revenue_rank,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS category_revenue_rank
    FROM product_metrics
)
SELECT
    product_id,
    product_name,
    category,
    total_quantity_sold,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_cost, 2) AS total_cost,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(profit_margin_percentage, 2)
        AS profit_margin_percentage,
    ROUND(
        total_revenue * 100.0
        / NULLIF(category_revenue, 0),
        2
    ) AS category_revenue_contribution_percentage,
    ROUND(
        total_profit * 100.0
        / NULLIF(company_total_profit, 0),
        2
    ) AS company_profit_contribution_percentage,
    overall_revenue_rank,
    category_revenue_rank
FROM product_analysis
ORDER BY overall_revenue_rank, product_id;


-- ============================================================
-- END OF DAY 72
-- Queries: Q711-Q720
-- Progress: 720 / 1000 = 72%
-- ============================================================
