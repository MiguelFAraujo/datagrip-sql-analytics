-- ETL Pipeline SQL for n8n workflows
-- Extract from MariaDB (source) -> Transform -> Load to ClickHouse (analytics)

-- 1. Extract customers (incremental)
SELECT * FROM customers
WHERE updated_at > '{{ $json.last_sync }}'
ORDER BY updated_at;

-- 2. Extract products (incremental)
SELECT * FROM products
WHERE updated_at > '{{ $json.last_sync }}'
ORDER BY updated_at;

-- 3. Extract orders (incremental)
SELECT * FROM orders
WHERE updated_at > '{{ $json.last_sync }}'
ORDER BY updated_at;

-- 4. Extract order_items (incremental)
SELECT oi.* FROM order_items oi
JOIN orders o ON oi.order_id = o.id
WHERE o.updated_at > '{{ $json.last_sync }}';

-- Transform & Load to ClickHouse (run in ClickHouse)
-- Upsert customers
INSERT INTO analytics.customers_dim (customer_id, email, name, created_date)
SELECT id, email, name, DATE(created_at)
FROM mysql('mariadb:3306', 'analytics', 'customers', 'lab', 'labpass')
WHERE updated_at > '{{ $json.last_sync }}'
ON DUPLICATE KEY UPDATE email=values(email), name=values(name);

-- Upsert products
INSERT INTO analytics.products_dim (product_id, sku, name, category_id, price)
SELECT id, sku, name, category_id, price
FROM mysql('mariadb:3306', 'analytics', 'products', 'lab', 'labpass')
WHERE updated_at > '{{ $json.last_sync }}'
ON DUPLICATE KEY UPDATE sku=values(sku), name=values(name), price=values(price);

-- Insert orders fact
INSERT INTO analytics.orders_fact (order_id, customer_id, product_id, quantity, unit_price, total_price, order_date, order_datetime, status)
SELECT
    oi.id,
    o.customer_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price,
    DATE(o.created_at),
    o.created_at,
    o.status
FROM mysql('mariadb:3306', 'analytics', 'order_items', 'lab', 'labpass') oi
JOIN mysql('mariadb:3306', 'analytics', 'orders', 'lab', 'labpass') o ON oi.order_id = o.id
WHERE o.updated_at > '{{ $json.last_sync }}';
