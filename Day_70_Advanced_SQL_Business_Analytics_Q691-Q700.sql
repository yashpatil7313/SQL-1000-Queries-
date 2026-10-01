-- ============================================================
-- Day 70: Advanced SQL & Real-World Business Analytics
-- Queries: Q691 to Q700
-- Progress: 700 / 1000 = 70%
-- ============================================================


-- ============================================================
-- Q691: Customer Monthly Spending Trend
-- ============================================================
-- Find each customer's monthly revenue and compare it
-- with the previous month's revenue.

WITH monthly_customer_revenue AS (

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

revenue_comparison AS (

    SELECT
        customer_id,
        order_year,
        order_month,
        revenue,

        LAG(revenue) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS previous_month_revenue

    FROM monthly_customer_revenue
)

SELECT
    customer_id,
    order_year,
    order_month,

    ROUND(revenue, 2) AS revenue,

    ROUND(
        previous_month_revenue,
        2
    ) AS previous_month_revenue,

    ROUND(
        revenue - previous_month_revenue,
        2
    ) AS revenue_difference,

    ROUND(
        (revenue - previous_month_revenue) * 100.0
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS growth_percentage

FROM revenue_comparison

ORDER BY
    customer_id,
    order_year,
    order_month;


-- ============================================================
-- Q692: Customers With Increasing Spending
-- for 3 Consecutive Available Months
-- ============================================================

WITH monthly_customer_revenue AS (

    SELECT
        customer_id,

        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,

        SUM(
            oi.quantity * oi.price
        ) AS revenue

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        customer_id,
        EXTRACT(YEAR FROM order_date),
        EXTRACT(MONTH FROM order_date)
),

revenue_comparison AS (

    SELECT
        customer_id,
        order_year,
        order_month,
        revenue,

        LAG(revenue, 1) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS previous_revenue,

        LAG(revenue, 2) OVER (
            PARTITION BY customer_id
            ORDER BY order_year, order_month
        ) AS two_months_ago

    FROM monthly_customer_revenue
)

SELECT DISTINCT
    customer_id

FROM revenue_comparison

WHERE
    two_months_ago IS NOT NULL
    AND previous_revenue > two_months_ago
    AND revenue > previous_revenue

ORDER BY
    customer_id;


-- ============================================================
-- Q693: Top Product by Revenue in Each Category
-- ============================================================
-- DENSE_RANK() allows ties.

WITH product_revenue AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity * oi.price
        ) AS total_revenue

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
        total_revenue,

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

WHERE revenue_rank = 1

ORDER BY
    category;


-- ============================================================
-- Q694: Customers With Revenue Above City Average
-- ============================================================

WITH customer_revenue AS (

    SELECT
        c.customer_id,
        c.customer_name,
        c.city,

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
        c.customer_name,
        c.city
),

city_analysis AS (

    SELECT
        customer_id,
        customer_name,
        city,
        total_revenue,

        AVG(total_revenue) OVER (
            PARTITION BY city
        ) AS city_average_revenue

    FROM customer_revenue
)

SELECT
    customer_id,
    customer_name,
    city,

    ROUND(
        total_revenue,
        2
    ) AS total_revenue,

    ROUND(
        city_average_revenue,
        2
    ) AS city_average_revenue,

    ROUND(
        total_revenue - city_average_revenue,
        2
    ) AS difference_from_city_average

FROM city_analysis

WHERE
    total_revenue > city_average_revenue

ORDER BY
    city,
    total_revenue DESC;


-- ============================================================
-- Q695: Product Profit Contribution
-- ============================================================
-- Calculate each product's profit and its percentage
-- contribution to total company profit.

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
)

SELECT
    product_id,
    product_name,
    category,

    ROUND(
        total_profit,
        2
    ) AS total_profit,

    ROUND(
        SUM(total_profit) OVER (),
        2
    ) AS company_total_profit,

    ROUND(
        total_profit * 100.0
        /
        NULLIF(
            SUM(total_profit) OVER (),
            0
        ),
        2
    ) AS profit_contribution_percentage

FROM product_profit

ORDER BY
    profit_contribution_percentage DESC;


-- ============================================================
-- Q696: Monthly New Customer Revenue
-- ============================================================
-- Calculate revenue generated by customers during the
-- month in which they made their first-ever purchase.

WITH first_customer_order AS (

    SELECT
        customer_id,

        MIN(order_date) AS first_order_date

    FROM orders

    GROUP BY
        customer_id
),

new_customer_revenue AS (

    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,

        SUM(
            oi.quantity * oi.price
        ) AS order_value

    FROM orders o

    JOIN first_customer_order fco
        ON o.customer_id = fco.customer_id
        AND o.order_date = fco.first_order_date

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_date
)

SELECT
    EXTRACT(YEAR FROM order_date)
        AS order_year,

    EXTRACT(MONTH FROM order_date)
        AS order_month,

    COUNT(DISTINCT customer_id)
        AS new_customers,

    ROUND(
        SUM(order_value),
        2
    ) AS new_customer_revenue

FROM new_customer_revenue

GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q697: Customer Purchase Gap Analysis
-- ============================================================
-- Calculate the gap between consecutive purchases.
-- Then identify customers whose average purchase gap
-- is greater than 60 days.

WITH customer_orders AS (

    SELECT
        customer_id,
        order_id,
        order_date,

        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_date

    FROM orders
),

purchase_gaps AS (

    SELECT
        customer_id,
        order_id,
        order_date,
        previous_order_date,

        DATEDIFF(
            order_date,
            previous_order_date
        ) AS gap_days

    FROM customer_orders

    WHERE
        previous_order_date IS NOT NULL
),

customer_gap_summary AS (

    SELECT
        customer_id,

        COUNT(*) AS number_of_gaps,

        AVG(gap_days) AS average_purchase_gap,

        MAX(gap_days) AS maximum_purchase_gap

    FROM purchase_gaps

    GROUP BY
        customer_id
)

SELECT
    cgs.customer_id,
    c.customer_name,

    cgs.number_of_gaps,

    ROUND(
        cgs.average_purchase_gap,
        2
    ) AS average_purchase_gap_days,

    cgs.maximum_purchase_gap

FROM customer_gap_summary cgs

JOIN customers c
    ON cgs.customer_id = c.customer_id

WHERE
    cgs.average_purchase_gap > 60

ORDER BY
    average_purchase_gap_days DESC;


-- ============================================================
-- Q698: Category Revenue Ranking by Month
-- ============================================================
-- Find the Top 3 revenue-generating categories
-- for every month.

WITH monthly_category_revenue AS (

    SELECT
        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        p.category,

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
        p.category
),

ranked_categories AS (

    SELECT
        order_year,
        order_month,
        category,
        revenue,

        DENSE_RANK() OVER (
            PARTITION BY order_year, order_month
            ORDER BY revenue DESC
        ) AS category_rank

    FROM monthly_category_revenue
)

SELECT
    order_year,
    order_month,
    category,
    ROUND(revenue, 2) AS revenue,
    category_rank

FROM ranked_categories

WHERE
    category_rank <= 3

ORDER BY
    order_year,
    order_month,
    category_rank;


-- ============================================================
-- Q699: Product Sales Consistency
-- ============================================================
-- Find products that generated revenue in at least
-- 6 different months.
--
-- Calculate their average monthly revenue.

WITH monthly_product_revenue AS (

    SELECT
        p.product_id,
        p.product_name,

        EXTRACT(YEAR FROM o.order_date)
            AS order_year,

        EXTRACT(MONTH FROM o.order_date)
            AS order_month,

        SUM(
            oi.quantity * oi.price
        ) AS monthly_revenue

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
)

SELECT
    product_id,
    product_name,

    COUNT(*) AS active_months,

    ROUND(
        AVG(monthly_revenue),
        2
    ) AS average_monthly_revenue,

    ROUND(
        SUM(monthly_revenue),
        2
    ) AS total_revenue

FROM monthly_product_revenue

GROUP BY
    product_id,
    product_name

HAVING
    COUNT(*) >= 6

ORDER BY
    active_months DESC,
    average_monthly_revenue DESC;


-- ============================================================
-- Q700: Advanced Customer Performance Dashboard
-- ============================================================
-- Complete customer-level business intelligence report.
--
-- Includes:
-- 1. Total Orders
-- 2. Total Revenue
-- 3. Average Order Value
-- 4. First Order Date
-- 5. Latest Order Date
-- 6. Days Since Latest Order
-- 7. Revenue Rank
-- 8. Revenue Percentile
-- 9. Customer Segment
-- ============================================================

WITH customer_metrics AS (

    SELECT
        c.customer_id,
        c.customer_name,
        c.city,

        COUNT(
            DISTINCT o.order_id
        ) AS total_orders,

        SUM(
            oi.quantity * oi.price
        ) AS total_revenue,

        MIN(o.order_date)
            AS first_order_date,

        MAX(o.order_date)
            AS latest_order_date

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

latest_dataset_date AS (

    SELECT
        MAX(order_date)
            AS dataset_latest_date

    FROM orders
),

customer_analysis AS (

    SELECT
        cm.customer_id,
        cm.customer_name,
        cm.city,

        cm.total_orders,
        cm.total_revenue,

        cm.total_revenue /
        NULLIF(cm.total_orders, 0)
            AS average_order_value,

        cm.first_order_date,
        cm.latest_order_date,

        DATEDIFF(
            ldd.dataset_latest_date,
            cm.latest_order_date
        ) AS days_since_latest_order

    FROM customer_metrics cm

    CROSS JOIN latest_dataset_date ldd
),

ranked_customers AS (

    SELECT
        customer_id,
        customer_name,
        city,

        total_orders,
        total_revenue,
        average_order_value,

        first_order_date,
        latest_order_date,
        days_since_latest_order,

        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank,

        PERCENT_RANK() OVER (
            ORDER BY total_revenue
        ) AS revenue_percentile

    FROM customer_analysis
)

SELECT
    customer_id,
    customer_name,
    city,

    total_orders,

    ROUND(
        total_revenue,
        2
    ) AS total_revenue,

    ROUND(
        average_order_value,
        2
    ) AS average_order_value,

    first_order_date,
    latest_order_date,

    days_since_latest_order,

    revenue_rank,

    ROUND(
        revenue_percentile,
        2
    ) AS revenue_percentile,

    CASE

        WHEN revenue_rank <= 3
            THEN 'Top Customer'

        WHEN total_revenue >=
             (
                SELECT AVG(total_revenue)
                FROM customer_analysis
             )
            THEN 'High Value'

        WHEN total_revenue >=
             (
                SELECT AVG(total_revenue)
                FROM customer_analysis
             ) * 0.5
            THEN 'Medium Value'

        ELSE 'Low Value'

    END AS customer_segment

FROM ranked_customers

ORDER BY
    revenue_rank;


-- ============================================================
-- END OF DAY 70
-- ============================================================
-- Queries: Q691 - Q700
-- Progress: 700 / 1000 = 70%
--
-- MILESTONE REACHED: 70%
-- ============================================================
