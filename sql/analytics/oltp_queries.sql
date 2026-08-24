-- OLTP Analytics Queries for MariaDB/PostgreSQL
-- Daily sales summary
SELECT
    DATE(o.created_at) as order_date,
    COUNT(DISTINCT o.id) as orders,
    SUM(o.total) as revenue,
    COUNT(DISTINCT o.customer_id) as customers
FROM orders o
WHERE o.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
  AND o.status IN ('paid','shipped','delivered')
GROUP BY DATE(o.created_at)
ORDER BY order_date DESC;

-- Top customers by revenue
SELECT
    c.id,
    c.email,
    c.name,
    COUNT(o.id) as total_orders,
    SUM(o.total) as lifetime_value
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.status IN ('paid','shipped','delivered')
GROUP BY c.id, c.email, c.name
HAVING total_orders > 1
ORDER BY lifetime_value DESC
LIMIT 50;

-- Product sales with category
SELECT
    p.sku,
    p.name,
    p.category_id,
    COUNT(oi.id) as order_count,
    SUM(oi.quantity) as units_sold,
    SUM(oi.quantity * oi.unit_price) as revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.created_at >= DATE_SUB(NOW(), INTERVAL 90 DAY)
  AND o.status IN ('paid','shipped','delivered')
GROUP BY p.sku, p.name, p.category_id
ORDER BY revenue DESC;

-- Inventory alerts (low stock)
SELECT
    p.id,
    p.sku,
    p.name,
    p.stock,
    p.category_id
FROM products p
WHERE p.stock < 10
ORDER BY p.stock ASC;
