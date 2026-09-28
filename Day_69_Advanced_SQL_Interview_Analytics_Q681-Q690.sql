-- ============================================================
-- Day 69: Advanced SQL Interview & Real-World Analytics
-- Queries: Q681 to Q690
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
-- Q681: First and Second Purchase Date of Every Customer
-- ============================================================
-- ROW_NUMBER() assigns purchase sequence to each customer's
-- orders.
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
)

SELECT
    c.customer_id,
    c.customer_name,

    MIN(
        CASE
            WHEN ro.purchase_number = 1
            THEN ro.order_date
        END
    ) AS first_purchase_date,

    MIN(
        CASE
            WHEN ro.purchase_number = 2
            THEN ro.order_date
        END
    ) AS second_purchase_date

FROM customers c

LEFT JOIN ranked_orders ro
    ON c.customer_id = ro.customer_id

GROUP BY
    c.customer_id,
    c.customer_name

ORDER BY
    c.customer_id;


-- ============================================================
-- Q682: Customers Whose Second Purchase Happened
-- Within 30 Days of First Purchase
-- ============================================================

WITH ranked_orders AS (

    SELECT
        customer_id,
        order_date,

        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS purchase_number

    FROM orders
),

purchase_dates AS (

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

    GROUP BY
        customer_id
)

SELECT
    c.customer_id,
    c.customer_name,
    pd.first_purchase_date,
    pd.second_purchase_date,

    DATEDIFF(
        pd.second_purchase_date,
        pd.first_purchase_date
    ) AS days_to_second_purchase

FROM purchase_dates pd

JOIN customers c
    ON pd.customer_id = c.customer_id

WHERE
    pd.second_purchase_date IS NOT NULL
    AND DATEDIFF(
        pd.second_purchase_date,
        pd.first_purchase_date
    ) <= 30

ORDER BY
    days_to_second_purchase;


-- ============================================================
-- Q683: Monthly Customer Retention Rate
-- ============================================================
-- A returning customer is a customer who purchased in the
-- previous month and also purchased in the current month.
--
-- Retention Rate =
-- Returning Customers / Previous Month Customers * 100
-- ============================================================

WITH monthly_customers AS (

    SELECT DISTINCT
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        customer_id

    FROM orders
),

monthly_counts AS (

    SELECT
        order_year,
        order_month,

        COUNT(DISTINCT customer_id)
            AS current_month_customers

    FROM monthly_customers

    GROUP BY
        order_year,
        order_month
),

retention AS (

    SELECT
        current_month.order_year,
        current_month.order_month,

        current_month.current_month_customers,

        previous_month.current_month_customers
            AS previous_month_customers,

        COUNT(
            DISTINCT
            CASE
                WHEN previous_month.customer_id IS NOT NULL
                THEN current_month.customer_id
            END
        ) AS retained_customers

    FROM monthly_customers current_month

    LEFT JOIN monthly_customers previous_month

        ON current_month.customer_id =
           previous_month.customer_id

        AND (
            (
                current_month.order_year =
                previous_month.order_year
                AND current_month.order_month =
                previous_month.order_month + 1
            )
            OR
            (
                current_month.order_year =
                previous_month.order_year + 1
                AND current_month.order_month = 1
                AND previous_month.order_month = 12
            )
        )

    LEFT JOIN monthly_counts previous_month_count

        ON (
            (
                current_month.order_year =
                previous_month_count.order_year
                AND current_month.order_month =
                previous_month_count.order_month + 1
            )
            OR
            (
                current_month.order_year =
                previous_month_count.order_year + 1
                AND current_month.order_month = 1
                AND previous_month_count.order_month = 12
            )
        )

    JOIN monthly_counts current_month_count

        ON current_month.order_year =
           current_month_count.order_year

        AND current_month.order_month =
            current_month_count.order_month

    GROUP BY
        current_month.order_year,
        current_month.order_month,
        current_month_count.current_month_customers,
        previous_month_count.current_month_customers
)

SELECT
    order_year,
    order_month,

    current_month_customers,
    previous_month_customers,
    retained_customers,

    ROUND(
        retained_customers * 100.0
        / NULLIF(previous_month_customers, 0),
        2
    ) AS retention_rate

FROM retention

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q684: Top 3 Customers by Revenue in Every City
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

ranked_customers AS (

    SELECT
        customer_id,
        customer_name,
        city,
        total_revenue,

        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY total_revenue DESC
        ) AS revenue_rank

    FROM customer_revenue
)

SELECT
    customer_id,
    customer_name,
    city,
    total_revenue,
    revenue_rank

FROM ranked_customers

WHERE
    revenue_rank <= 3

ORDER BY
    city,
    revenue_rank;


-- ============================================================
-- Q685: Products With Revenue Increasing for
-- 3 Consecutive Available Months
-- ============================================================
-- This checks three consecutive monthly records available
-- for each product.
-- ============================================================

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
        ) AS revenue

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

revenue_comparison AS (

    SELECT
        product_id,
        product_name,
        order_year,
        order_month,
        revenue,

        LAG(revenue, 1) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS previous_revenue,

        LAG(revenue, 2) OVER (
            PARTITION BY product_id
            ORDER BY order_year, order_month
        ) AS two_months_ago

    FROM monthly_product_revenue
)

SELECT DISTINCT
    product_id,
    product_name

FROM revenue_comparison

WHERE
    two_months_ago IS NOT NULL

    AND previous_revenue > two_months_ago

    AND revenue > previous_revenue

ORDER BY
    product_id;


-- ============================================================
-- Q686: Product Percentage Contribution
-- to Category Revenue
-- ============================================================
-- Formula:
--
-- Product Revenue
-- -------------------------- * 100
-- Total Category Revenue
-- ============================================================

WITH product_revenue AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category,

        SUM(
            oi.quantity * oi.price
        ) AS product_revenue

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
    product_revenue,

    SUM(product_revenue) OVER (
        PARTITION BY category
    ) AS category_revenue,

    ROUND(
        product_revenue * 100.0
        /
        NULLIF(
            SUM(product_revenue) OVER (
                PARTITION BY category
            ),
            0
        ),
        2
    ) AS category_revenue_percentage

FROM product_revenue

ORDER BY
    category,
    category_revenue_percentage DESC;


-- ============================================================
-- Q687: Customers Whose Latest Order Value
-- Is Greater Than Their First Order Value
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

ordered_values AS (

    SELECT
        order_id,
        customer_id,
        order_date,
        order_value,

        FIRST_VALUE(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS first_order_value,

        FIRST_VALUE(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC, order_id DESC
        ) AS latest_order_value

    FROM order_values
)

SELECT DISTINCT
    ov.customer_id,
    c.customer_name,

    ov.first_order_value,
    ov.latest_order_value,

    ROUND(
        ov.latest_order_value -
        ov.first_order_value,
        2
    ) AS order_value_difference

FROM ordered_values ov

JOIN customers c
    ON ov.customer_id = c.customer_id

WHERE
    ov.latest_order_value >
    ov.first_order_value

ORDER BY
    order_value_difference DESC;


-- ============================================================
-- Q688: Monthly Average Order Value
-- and Month-over-Month Change
-- ============================================================

WITH order_values AS (

    SELECT
        o.order_id,
        o.order_date,

        SUM(
            oi.quantity * oi.price
        ) AS order_value

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        o.order_id,
        o.order_date
),

monthly_aov AS (

    SELECT
        EXTRACT(YEAR FROM order_date)
            AS order_year,

        EXTRACT(MONTH FROM order_date)
            AS order_month,

        AVG(order_value)
            AS average_order_value

    FROM order_values

    GROUP BY
        EXTRACT(YEAR FROM order_date),
        EXTRACT(MONTH FROM order_date)
),

aov_comparison AS (

    SELECT
        order_year,
        order_month,
        average_order_value,

        LAG(average_order_value) OVER (
            ORDER BY order_year, order_month
        ) AS previous_month_aov

    FROM monthly_aov
)

SELECT
    order_year,
    order_month,

    ROUND(
        average_order_value,
        2
    ) AS average_order_value,

    ROUND(
        previous_month_aov,
        2
    ) AS previous_month_aov,

    ROUND(
        average_order_value -
        previous_month_aov,
        2
    ) AS aov_difference,

    ROUND(
        (
            average_order_value -
            previous_month_aov
        ) * 100.0
        /
        NULLIF(previous_month_aov, 0),
        2
    ) AS aov_growth_percentage

FROM aov_comparison

ORDER BY
    order_year,
    order_month;


-- ============================================================
-- Q689: Category With Highest Profit Growth
-- Compared With Previous Month
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

profit_growth AS (

    SELECT
        order_year,
        order_month,
        category,
        profit,

        LAG(profit) OVER (
            PARTITION BY category
            ORDER BY order_year, order_month
        ) AS previous_profit

    FROM monthly_category_profit
),

growth_calculation AS (

    SELECT
        order_year,
        order_month,
        category,
        profit,
        previous_profit,

        (
            profit - previous_profit
        ) AS profit_difference,

        (
            (profit - previous_profit) * 100.0
            /
            NULLIF(previous_profit, 0)
        ) AS growth_percentage

    FROM profit_growth

    WHERE
        previous_profit IS NOT NULL
)

SELECT
    order_year,
    order_month,
    category,

    ROUND(profit, 2) AS profit,
    ROUND(previous_profit, 2) AS previous_profit,

    ROUND(
        profit_difference,
        2
    ) AS profit_difference,

    ROUND(
        growth_percentage,
        2
    ) AS growth_percentage

FROM growth_calculation

ORDER BY
    growth_percentage DESC;


-- ============================================================
-- Q690: Advanced Customer RFM Report
-- ============================================================
-- RFM:
--
-- R = Recency
--     How recently did the customer purchase?
--
-- F = Frequency
--     How many orders did the customer make?
--
-- M = Monetary
--     How much revenue did the customer generate?
--
-- NTILE(5) creates five groups.
--
-- Higher:
-- Recency score = More recent
-- Frequency score = More orders
-- Monetary score = More revenue
-- ============================================================

WITH latest_date AS (

    SELECT
        MAX(order_date) AS dataset_latest_date

    FROM orders
),

customer_metrics AS (

    SELECT
        c.customer_id,
        c.customer_name,

        MAX(o.order_date)
            AS last_purchase_date,

        COUNT(
            DISTINCT o.order_id
        ) AS frequency,

        SUM(
            oi.quantity * oi.price
        ) AS monetary

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.customer_name
),

rfm_values AS (

    SELECT
        cm.customer_id,
        cm.customer_name,

        DATEDIFF(
            ld.dataset_latest_date,
            cm.last_purchase_date
        ) AS recency,

        cm.frequency,
        cm.monetary

    FROM customer_metrics cm

    CROSS JOIN latest_date ld
),

rfm_scores AS (

    SELECT
        customer_id,
        customer_name,

        recency,
        frequency,
        monetary,

        NTILE(5) OVER (
            ORDER BY recency DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary
        ) AS monetary_score

    FROM rfm_values
),

final_rfm AS (

    SELECT
        customer_id,
        customer_name,

        recency,
        frequency,
        monetary,

        recency_score,
        frequency_score,
        monetary_score,

        (
            recency_score +
            frequency_score +
            monetary_score
        ) AS rfm_score

    FROM rfm_scores
)

SELECT
    customer_id,
    customer_name,

    recency,
    frequency,

    ROUND(
        monetary,
        2
    ) AS monetary,

    recency_score,
    frequency_score,
    monetary_score,

    rfm_score,

    CASE

        WHEN rfm_score >= 13
            THEN 'Champions'

        WHEN rfm_score >= 10
            THEN 'Loyal Customers'

        WHEN rfm_score >= 7
            THEN 'Potential Customers'

        WHEN rfm_score >= 5
            THEN 'At Risk'

        ELSE 'Low Value'

    END AS customer_segment

FROM final_rfm

ORDER BY
    rfm_score DESC,
    monetary DESC;


-- ============================================================
-- END OF DAY 69
-- Queries: Q681 - Q690
-- Progress: 690 / 1000 = 69%
-- ============================================================
