--SCRIPT 04: FUNNEL BY COUNTRY (แยกตามประเทศ)

--4.1. Top 10 ประเทศที่มี session มากสุด มี funnel conversion rate เป็นยังไงในแต่ละ step?**
WITH country_session as (
SELECT 
    s.country,
    e.event_type,
    CASE event_type
         WHEN 'page_view' THEN 1
         WHEN 'add_to_cart' THEN 2
         WHEN 'checkout' THEN 3
         WHEN 'purchase' THEN 4
      END as step_order,
      COUNT( DISTINCT e.session_id) as sessions
FROM sessions s
LEFT JOIN events e on e.session_id = s.session_id
WHERE s.country IN (
    SELECT country FROM sessions
    GROUP BY country
    ORDER BY COUNT(*) DESC
    LIMIT 10
)
GROUP BY s.country, e.event_type
ORDER BY s.country, step_order
)
SELECT 
 *,
 ROUND(100.0* sessions/ LAG(sessions) OVER( PARTITION BY country ORDER BY step_order),2) as funnel_conversion_rate
FROM country_session



--4.2. ประเทศไหน drop-off ที่ checkout สูงสุด?** 
SELECT 
   s.country,
   COUNT(DISTINCT s.session_id) as sessions,
   COUNT(DISTINCT CASE WHEN e.event_type = 'checkout' THEN s.session_id END) as checkout_session,
   COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END) as purchase_session,
   ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END)/
                   COUNT(DISTINCT CASE WHEN e.event_type = 'checkout' THEN s.session_id END),2) as conversion_rate,
    ROUND(100-(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END)/
                   COUNT(DISTINCT CASE WHEN e.event_type = 'checkout' THEN s.session_id END)),2) as drop_off_rate
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
GROUP BY s.country
ORDER BY drop_off_rate DESC


--4.3. ประเทศไหนมี overall conversion rate ต่ำสุดทั้งที่มี session เยอะ?**
SELECT 
   s.country,
   COUNT(DISTINCT s.session_id) as sessions,
   COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END) as purchase_session,
   ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END)/
   COUNT(DISTINCT s.session_id),2) as conversion_rate,
   100- ROUND(100.0 * COUNT(DISTINCT CASE WHEN e.event_type = 'purchase' THEN s.session_id END)/
   COUNT(DISTINCT s.session_id),2) as drop_off_rate
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
GROUP BY s.country
ORDER BY conversion_rate DESC





