-- Silver: cleaned orders with DQ checks and keep latest by purchase timestamp
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.orders` AS
SELECT
  NULLIF(TRIM(order_id), '') AS order_id,
  NULLIF(TRIM(customer_id), '') AS customer_id,
  LOWER(NULLIF(TRIM(order_status), '')) AS order_status,
  COALESCE(SAFE_CAST(order_purchase_timestamp AS TIMESTAMP), NULL) AS order_purchase_timestamp,
  COALESCE(SAFE_CAST(order_approved_at AS TIMESTAMP), NULL) AS order_approved_at,
  COALESCE(SAFE_CAST(order_delivered_carrier_date AS TIMESTAMP), NULL) AS order_delivered_carrier_date,
  COALESCE(SAFE_CAST(order_delivered_customer_date AS TIMESTAMP), NULL) AS order_delivered_customer_date,
  COALESCE(SAFE_CAST(order_estimated_delivery_date AS TIMESTAMP), NULL) AS order_estimated_delivery_date,
  -- DQ checks
  (IF(order_id IS NULL OR TRIM(order_id) = '', 1, 0)
   + IF(customer_id IS NULL OR TRIM(customer_id) = '', 1, 0)
   + IF(order_purchase_timestamp IS NULL, 1, 0)) AS _dq_null_count,
  CASE WHEN SAFE_CAST(order_purchase_timestamp AS TIMESTAMP) IS NULL THEN 'invalid_purchase_ts' ELSE 'ok' END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.orders`
QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_purchase_timestamp DESC NULLS LAST) = 1;
