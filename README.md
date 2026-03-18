# E-Commerce Conversion Funnel Analysis

## Executive Summary

This project analyzes the e-commerce conversion funnel to identify where users drop off and estimate the revenue opportunity of improving conversion. Using SQL in DB Browser for SQLite and Power BI, I queried 760,958 event records across 120,000 sessions and created a dashboard to track user behavior through the funnel. After identifying that the largest revenue opportunities are in improving checkout drop-off and cart abandonment, I recommend a few adjustments that will lead to higher conversion:

1. Reminder emails and texts
2. Progress bar and step indicator at checkout
3. Simplify the checkout experience

---

## Dataset

This project uses the same dataset as the [E-Commerce EDA Project](https://github.com/suphitsara-sanitna/ecommerce-eda) — 200,000+ records across 7 tables covering transactions from an e-commerce business. Please refer to that repository to download the dataset.

---

## Business Problem

Revenue for this e-commerce business is entirely dependent on completed purchases. The overall conversion rate from session to purchase sits at only 27.98%, meaning more than 70% of users who visit the site never complete a purchase. The key question is: where are users dropping out of the funnel, and what changes can be made to encourage them to complete their purchase?

<img width="1253" height="699" alt="Screenshot 2569-03-18 at 12 07 29" src="https://github.com/user-attachments/assets/8ab9ed88-258d-479d-9c57-6c4dc9316ccf" />


## Methodology

1. SQL queries to extract and analyze event-level data tracking user behavior across the funnel
2. Segmentation analysis by device, traffic source, and country to identify whether drop-off patterns differ across user groups
3. A dashboard in Power BI to visualize funnel performance and revenue recovery opportunities

---

## Skills

**SQL:** CTEs, Joins, CASE WHEN, Aggregate Functions, Window Functions, Subqueries, Date Functions

**Power BI:** Data visualization, bar chart, funnel chart, line chart

---

## Results & Business Recommendation

This funnel analysis identified that the biggest drop-off occurs at the Add to Cart → Checkout step, where the step-to-step conversion rate drops to only 55.09% — the lowest across all funnel stages. This means nearly half of users who add items to their cart never reach checkout. The overall cart abandonment rate sits at 41.35%.

After segmenting the funnel by device, traffic source, and country, the conversion rate at the checkout step remained consistently low across all segments at approximately 55%. This confirms that the issue is not specific to any particular device or channel, but rather a systemic problem with the checkout experience itself.

If checkout drop-off is reduced by 10%, an estimated $151,589 in additional revenue could be recovered. If cart abandonment is reduced by 10%, an estimated $641,441 in additional revenue could be recovered. While cart abandonment shows a higher recovery potential, this figure assumes all recovered sessions would convert at the same AOV, which may overestimate the actual impact. Checkout drop-off is the more reliable opportunity as these users have already demonstrated strong purchase intent by reaching the final step.

Because the biggest revenue opportunity comes from improving the checkout conversion rate, I recommend the following adjustments:

1. Send reminder emails and texts to users who abandon cart or checkout, targeting those who have opted in to marketing communications
2. Add a progress bar and step indicator throughout the checkout process to encourage completion
3. Investigate and simplify the checkout experience to reduce friction across all devices and traffic sources

To better identify the root cause of checkout drop-off, it is recommended to collect additional data such as payment method, payment error logs, shipping cost displayed at checkout, and time spent on each checkout step. This data would allow more targeted optimization beyond what the current dataset can support.

---

## Next Steps

1. Collect additional data at the checkout stage such as payment method, error logs, and shipping cost to better identify the root cause of drop-off
2. Run A/B test on checkout UX to identify which checkout experience leads to higher conversion
3. Build a deeper analysis on cart abandonment behavior once additional data is available
