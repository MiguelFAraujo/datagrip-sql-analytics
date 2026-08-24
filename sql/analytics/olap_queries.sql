-- OLAP Analytics Queries for ClickHouse
-- Daily revenue by category
SELECT
    order_date,
    category_id,
    count() as orders,
    sum(total_price) as revenue,
    uniq(customer_id) as customers
FROM analytics.orders_fact o
JOIN analytics.products_dim p ON o.product_id = p.product_id
WHERE order_date >= today() - 30
GROUP BY order_date, category_id
ORDER BY order_date DESC, revenue DESC;

-- Customer lifetime value
SELECT
    customer_id,
    count(DISTINCT order_id) as total_orders,
    sum(total_price) as lifetime_value,
    min(order_date) as first_order,
    max(order_date) as last_order
FROM analytics.orders_fact
GROUP BY customer_id
HAVING total_orders > 1
ORDER BY lifetime_value DESC
LIMIT 100;

-- Product performance
SELECT
    p.sku,
    p.name,
    p.category_id,
    count(DISTINCT o.order_id) as orders,
    sum(o.quantity) as units_sold,
    sum(o.total_price) as revenue,
    avg(o.unit_price) as avg_price
FROM analytics.orders_fact o
JOIN analytics.products_dim p ON o.product_id = p.product_id
WHERE o.order_date >= today() - 90
GROUP BY p.sku, p.name, p.category_id
ORDER BY revenue DESC;
