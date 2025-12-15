-- Silver: cleaned products with DQ and numeric validations
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.products` AS
SELECT
  NULLIF(TRIM(product_id), '') AS product_id,
  NULLIF(TRIM(product_category_name), '') AS product_category_name,
  SAFE_CAST(product_name_lenght AS INT64) AS product_name_lenght,
  SAFE_CAST(product_description_lenght AS INT64) AS product_description_lenght,
  SAFE_CAST(product_photos_qty AS INT64) AS product_photos_qty,
  SAFE_CAST(product_weight_g AS INT64) AS product_weight_g,
  SAFE_CAST(product_length_cm AS INT64) AS product_length_cm,
  SAFE_CAST(product_height_cm AS INT64) AS product_height_cm,
  SAFE_CAST(product_width_cm AS INT64) AS product_width_cm,
  (IF(product_id IS NULL OR TRIM(product_id) = '', 1, 0)
   + IF(product_category_name IS NULL OR TRIM(product_category_name) = '', 1, 0)) AS _dq_null_count,
  CASE WHEN SAFE_CAST(product_weight_g AS INT64) IS NULL THEN 'invalid_weight' ELSE 'ok' END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.products`
QUALIFY ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) = 1;
