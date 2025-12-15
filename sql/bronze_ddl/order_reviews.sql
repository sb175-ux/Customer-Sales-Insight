-- Bronze table DDL for order_reviews (raw copy)
CREATE TABLE IF NOT EXISTS `fourth-library-296421.customer_analytics.order_reviews` (
  review_id STRING,
  order_id STRING,
  review_score INT64,
  review_comment_title STRING,
  review_comment_message STRING,
  review_creation_date TIMESTAMP,
  review_answer_timestamp TIMESTAMP
);

-- Source file: raw_data/order_reviews_dataset.csv
-- review timestamps stored as TIMESTAMP.