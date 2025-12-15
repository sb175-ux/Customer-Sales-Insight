-- Silver: cleaned order_items with DQ checks
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.order_items` AS
SELECT
  NULLIF(TRIM(order_id), '') AS order_id,
--   SAFE_CAST(order_item_id AS INT64) AS order_item_id,
  NULLIF(TRIM(product_id), '') AS product_id,
  NULLIF(TRIM(seller_id), '') AS seller_id,
  COALESCE(SAFE_CAST(shipping_limit_date AS TIMESTAMP), NULL) AS shipping_limit_date,
  SAFE_CAST(price AS FLOAT64) AS price,
  SAFE_CAST(freight_value AS FLOAT64) AS shipping_charge,
  -- number of items for this (order_id, product_id)
  COUNT(1) OVER (PARTITION BY NULLIF(TRIM(order_id), ''), NULLIF(TRIM(product_id), '')) AS no_items,
  -- DQ checks
  (IF(order_id IS NULL OR TRIM(order_id) = '', 1, 0)
   + IF(product_id IS NULL OR TRIM(product_id) = '', 1, 0)) AS _dq_null_count,
  CASE WHEN SAFE_CAST(price AS FLOAT64) IS NULL THEN 'type_error' ELSE 'ok' END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.order_items`
QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id, product_id ORDER BY order_id, product_id) = 1;
