--03: FUNNEL BY TRAFFIC SOURCE (แยกตาม Source)

--3.1 แต่ละ source (organic/paid/email/social/direct/referral) มี session กี่ session และสัดส่วนเท่าไร?**
SELECT 
   source,
   COUNT(DISTINCT session_id) as sessions,
   (SELECT COUNT(DISTINCT session_id) FROM sessions) as total_sessions,
   ROUND(100.0*COUNT(DISTINCT session_id)/ (SELECT COUNT(DISTINCT session_id) FROM sessions),2) as session_share
FROM sessions
GROUP BY source


--3.2 Conversion rate ของแต่ละ step แยกตาม source เป็นยังไง?**, 3.4 Source ไหน drop-off สูงสุดในแต่ละ step?**
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


--3.3 Overall conversion rate (Session → Purchase) แยกตาม source ต่างกันไหม?**, 
--3.5 Source ไหนมี session-to-purchase rate ดีที่สุด? (quality traffic ranking)**
SELECT
   *,
  row_number() OVER(ORDER BY conversion_rate DESC)
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





