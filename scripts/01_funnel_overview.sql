--01: FUNNEL OVERVIEW (ภาพรวม Funnel)

--1.1 แต่ละ stage มี session กี่ session?**
SELECT 
   event_type,
   COUNT(DISTINCT session_id) as total_sessions,
   (SELECT COUNT(DISTINCT session_id) FROM events) as total_sessions,
   ROUND(100.0 * COUNT(DISTINCT session_id) / (SELECT COUNT(DISTINCT session_id) FROM events), 2) as percentage
FROM events
GROUP BY event_type

--1.2. Conversion rate ของแต่ละ step เท่าไร? (View→Cart, Cart→Checkout, Checkout→Purchase)**,
--1.4 Drop-off rate ของแต่ละ step เท่าไร? (กี่ % ที่หายไปในแต่ละ stage)**
SELECT 
   event_type,
   CASE event_type
         WHEN 'page_view' THEN 1
         WHEN 'add_to_cart' THEN 2
         WHEN 'checkout' THEN 3
         WHEN 'purchase' THEN 4
      END as step_order,
   COUNT(DISTINCT session_id) as sessions,
   LAG(COUNT(DISTINCT session_id)) OVER(ORDER BY (COUNT(DISTINCT session_id)) DESC) as previous_sesions,
   ROUND( 100.0 * COUNT(DISTINCT session_id) / 
    LAG(COUNT(DISTINCT session_id)) OVER(ORDER BY (COUNT(DISTINCT session_id)) DESC),2) as conversion_rate,
    ROUND( 100 - ( 100.0 * COUNT(DISTINCT session_id) / 
    LAG(COUNT(DISTINCT session_id)) OVER(ORDER BY (COUNT(DISTINCT session_id)) DESC)),2) as drop_off_rate,
   (SELECT COUNT(DISTINCT session_id) FROM events) as total_sessions,
   ROUND(100.0 * COUNT(DISTINCT session_id) / (SELECT COUNT(DISTINCT session_id) FROM events), 2) as pct_of_total
FROM events
GROUP BY event_type
ORDER BY step_order



--1.3 Overall conversion rate (Session → Purchase) เท่าไร?**
SELECT 
   COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN session_id END) as purchase_sessions,
   COUNT(DISTINCT session_id) as total_sessions,
   ROUND(100.0 * COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN session_id END) / 
   (COUNT(DISTINCT session_id)), 2) as overall_conversion_rate
FROM events


--1.5 Session ที่ซื้อสำเร็จใช้เวลาเฉลี่ยนานแค่ไหนจาก page_view ถึง purchase?**
WITH first_pageview as (
SELECT
   session_id,
   event_type,
   MIN(timestamp) as first_pageview_time
FROM events
WHERE event_type = 'page_view'
GROUP BY session_id
),
purchase_event as (
SELECT
   session_id,
   event_type,
   timestamp
FROM events
WHERE event_type = 'purchase'
GROUP BY session_id
)
 SELECT 
    count(pe.session_id) as completed_purchases,
    ROUND(AVG(1440.0 * (JULIANDAY(pe.timestamp) - JULIANDAY(fp.first_pageview_time))), 2) as avg_minutes_to_purchase,
	ROUND(MIN(1440.0 * (JULIANDAY(pe.timestamp) - JULIANDAY(fp.first_pageview_time))), 2) as min_minutes_to_purchase,
    ROUND(MAX(1440.0 * (JULIANDAY(pe.timestamp) - JULIANDAY(fp.first_pageview_time))), 2) as max_minutes_to_purchase
FROM purchase_event pe
LEFT JOIN first_pageview fp on fp.session_id = pe.session_id 



