-- Bronze table DDL for sellers (raw copy)
CREATE TABLE IF NOT EXISTS `fourth-library-296421.customer_analytics.sellers` (
  seller_id STRING,
  seller_zip_code_prefix STRING,
  seller_city STRING,
  seller_state STRING
);

-- Source file: raw_data/sellers_dataset.csv
-- ZIP prefix kept as STRING to preserve leading zeros.