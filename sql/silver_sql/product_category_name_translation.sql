-- Silver: cleaned product category translations
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.product_category_name_translation` AS
SELECT
  NULLIF(TRIM(product_category_name), '') AS product_category_name,
  NULLIF(TRIM(product_category_name_english), '') AS product_category_name_english,
  (IF(product_category_name IS NULL OR TRIM(product_category_name) = '', 1, 0)
   + IF(product_category_name_english IS NULL OR TRIM(product_category_name_english) = '', 1, 0)) AS _dq_null_count,
  CASE WHEN product_category_name IS NULL THEN 'missing_key' ELSE 'ok' END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.product_category_name_translation`
QUALIFY ROW_NUMBER() OVER (PARTITION BY product_category_name ORDER BY product_category_name) = 1;
