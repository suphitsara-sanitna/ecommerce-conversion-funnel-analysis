--/*
================================================================================
Script 08: Funnel Opportunities & Recommendations
================================================================================
Purpose:
    - To identify the biggest drop-off point in the funnel
    - To find the lowest-converting device and traffic source combinations
    - To estimate revenue recovery potential from improving checkout drop-off
    - To estimate additional orders from reducing cart abandonment

Tables Used:
    - events
    - sessions
    - orders

SQL Functions Used:
    - Aggregate Functions: COUNT(), SUM(), ROUND()
    - Window Functions: LAG() OVER()
    - CTEs
    - Subqueries
    - CASE WHEN
================================================================================
*/

--8.1 Which funnel step has the highest drop-off rate? (biggest leak in the funnel)
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

--8.2 Which device and traffic source combination has the lowest conversion rate?
SELECT 
   s.device,
   s.source,
   COUNT(DISTINCT e.session_id) as sessions,
   COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END) as purchase_session,
   ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END)/
   COUNT(DISTINCT e.session_id),2) as conversion_rate,
   100- ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN e.session_id END)/
   COUNT(DISTINCT e.session_id),2) as drop_off_rate
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
GROUP BY s.device, s.source
ORDER BY conversion_rate 

--8.3 ถ้าแก้ checkout drop-off ได้ 50% จะ recover revenue ได้เท่าไร? (revenue impact estimation)**
SELECT 
   COUNT(DISTINCT session_id) as checkout_drop_off_sessions,
   (SELECT SUM(total_usd) FROM orders) as total_revenue_from_order,
   (SELECT COUNT(order_id) FROM orders) as total_orders_sold,
   (SELECT (SUM(total_usd))/COUNT(order_id) FROM orders) as AOV,
   ROUND(COUNT(DISTINCT session_id)/2*(SELECT (SUM(total_usd))/COUNT(order_id) FROM orders),2) as recover_revenue ,
   ROUND(100.0*(COUNT(DISTINCT session_id)/2*(SELECT (SUM(total_usd))/COUNT(order_id) FROM orders))/
   (SELECT SUM(total_usd) FROM orders),2) as recover_revenue_percent 
FROM events
WHERE event_type = 'checkout'
AND session_id NOT IN 
 (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' 
  )

--8.4 If cart abandonment is reduced by 10%, how many additional orders could be generated?
WITH cart_abandon as (
SELECT
    DISTINCT session_id,
    product_id
FROM events
WHERE event_type = 'add_to_cart'
AND session_id NOT IN 
 (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' 
  )
)
SELECT
   COUNT(DISTINCT session_id) as cart_abandon_sessions,
   (SELECT ROUND(SUM(total_usd),2) FROM orders) as total_revenue_from_order,
   (SELECT COUNT(order_id) FROM orders) as total_orders_sold,
   (SELECT ROUND((SUM(total_usd))/COUNT(order_id),2) FROM orders) as AOV,
   ROUND(0.1 * COUNT(DISTINCT session_id), 0) as additional_orders,
   ROUND(0.1 *COUNT(DISTINCT session_id)*(SELECT (SUM(total_usd))/COUNT(order_id) FROM orders),2) as recover_revenue ,
   ROUND(100.0*((COUNT(DISTINCT session_id)*0.1)*(SELECT (SUM(total_usd))/COUNT(order_id) FROM orders))/
   (SELECT SUM(total_usd) FROM orders),2) as recover_revenue_percent 
FROM cart_abandon
