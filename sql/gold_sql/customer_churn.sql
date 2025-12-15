-- Gold: Customer churn snapshot
-- Computes last order date per customer and a churn flag using a 90-day window

CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_features.customer_churn` AS
WITH customer_last AS (
  SELECT
    NULLIF(TRIM(customer_id), '') AS customer_id,
    MAX(COALESCE(SAFE_CAST(order_purchase_timestamp AS TIMESTAMP), TIMESTAMP('1970-01-01'))) AS last_order_ts
  FROM `fourth-library-296421.customer_analytics_stage.orders`
  GROUP BY customer_id
),
snapshot AS (
  -- snapshot_date chosen as the max order date in the dataset
  SELECT MAX(last_order_ts) AS snapshot_ts FROM customer_last
)
SELECT
  cl.customer_id,
  DATE(cl.last_order_ts) AS last_order_date,
  s.snapshot_ts,
  DATE(s.snapshot_ts) AS snapshot_date,
  DATE_DIFF(DATE(s.snapshot_ts), DATE(cl.last_order_ts), DAY) AS days_since_last_order,
  -- churn: customer with no orders in the last 90 days relative to snapshot
  CASE WHEN DATE_DIFF(DATE(s.snapshot_ts), DATE(cl.last_order_ts), DAY) > 90 THEN TRUE ELSE FALSE END AS is_churned
FROM customer_last cl CROSS JOIN snapshot s
ORDER BY days_since_last_order DESC;