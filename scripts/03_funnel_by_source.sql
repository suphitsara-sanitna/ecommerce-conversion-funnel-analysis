/*
================================================================================
Script 03: Funnel by Traffic Source
================================================================================
Purpose:
    - To compare session distribution across traffic sources
    - To measure conversion and drop-off rates at each funnel step by source
    - To identify which source has the highest drop-off
    - To rank traffic sources by session-to-purchase quality

Tables Used:
    - events
    - sessions

SQL Functions Used:
    - Aggregate Functions: COUNT(), ROUND()
    - Window Functions: LAG() OVER(), ROW_NUMBER() OVER()
    - CTEs
    - Subqueries
    - CASE WHEN
================================================================================
*/

--3.1 How many sessions does each traffic source have and what is the share?
SELECT 
   source,
   COUNT(DISTINCT session_id) as sessions,
   (SELECT COUNT(DISTINCT session_id) FROM sessions) as total_sessions,
   ROUND(100.0*COUNT(DISTINCT session_id)/ (SELECT COUNT(DISTINCT session_id) FROM sessions),2) as session_share
FROM sessions
GROUP BY source
    
--3.2 What is the conversion rate and drop-off rate at each funnel step by traffic source?
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
, source_session as (
SELECT 
   s.source as source,
   es.event_type as event_type,
   es.step_order as step_order,
   COUNT(es.session) as event_type_per_source
FROM sessions s
LEFT JOIN event_session es on es.session_id = s.session_id
GROUP BY s.source,es.event_type
ORDER BY s.source,es.step_order
)
SELECT 
 *,
 ROUND(100.0* event_type_per_source/ 
 LAG(event_type_per_source) OVER( PARTITION BY source ORDER BY step_order),2) as conversion_rate,
 ROUND(100-(100.0* event_type_per_source/ 
 LAG(event_type_per_source) OVER( PARTITION BY source ORDER BY step_order)),2) as drop_off_rate
FROM  source_session
    
-- 3.3 Does the overall conversion rate differ by source and which source has the best quality traffic?
SELECT
   *,
  row_number() OVER(ORDER BY conversion_rate DESC) as ranking
FROM
(SELECT 
   s.source,
   COUNT(DISTINCT s.session_id) as sessions,
   COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END) as purchase_session,
   ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END)/
   COUNT(DISTINCT s.session_id),2) as conversion_rate,
   100- ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END)/
   COUNT(DISTINCT s.session_id),2) as drop_off_rate
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
GROUP BY s.source
ORDER BY conversion_rate DESC) conversion_rate
