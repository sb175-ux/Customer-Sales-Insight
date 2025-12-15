-- Silver: cleaned order_payments with DQ checks
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.order_payments` AS
SELECT
  NULLIF(TRIM(order_id), '') AS order_id,
  SAFE_CAST(payment_sequential AS INT64) AS payment_sequential,
  LOWER(NULLIF(TRIM(payment_type), '')) AS payment_type,
  SAFE_CAST(payment_installments AS INT64) AS payment_installments,
  SAFE_CAST(payment_value AS FLOAT64) AS payment_value,
  -- DQ checks
  (IF(order_id IS NULL OR TRIM(order_id) = '', 1, 0)
   + IF(payment_sequential IS NULL, 1, 0)
   + IF(payment_value IS NULL, 1, 0)) AS _dq_null_count,
  CASE WHEN SAFE_CAST(payment_value AS FLOAT64) IS NULL THEN 'invalid_payment_value' ELSE 'ok' END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.order_payments`
QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id, payment_sequential ORDER BY order_id, payment_sequential) = 1;
