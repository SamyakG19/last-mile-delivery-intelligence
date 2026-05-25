-- Q1: Overall OTIF Rate (12-day SLA from purchase date)
-- Definition: Order delivered within 12 days of purchase = On Time
-- Avg actual delivery = 12.5 days | Industry benchmark = 85%+
-- Finding: 40.37% of orders are FAILING SLA
SELECT
    COUNT(*)  AS total_delivered,
    SUM(is_on_time)  AS on_time_count,
    COUNT(*) - SUM(is_on_time) AS failed_sla_count,
    ROUND(100.0 * SUM(is_on_time) / COUNT(*), 2)  AS otif_pct,
    ROUND(100.0 * (COUNT(*) - SUM(is_on_time))
          / COUNT(*), 2) AS failure_rate_pct,
    ROUND(AVG(actual_delivery_days), 1)  AS avg_delivery_days
FROM fact_shipments
WHERE is_delivered = 1;

-- Q2: Monthly OTIF trend over time
SELECT
    STRFTIME('%Y-%m', order_purchase_timestamp) AS month,
    COUNT(*) AS total_orders,
    ROUND(100.0 * SUM(is_on_time) / COUNT(*), 2) AS otif_pct
FROM fact_shipments
WHERE is_delivered = 1
GROUP BY STRFTIME('%Y-%m', order_purchase_timestamp)
ORDER BY month ASC;

-- Q3: Top 10 states with highest late delivery rate

SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN f.is_on_time = 0 THEN 1 ELSE 0 END) AS late_deliveries,
    ROUND(100.0 *SUM(CASE WHEN f.is_on_time = 0 THEN 1 ELSE 0 END)/ COUNT(*), 2) AS late_pct
FROM fact_shipments f
JOIN customers c ON f.customer_id = c.customer_id
WHERE f.is_delivered = 1
GROUP BY c.customer_state
ORDER BY late_pct DESC
LIMIT 10;

-- Q4 : SLA breach severity bucket
SELECT
    CASE
        WHEN actual_delivery_days <= 7  THEN '1. Fast (0-7 days)'
        WHEN actual_delivery_days <= 12 THEN '2. On time (8-12 days)'
        WHEN actual_delivery_days <= 20 THEN '3. Slow (13-20 days)'
        WHEN actual_delivery_days <= 30 THEN '4. Very slow (21-30 days)'
        ELSE                                 '5. Critical (30+ days)'
    END AS delivery_bucket,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM fact_shipments
WHERE is_delivered = 1
AND actual_delivery_days IS NOT NULL
GROUP BY delivery_bucket
ORDER BY delivery_bucket;

-- Q5: Delivery performance by product price tier
SELECT
    CASE
        WHEN price < 50   THEN 'Budget (under R$50)'
        WHEN price < 200  THEN 'Mid-range (R$50-200)'
        ELSE 'Premium (R$200+)'
    END AS price_tier,
    COUNT(*)  AS order_count,
    ROUND(AVG(actual_delivery_days), 2) AS avg_delivery_days,
    ROUND(100.0 * SUM(is_on_time) / COUNT(*), 2)  AS otif_pct,
    ROUND(MIN(actual_delivery_days), 1)  AS fastest_delivery,
    ROUND(MAX(actual_delivery_days), 1) AS slowest_delivery
FROM fact_shipments
WHERE is_delivered = 1
AND actual_delivery_days IS NOT NULL
GROUP BY price_tier
ORDER BY avg_delivery_days DESC;

-- Q6: Financial exposure from delivery failures
SELECT
    COUNT(*)                                AS late_orders,
    ROUND(SUM(price), 2)                    AS gmv_at_risk,
    ROUND(SUM(freight_value), 2)            AS freight_at_risk,
    ROUND(AVG(price), 2)                    AS avg_order_value,
    ROUND(AVG(actual_delivery_days), 1)     AS avg_days_late_orders
FROM fact_shipments
WHERE is_on_time = 0 AND is_delivered = 1;

-- Q7: Bottom 20 sellers by OTIF performance
SELECT
    f.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(*)                                        AS total_orders,
    ROUND(AVG(f.actual_delivery_days), 2)           AS avg_delivery_days,
    ROUND(100.0 * SUM(f.is_on_time) / COUNT(*), 2) AS otif_pct
FROM fact_shipments f
JOIN sellers s ON f.seller_id = s.seller_id
WHERE f.is_delivered = 1
GROUP BY f.seller_id
HAVING COUNT(*) >= 10
ORDER BY otif_pct ASC
LIMIT 20;

-- Q8: Customer satisfaction vs delivery performance
SELECT
    CASE
        WHEN r.review_score >= 4 THEN 'Satisfied (4-5 stars)'
        WHEN r.review_score = 3  THEN 'Neutral (3 stars)'
        ELSE                          'Dissatisfied (1-2 stars)'
    END                                     AS satisfaction_level,
    COUNT(*)                                AS order_count,
    ROUND(AVG(f.actual_delivery_days), 2)   AS avg_delivery_days,
    ROUND(AVG(f.price), 2)                  AS avg_order_value
FROM fact_shipments f
JOIN reviews r ON f.order_id = r.order_id
WHERE f.is_delivered = 1
GROUP BY satisfaction_level
ORDER BY avg_delivery_days DESC;

-- Q9: Orders never delivered (stuck/lost shipments)
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (), 2) AS pct_of_undelivered
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY order_count DESC;

-- Q10: Weekly order volume with 4-week rolling average
SELECT
    STRFTIME('%Y-W%W', order_purchase_timestamp) AS week,
    COUNT(*)  AS weekly_orders,
    ROUND(AVG(COUNT(*)) OVER (ORDER BY STRFTIME('%Y-W%W', order_purchase_timestamp)
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW ), 0)  AS rolling_4week_avg
FROM orders
GROUP BY week
ORDER BY week;
     

-- Q11: Freight cost as % of order value by state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)              AS total_orders,
    ROUND(AVG(oi.freight_value), 2)         AS avg_freight_cost,
    ROUND(AVG(oi.price), 2)                 AS avg_order_value,
    ROUND(100.0 * AVG(oi.freight_value)
          / AVG(oi.price), 2)               AS freight_pct_of_order
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c   ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING COUNT(DISTINCT o.order_id) > 100
ORDER BY freight_pct_of_order DESC
LIMIT 10;


-- Q12: Product categories with most severe delays (CTE pattern)
WITH late_orders AS (
    SELECT order_id
    FROM fact_shipments
    WHERE actual_delivery_days > 20
    AND is_delivered = 1
),
category_delays AS (
    SELECT
        p.product_category_name     AS category,
        COUNT(*)                    AS late_count
    FROM order_items oi
    JOIN late_orders lo ON oi.order_id = lo.order_id
    JOIN products p    ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)
SELECT
    category,
    late_count,
    RANK() OVER (ORDER BY late_count DESC) AS delay_rank
FROM category_delays
ORDER BY late_count DESC
LIMIT 15;


-- Q13: Cumulative order volume growth (running total)
SELECT
    STRFTIME('%Y-%m', order_purchase_timestamp) AS month,
    COUNT(*)                                     AS monthly_orders,
    SUM(COUNT(*)) OVER (
        ORDER BY STRFTIME('%Y-%m', order_purchase_timestamp)
    )                                            AS cumulative_orders
FROM orders
GROUP BY month
ORDER BY month;


-- Q14: Month-over-month OTIF change using LAG()
WITH monthly_otif AS (
    SELECT
        STRFTIME('%Y-%m', order_purchase_timestamp) AS month,
        ROUND(100.0 * SUM(is_on_time) / COUNT(*), 2) AS otif_pct
    FROM fact_shipments
    WHERE is_delivered = 1
    GROUP BY month
)
SELECT
    month,
    otif_pct,
    LAG(otif_pct) OVER (ORDER BY month)      AS prev_month_otif,
    ROUND(otif_pct -
        LAG(otif_pct) OVER (ORDER BY month),
    2)                                        AS mom_change
FROM monthly_otif
ORDER BY month;


-- Q15: State delivery performance ranking with tier classification
WITH state_performance AS (
    SELECT
        c.customer_state,
        COUNT(*)                                        AS total_orders,
        ROUND(100.0 * SUM(f.is_on_time) / COUNT(*), 2) AS otif_pct,
        ROUND(AVG(f.actual_delivery_days), 2)           AS avg_delivery_days
    FROM fact_shipments f
    JOIN customers c ON f.customer_id = c.customer_id
    WHERE f.is_delivered = 1
    GROUP BY c.customer_state
    HAVING COUNT(*) >= 50
)
SELECT
    customer_state,
    total_orders,
    otif_pct,
    avg_delivery_days,
    RANK()  OVER (ORDER BY otif_pct DESC)   AS performance_rank,
    NTILE(3) OVER (ORDER BY otif_pct DESC)  AS performance_tier
FROM state_performance
ORDER BY performance_rank;





