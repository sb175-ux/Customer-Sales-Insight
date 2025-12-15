-- Silver: cleaned geolocation with DQ checks
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.geolocation` AS
SELECT
  NULLIF(TRIM(CAST(geolocation_zip_code_prefix AS STRING)), '') AS geolocation_zip_code_prefix,
  SAFE_CAST(geolocation_lat AS FLOAT64) AS geolocation_lat,
  SAFE_CAST(geolocation_lng AS FLOAT64) AS geolocation_lng,
  LOWER(NULLIF(TRIM(geolocation_city), '')) AS geolocation_city,
  UPPER(NULLIF(TRIM(geolocation_state), '')) AS geolocation_state,
  -- DQ checks
  (IF(geolocation_zip_code_prefix IS NULL OR TRIM(CAST(geolocation_zip_code_prefix AS STRING)) = '', 1, 0)
   + IF(geolocation_lat IS NULL, 1, 0)
   + IF(geolocation_lng IS NULL, 1, 0)) AS _dq_null_count,
  CASE WHEN SAFE_CAST(geolocation_lat AS FLOAT64) IS NULL OR SAFE_CAST(geolocation_lng AS FLOAT64) IS NULL
       THEN 'invalid_coords' ELSE 'ok' END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.geolocation`;
