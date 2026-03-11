--/*
================================================================================
Script 05: Product-Level Funnel
================================================================================
Purpose:
    - To identify top products by page views and add-to-cart events
    - To measure view-to-cart rate by product
    - To measure cart-to-purchase rate by product
    - To compare view-to-purchase rate across product categories

Tables Used:
    - events
    - products
    - order_items

SQL Functions Used:
    - Aggregate Functions: COUNT(), SUM(), ROUND()
    - CTEs
    - CASE WHEN
================================================================================
*/

--5.1 What are the top 10 most viewed products?
SELECT
   p.product_id,
   p.name,
   COUNT(*) as view_session
FROM events e
LEFT JOIN products p on p.product_id = e.product_id
WHERE e.event_type = 'page_view'
GROUP BY p.product_id,p.name
ORDER BY view_session DESC

--5.2 What are the top 10 most added-to-cart products?
SELECT
   p.product_id,
   p.name,
   COUNT(*) as cart_session
FROM events e
LEFT JOIN products p on p.product_id = e.product_id
WHERE e.event_type = 'add_to_cart'
GROUP BY p.product_id,p.name
ORDER BY cart_session DESC

--5.3 What is the view-to-cart rate by product? Which products have the lowest rate?
SELECT 
   p.name, 
   COUNT(DISTINCT CASE WHEN e.event_type = 'page_view' THEN e.session_id END) as sessions, 
   COUNT(DISTINCT CASE WHEN e.event_type = 'add_to_cart' THEN e.session_id END) as cart_session, 
   100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'add_to_cart' THEN e.session_id END)/ 
   COUNT(DISTINCT CASE WHEN e.event_type = 'page_view' THEN e.session_id END) as rate 
FROM events e 
LEFT JOIN products p on p.product_id = e.product_id 
GROUP BY p.product_id 
ORDER BY rate DESC

--5.4 What is the cart-to-purchase rate by product? Which products are added to cart but rarely purchased?
WITH cart_event as (
SELECT
   e.product_id as product_id,
   p.name,
   e.event_type, 
   COUNT(*) as cart_sessions
FROM events e
LEFT JOIN products p on p.product_id = e.product_id 
WHERE e.event_type = 'add_to_cart' 
GROUP BY e.product_id,  p.name, e.event_type 
ORDER BY e.product_id
),
purchase_event as (
SELECT
   oi.product_id as productID,
   p.name,
   COUNT(*) as purchase_sessions
FROM order_items oi
LEFT JOIN products p on p.product_id = oi.product_id
GROUP BY oi.product_id, p.name
)
SELECT 
   pe.productID,
   pe.name,
   ce.cart_sessions,
   pe.purchase_sessions,
   ROUND(100.0* pe.purchase_sessions/ce.cart_sessions ,2) as cart_to_purchase_rate
FROM purchase_event pe
LEFT JOIN cart_event ce on ce.product_id = pe.productID
ORDER BY cart_to_purchase_rate DESC

-- 5.5 Which product category has the lowest overall view-to-purchase rate?
WITH view_event as (
SELECT
   e.product_id as product_id,
   p.name,
   p.category,
   e.event_type,
   COUNT(*) as view_sessions
FROM events e
LEFT JOIN products p on p.product_id = e.product_id
WHERE e.event_type = 'page_view'
GROUP BY  e.product_id, e.product_id
ORDER BY e.product_id
),
purchase_event as (
SELECT
   oi.product_id as productID,
   p.name,
   p.category as category,
   COUNT(*) as purchase_sessions
FROM order_items oi
LEFT JOIN products p on p.product_id = oi.product_id
GROUP BY oi.product_id
)
SELECT
   pe.category,
   SUM(ve.view_sessions) as total_views,
   SUM(pe.purchase_sessions) as total_purchases,
   ROUND(100.0* SUM(pe.purchase_sessions)/SUM(ve.view_sessions) ,2) as view_to_purchase_rate
FROM purchase_event pe
LEFT JOIN view_event ve on ve.product_id = pe.productID
GROUP BY pe.category
ORDER BY view_to_purchase_rate
