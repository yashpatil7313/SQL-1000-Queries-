  -- ============================================================
-- Day 71: Advanced SQL Analytics & Interview Practice
-- Queries: Q701 to Q710
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
-- Q701: Customers With Revenue Increasing for 3 Consecutive
-- Calendar Months
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.customer_id,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),
previous_values AS (
    SELECT
        *,
        LAG(revenue, 1) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS previous_revenue,
        LAG(order_year, 1) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS previous_year,
        LAG(order_month, 1) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS previous_month,
        LAG(revenue, 2) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS revenue_two_months_ago,
        LAG(order_year, 2) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS year_two_months_ago,
        LAG(order_month, 2) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS month_two_months_ago
    FROM monthly_revenue
)
SELECT DISTINCT
    customer_id
FROM previous_values
WHERE
    previous_revenue > revenue_two_months_ago
    AND revenue > previous_revenue

    -- Ensure the previous record is the previous calendar month.
    AND (
        (order_year = previous_year
         AND order_month = previous_month + 1)
        OR
        (order_year = previous_year + 1
         AND order_month = 1
         AND previous_month = 12)
    )

    -- Ensure the record two positions back is also
    -- exactly two calendar months earlier.
    AND (
        (order_year = year_two_months_ago
         AND order_month = month_two_months_ago + 2)
        OR
        (order_year = year_two_months_ago
         AND order_month = month_two_months_ago + 1
         AND previous_month = month_two_months_ago + 1)
        OR
        (order_year = year_two_months_ago + 1
         AND order_month = 1
         AND month_two_months_ago = 11)
        OR
        (order_year = year_two_months_ago + 1
         AND order_month = 2
         AND month_two_months_ago = 12)
    )
ORDER BY customer_id;


-- ============================================================
-- Q702: Second-Highest Revenue Product in Each Category
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
    total_revenue,
    revenue_rank
FROM ranked_products
WHERE revenue_rank = 2
ORDER BY category, product_name;


-- ============================================================
-- Q703: Cumulative Revenue and Cumulative Revenue Percentage
-- ============================================================

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.price) AS total_revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name
),
running_revenue AS (
    SELECT
        product_id,
        product_name,
        total_revenue,
        SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC, product_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue,
        SUM(total_revenue) OVER () AS company_revenue
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    total_revenue,
    cumulative_revenue,
    ROUND(
        cumulative_revenue * 100.0
        / NULLIF(company_revenue, 0),
        2
    ) AS cumulative_revenue_percentage
FROM running_revenue
ORDER BY total_revenue DESC, product_id;


-- ============================================================
-- Q704: Customers Who Purchased From Every Category
-- ============================================================

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM (
        SELECT DISTINCT category
        FROM products
        WHERE category IS NOT NULL
    ) categories
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id
        JOIN products p
            ON oi.product_id = p.product_id
        WHERE o.customer_id = c.customer_id
          AND p.category = categories.category
    )
)
ORDER BY c.customer_id;


-- ============================================================
-- Q705: Product Pairs Frequently Purchased Together
-- ============================================================

WITH product_pairs AS (
    SELECT
        oi1.product_id AS product_id_1,
        oi2.product_id AS product_id_2,
        COUNT(DISTINCT oi1.order_id) AS orders_together
    FROM order_items oi1
    JOIN order_items oi2
        ON oi1.order_id = oi2.order_id
       AND oi1.product_id < oi2.product_id
    GROUP BY
        oi1.product_id,
        oi2.product_id
),
ranked_pairs AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            ORDER BY orders_together DESC
        ) AS pair_rank
    FROM product_pairs
)
SELECT
    rp.product_id_1,
    p1.product_name AS product_1,
    rp.product_id_2,
    p2.product_name AS product_2,
    rp.orders_together,
    rp.pair_rank
FROM ranked_pairs rp
JOIN products p1
    ON rp.product_id_1 = p1.product_id
JOIN products p2
    ON rp.product_id_2 = p2.product_id
WHERE rp.pair_rank <= 10
ORDER BY rp.pair_rank, product_1, product_2;


-- ============================================================
-- Q706: Monthly Revenue Growth Classification
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
),
comparison AS (
    SELECT
        *,
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
    ROUND(
        (revenue - previous_revenue) * 100.0
        / NULLIF(previous_revenue, 0),
        2
    ) AS growth_percentage,
    CASE
        WHEN previous_revenue IS NULL
            THEN 'No Previous Month'
        WHEN revenue > previous_revenue
            THEN 'Growth'
        WHEN revenue < previous_revenue
            THEN 'Decline'
        ELSE 'No Change'
    END AS revenue_trend
FROM comparison
ORDER BY order_year, order_month;


-- ============================================================
-- Q707: Customers Whose Latest Order Exceeds Their Average
-- Order Value
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
customer_analysis AS (
    SELECT
        *,
        AVG(order_value) OVER (
            PARTITION BY customer_id
        ) AS average_order_value,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS latest_order_rank
    FROM order_values
)
SELECT
    ca.customer_id,
    c.customer_name,
    ca.order_id AS latest_order_id,
    ca.order_date AS latest_order_date,
    ca.order_value AS latest_order_value,
    ROUND(ca.average_order_value, 2) AS average_order_value
FROM customer_analysis ca
JOIN customers c
    ON ca.customer_id = c.customer_id
WHERE ca.latest_order_rank = 1
  AND ca.order_value > ca.average_order_value
ORDER BY ca.order_value DESC;


-- ============================================================
-- Q708: Category Contribution to Total Monthly Profit
-- ============================================================

WITH monthly_category_profit AS (
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        p.category,
        SUM(
            oi.quantity * (oi.price - p.cost_price)
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
)
SELECT
    order_year,
    order_month,
    category,
    profit,
    SUM(profit) OVER (
        PARTITION BY order_year, order_month
    ) AS monthly_total_profit,
    ROUND(
        profit * 100.0
        / NULLIF(
            SUM(profit) OVER (
                PARTITION BY order_year, order_month
            ),
            0
        ),
        2
    ) AS profit_contribution_percentage
FROM monthly_category_profit
ORDER BY order_year, order_month, profit DESC;


-- ============================================================
-- Q709: Products With Declining Revenue for 3 Consecutive
-- Calendar Months
-- ============================================================

WITH monthly_product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        EXTRACT(YEAR FROM o.order_date) AS order_year,
        EXTRACT(MONTH FROM o.order_date) AS order_month,
        SUM(oi.quantity * oi.price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    GROUP BY
        p.product_id,
        p.product_name,
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
),
previous_values AS (
    SELECT
        *,
        LAG(revenue, 1) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS previous_revenue,
        LAG(revenue, 2) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS revenue_two_months_ago,
        LAG(order_year, 1) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS previous_year,
        LAG(order_month, 1) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS previous_month,
        LAG(order_year, 2) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS year_two_months_ago
