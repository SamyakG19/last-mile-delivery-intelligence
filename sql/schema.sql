-- ============================================
-- Last-Mile Delivery Intelligence Platform
-- Star Schema — View Definitions
-- Author: Samyak G19
-- Database: supply_chain.db
-- ============================================

-- ============================================
-- Last-Mile Delivery Intelligence Platform
-- Star Schema — View Definitions
-- Author: Samyak G19
-- ============================================

-- ── VIEW 1: Central Fact Table ───────────────
-- One row per shipment with all calculated KPIs
-- SLA definition: 12 days from purchase to delivery
DROP VIEW IF EXISTS fact_shipments;

CREATE VIEW fact_shipments AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_estimated_delivery_date,
    o.order_delivered_customer_date,
    oi.freight_value,
    oi.price,
    oi.product_id,
    oi.seller_id,
    -- Actual days from purchase to delivery
    ROUND(
        JULIANDAY(o.order_delivered_customer_date) -
        JULIANDAY(o.order_purchase_timestamp),
    1) AS actual_delivery_days,
    -- Delay vs estimated date (negative = early)
    ROUND(
        JULIANDAY(o.order_delivered_customer_date) -
        JULIANDAY(o.order_estimated_delivery_date),
    1) AS delay_vs_estimate,
    -- PRIMARY OTIF FLAG: SLA = 12 days from purchase
    CASE
        WHEN JULIANDAY(o.order_delivered_customer_date) -
             JULIANDAY(o.order_purchase_timestamp) <= 12
        THEN 1 ELSE 0
    END AS is_on_time,
    -- Delivered flag
    CASE
        WHEN o.order_status = 'delivered' THEN 1 ELSE 0
    END AS is_delivered
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id;

-- ── VIEW 2: Customer Zone Dimension ──────────
-- Unique customer locations for geographic analysis
CREATE VIEW IF NOT EXISTS dim_zone AS
SELECT DISTINCT
    customer_id,
    customer_city,
    customer_state
FROM customers;

-- ── VIEW 3: Seller Dimension ──────────────────
-- Unique seller profiles for performance ranking
CREATE VIEW IF NOT EXISTS dim_seller AS
SELECT DISTINCT
    seller_id,
    seller_city,
    seller_state
FROM sellers;