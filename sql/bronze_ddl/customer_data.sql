-- Bronze table DDL for customers (raw copy, minimal transforms)
CREATE TABLE IF NOT EXISTS `fourth-library-296421.customer_analytics.customer_data` (
  customer_id STRING,
  customer_unique_id STRING,
  customer_zip_code_prefix STRING,
  customer_city STRING,
  customer_state STRING
);

-- Source file: raw_data/customers_dataset.csv
-- Note: zip prefix kept as STRING to preserve leading zeros.