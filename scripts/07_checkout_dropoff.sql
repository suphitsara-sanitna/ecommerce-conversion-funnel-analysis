/*
================================================================================
Script 07: Checkout Drop-off Analysis
================================================================================
Purpose:
    - To measure overall checkout abandonment rate
    - To identify which devices and traffic sources have the most checkout drop-off

Tables Used:
    - events
    - sessions

SQL Functions Used:
    - Aggregate Functions: COUNT(), ROUND()
    - Subqueries
    - CASE WHEN
================================================================================
*/

--7.1 What is the overall checkout abandonment rate?
SELECT 
   COUNT(DISTINCT session_id) as checkout_abandon,
   (SELECT COUNT(DISTINCT CASE WHEN event_type = 'checkout' THEN session_id END) FROM events) as checkout_sessions,
   ROUND(100.0* COUNT(DISTINCT session_id)/
   (SELECT COUNT(DISTINCT CASE WHEN event_type = 'checkout' THEN session_id END) FROM events),2) as checkout_abandon_rate
FROM events
WHERE event_type = 'checkout'
AND session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )
    
--7.2 Which device has the most checkout abandonment sessions?
SELECT 
   s.device as device,
   COUNT(DISTINCT e.session_id) as check_out_abandon_sessions
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
WHERE e.event_type = 'checkout'
AND e.session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )
GROUP BY device
ORDER BY sessions DESC

--7.3 Which traffic source has the most checkout abandonment sessions?
SELECT 
   s.source as source,
   COUNT(DISTINCT e.session_id) as check_out_abandon_sessions
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
WHERE e.event_type = 'checkout'
AND e.session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )
GROUP BY source
ORDER BY sessions DESC
