--SCRIPT 05: PRODUCT-LEVEL FUNNEL (แยกตาม Product / Category)

--5.1 Top 10 สินค้าที่ถูก page_view มากที่สุด**
SELECT
   p.product_id,
   p.name,
   COUNT(*) as view_session
FROM events e
LEFT JOIN products p on p.product_id = e.product_id
WHERE e.event_type = 'page_view'
GROUP BY p.product_id,p.name
ORDER BY view_session DESC


--5.2 Top 10 สินค้าที่ถูก add_to_cart มากที่สุด**
SELECT
   p.product_id,
   p.name,
   COUNT(*) as cart_session
FROM events e
LEFT JOIN products p on p.product_id = e.product_id
WHERE e.event_type = 'add_to_cart'
GROUP BY p.product_id,p.name
ORDER BY cart_session DESC



--5.3 View-to-Cart rate ของแต่ละสินค้าเป็นยังไง? สินค้าไหน rate ต่ำสุด?**
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



--5.4 Cart-to-Purchase rate ของแต่ละสินค้าเป็นยังไง? สินค้าไหนที่คนหยิบแล้วไม่ซื้อบ่อย?**
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


--5.5 Category ไหนมี overall view-to-purchase rate ต่ำสุด?**
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











