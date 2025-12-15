-- Silver: cleaned order_reviews with DQ checks
CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_stage.order_reviews` AS
SELECT
  NULLIF(TRIM(review_id), '') AS review_id,
  NULLIF(TRIM(order_id), '') AS order_id,
  SAFE_CAST(review_score AS INT64) AS review_score,
  NULLIF(TRIM(review_comment_title), '') AS review_comment_title,
  NULLIF(TRIM(review_comment_message), '') AS review_comment_message,
  COALESCE(SAFE_CAST(review_creation_date AS TIMESTAMP), NULL) AS review_creation_date,
  COALESCE(SAFE_CAST(review_answer_timestamp AS TIMESTAMP), NULL) AS review_answer_timestamp,
  -- DQ checks
  (IF(review_id IS NULL OR TRIM(review_id) = '', 1, 0)
   + IF(review_score IS NULL, 1, 0)) AS _dq_null_count,
  CASE WHEN SAFE_CAST(review_score AS INT64) IS NULL THEN 'invalid_score' ELSE 'ok' END AS _dq_status,
  CURRENT_TIMESTAMP() AS _ingest_ts
FROM `fourth-library-296421.customer_analytics.order_reviews`
QUALIFY ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_id) = 1;
