-- Gold: Payment totals by payment_type and order date
-- Granularity: (payment_type, order_date)
-- Uses: customer_analytics_stage.order_payments (payment_value, payment_type) and customer_analytics_stage.orders (order_purchase_timestamp)

CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_features.payment_type_date` AS
WITH payments AS (
  SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    LOWER(NULLIF(TRIM(payment_type), '')) AS payment_type,
    SAFE_CAST(payment_value AS FLOAT64) AS payment_value,
    SAFE_CAST(payment_installments AS INT64) AS payment_installments
  FROM `fourth-library-296421.customer_analytics_stage.order_payments`
),
orders AS (
  SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    COALESCE(SAFE_CAST(order_purchase_timestamp AS TIMESTAMP), NULL) AS order_purchase_timestamp
  FROM `fourth-library-296421.customer_analytics_stage.orders`
),
joined AS (
  SELECT
    p.payment_type,
    DATE(o.order_purchase_timestamp) AS order_date,
    p.payment_value
  FROM payments p
  LEFT JOIN orders o
    ON p.order_id = o.order_id
  WHERE p.payment_type IS NOT NULL
    AND o.order_purchase_timestamp IS NOT NULL
)
SELECT
  payment_type,
  order_date,
  SUM(COALESCE(payment_value, 0.0)) AS total_payment_value,
  COUNT(1) AS payment_count,
  AVG(COALESCE(payment_value, 0.0)) AS avg_payment_value
FROM joined
GROUP BY payment_type, order_date
ORDER BY order_date, payment_type;