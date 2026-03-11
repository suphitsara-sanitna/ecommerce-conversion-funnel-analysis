/*
================================================================================
Script 02: Funnel by Device
================================================================================
Purpose:
    - To compare session distribution across device types
    - To measure conversion and drop-off rates at each funnel step by device
    - To identify which device has the highest drop-off and lowest overall conversion
    - To compare Average Order Value (AOV) across devices

Tables Used:
    - events
    - sessions

SQL Functions Used:
    - Aggregate Functions: COUNT(), SUM(), ROUND()
    - Window Functions: LAG() OVER()
    - CTEs
    - Subqueries
    - CASE WHEN
================================================================================
*/

--2.1 How many sessions does each device have and what is the share?
SELECT 
   device,
   COUNT(DISTINCT session_id) as sessions,
   (SELECT COUNT(DISTINCT session_id) FROM sessions) as total_sessions,
   ROUND(100.0*COUNT(DISTINCT session_id)/ (SELECT COUNT(DISTINCT session_id) FROM sessions),2) as session_share
FROM sessions
GROUP BY device
    
--2.2 What is the conversion rate and drop-off rate at each funnel step by device?
WITH event_session as (
SELECT 
   session_id,
   event_type,
   COUNT( DISTINCT session_id) as session,
   CASE event_type
         WHEN 'page_view' THEN 1
         WHEN 'add_to_cart' THEN 2
         WHEN 'checkout' THEN 3
         WHEN 'purchase' THEN 4
      END as step_order
FROM events
GROUP BY session_id,event_type
ORDER BY session_id,step_order
)
, device_session as (
SELECT 
   s.device as device,
   es.event_type as event_type,
   es.step_order as step_order,
   COUNT(es.session) as event_type_per_device
FROM sessions s
LEFT JOIN event_session es on es.session_id = s.session_id
GROUP BY s.device,es.event_type
ORDER BY s.device,es.step_order
)
SELECT 
 *,
 ROUND(100.0* event_type_per_device/ 
 LAG(event_type_per_device) OVER( PARTITION BY device ORDER BY step_order),2) as conversion_rate,
 ROUND(100-(100.0* event_type_per_device/ 
 LAG(event_type_per_device) OVER( PARTITION BY device ORDER BY step_order)),2) as drop_off_rate
FROM  device_session
    
--2.3 Does the overall conversion rate (Session → Purchase) differ by device?
SELECT 
   s.device,
   COUNT(DISTINCT e.session_id) as sessions,
   COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END) as purchase_session,
   ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END)/
   COUNT(DISTINCT e.session_id),2) as conversion_rate,
   100- ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END)/
   COUNT(DISTINCT e.session_id),2) as drop_off_rate
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
GROUP BY s.device
ORDER BY conversion_rate DESC

--2.4 What is the AOV for each device among sessions that completed a purchase?
SELECT 
    s.device,
   COUNT(e.session_id) as total_orders,
   ROUND(SUM(e.amount_usd),2) as revenue,
   ROUND(SUM(e.amount_usd)/COUNT(e.session_id),2) as AOV
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
WHERE event_type = 'purchase'
GROUP BY s.device
