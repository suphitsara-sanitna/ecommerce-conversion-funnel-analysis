/*
================================================================================
Script 06: Cart Abandonment Analysis
================================================================================
Purpose:
    - To measure overall cart abandonment rate
    - To compare average cart size between abandoned and purchased sessions
    - To identify which devices and traffic sources have the most cart abandonment
    - To find the most frequently abandoned products

Tables Used:
    - events
    - sessions
    - products

SQL Functions Used:
    - Aggregate Functions: COUNT(), SUM(), ROUND()
    - CTEs
    - Subqueries
    - CASE WHEN
    - UNION ALL
================================================================================
*/

--6.1 What is the overall cart abandonment rate?
SELECT 
   COUNT(DISTINCT session_id) as cart_abandon,
   (SELECT COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN session_id END) FROM events) as cart_sessions,
   ROUND(100.0* COUNT(DISTINCT session_id)/
   (SELECT COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN session_id END) FROM events),2) as cart_abandon_rate
FROM events
WHERE event_type = 'add_to_cart'
AND session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )
   
--6.2 How does average cart size compare between abandoned and purchased sessions?
WITH  sessions_abandon_cart_size as (
SELECT 
   session_id,
   event_type,
   COUNT(DISTINCT product_id) total_product
FROM events
WHERE event_type = 'add_to_cart' AND session_id NOT IN 
  (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' 
    )
GROUP BY session_id
),
purchase_cart_size as(
   SELECT 
   session_id,
   event_type,
   COUNT(DISTINCT product_id) total_product
FROM events
WHERE event_type = 'add_to_cart' AND session_id IN 
  (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' 
    )
GROUP BY session_id
)
SELECT
   'abandon cart' as section,
   SUM(total_product) as total_product,
   COUNT(*) as total_sessions,
   ROUND(1.0 *SUM(total_product)/COUNT(*),2) as avg_cart_size
FROM sessions_abandon_cart_size
UNION ALL 
SELECT
   'purchase' ,
   SUM(total_product) as total_product,
   COUNT(*) as total_sessions,
   ROUND(1.0 *SUM(total_product)/COUNT(*),2) as avg_cart_size
FROM purchase_cart_size
   
--6.3 Which device has the most cart abandonment sessions?
SELECT 
   s.device as device,
   COUNT(DISTINCT e.session_id) as sessions
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
WHERE e.event_type = 'add_to_cart'
AND e.session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )
GROUP BY device
ORDER BY sessions DESC
   
--6.4 Which traffic source has the most cart abandonment sessions?
SELECT 
   s.source as source,
   COUNT(DISTINCT e.session_id) as sessions
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
WHERE e.event_type = 'add_to_cart'
AND e.session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )
GROUP BY source
ORDER BY sessions DESC

--6.5 Which products are most frequently added to cart but never purchased?
SELECT 
   e.product_id,
   p.name,
   COUNT(*) as total_product
FROM events e
LEFT JOIN products p on p.product_id = e.product_id
WHERE e.event_type = 'add_to_cart' AND e.session_id NOT IN 
  (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' 
    )
GROUP BY e.product_id
ORDER BY total_product DESC
