-- Silver: cleaned sellers with DQ checks
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.sellers` AS
SELECT
  NULLIF(TRIM(seller_id), '') AS seller_id,
  NULLIF(TRIM(CAST(seller_zip_code_prefix AS STRING)), '') AS seller_zip_code_prefix,
  LOWER(NULLIF(TRIM(seller_city), '')) AS seller_city,
  UPPER(NULLIF(TRIM(seller_state), '')) AS seller_state,
  (IF(seller_id IS NULL OR TRIM(seller_id) = '', 1, 0)
   + IF(seller_zip_code_prefix IS NULL OR TRIM(CAST(seller_zip_code_prefix AS STRING)) = '', 1, 0)) AS _dq_null_count,
  CASE WHEN seller_id IS NULL THEN 'missing_key' ELSE 'ok' END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.sellers`
QUALIFY ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY seller_id) = 1;
