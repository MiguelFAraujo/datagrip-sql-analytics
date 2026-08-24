-- ClickHouse schema for OLAP Analytics
CREATE DATABASE IF NOT EXISTS analytics;

-- Fact table for orders (optimized for OLAP)
CREATE TABLE IF NOT EXISTS analytics.orders_fact
(
    order_id UInt64,
    customer_id UInt64,
    product_id UInt64,
    quantity UInt32,
    unit_price Decimal(10,2),
    total_price Decimal(12,2),
    order_date Date,
    order_datetime DateTime,
    status LowCardinality(String)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(order_date)
ORDER BY (customer_id, order_date)
TTL order_date + INTERVAL 2 YEAR
SETTINGS index_granularity = 8192;

-- Dimension tables
CREATE TABLE IF NOT EXISTS analytics.customers_dim
(
    customer_id UInt64,
    email String,
    name String,
    created_date Date
)
ENGINE = MergeTree()
ORDER BY customer_id;

CREATE TABLE IF NOT EXISTS analytics.products_dim
(
    product_id UInt64,
    sku String,
    name String,
    category_id UInt32,
    price Decimal(10,2)
)
ENGINE = MergeTree()
ORDER BY product_id;

-- Materialized view for daily sales
CREATE MATERIALIZED VIEW IF NOT EXISTS analytics.daily_sales_mv
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(order_date)
ORDER BY (order_date, category_id)
AS SELECT
    order_date,
    p.category_id,
    count() as order_count,
    sum(total_price) as revenue,
    uniq(customer_id) as unique_customers
FROM analytics.orders_fact o
JOIN analytics.products_dim p ON o.product_id = p.product_id
GROUP BY order_date, p.category_id;
