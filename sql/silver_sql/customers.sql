-- Silver: cleaned customers with DQ checks
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.customers` AS
SELECT
  NULLIF(TRIM(customer_id), '') AS customer_id,
  NULLIF(TRIM(customer_unique_id), '') AS customer_unique_id,
  NULLIF(TRIM(CAST(customer_zip_code_prefix AS STRING)), '') AS customer_zip_code_prefix,
  LOWER(NULLIF(TRIM(customer_city), '')) AS customer_city,
  UPPER(NULLIF(TRIM(customer_state), '')) AS customer_state,
  -- DQ checks
  (IF(customer_id IS NULL OR TRIM(customer_id) = '', 1, 0)
   + IF(customer_unique_id IS NULL OR TRIM(customer_unique_id) = '', 1, 0)) AS _dq_null_count,
  CASE
    WHEN customer_id IS NULL OR TRIM(customer_id) = '' THEN 'missing_key'
    WHEN customer_unique_id IS NULL OR TRIM(customer_unique_id) = '' THEN 'missing_unique_id'
    ELSE 'ok'
  END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.customer_data`
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) = 1;
