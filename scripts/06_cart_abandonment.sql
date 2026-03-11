-- 06: CART ABANDONMENT ANALYSIS (วิเคราะห์การทิ้งตะกร้า)

--6.1 Cart abandonment rate โดยรวมเท่าไร? (session ที่มี add_to_cart แต่ไม่มี purchase)**
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



--6.2 Session ที่ abandon cart มี cart_size เฉลี่ยเท่าไร เทียบกับ session ที่ซื้อสำเร็จ?**
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


--6.3 Session ที่ abandon cart มาจาก device ไหนมากสุด?**

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


--6.4 Session ที่ abandon cart มาจาก source ไหนมากสุด?**
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


--6.5 สินค้าไหนที่ถูก add_to_cart บ่อยที่สุดแต่ไม่ถูก purchase? (top abandoned products)**
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
