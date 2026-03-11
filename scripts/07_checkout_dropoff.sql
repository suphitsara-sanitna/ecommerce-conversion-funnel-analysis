--07: CHECKOUT DROP-OFF ANALYSIS (วิเคราะห์การหยุดที่ Checkout)

--7.1 Checkout abandonment rate โดยรวมเท่าไร? (session ที่มี checkout แต่ไม่มี purchase)**
SELECT 
   COUNT(DISTINCT session_id) as cart_abandon,
   (SELECT COUNT(DISTINCT CASE WHEN event_type = 'checkout' THEN session_id END) FROM events) as cart_sessions,
   ROUND(100.0* COUNT(DISTINCT session_id)/
   (SELECT COUNT(DISTINCT CASE WHEN event_type = 'checkout' THEN session_id END) FROM events),2) as cart_abandon_rate
FROM events
WHERE event_type = 'checkout'
AND session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )


--7.2 Session ที่ไปถึง checkout แต่ไม่ซื้อ มาจาก device ไหน?**
SELECT 
   s.device as device,
   COUNT(DISTINCT e.session_id) as sessions
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
WHERE e.event_type = 'checkout'
AND e.session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )
GROUP BY device
ORDER BY sessions DESC



--7.3 Session ที่ไปถึง checkout แต่ไม่ซื้อ มาจาก source ไหน?**
SELECT 
   s.source as source,
   COUNT(DISTINCT e.session_id) as sessions
FROM events e
LEFT JOIN sessions s on s.session_id = e.session_id
WHERE e.event_type = 'checkout'
AND e.session_id NOT IN (
    SELECT DISTINCT session_id 
    FROM events 
    WHERE event_type = 'purchase' )
GROUP BY source
ORDER BY sessions DESC





