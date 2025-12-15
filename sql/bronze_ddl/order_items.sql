-- Bronze table DDL for order_items (raw copy)
CREATE TABLE IF NOT EXISTS `fourth-library-296421.customer_analytics.order_items` (
  order_id STRING,
  order_item_id INT64,
  product_id STRING,
  seller_id STRING,
  shipping_limit_date TIMESTAMP,
  price FLOAT64,
  freight_value FLOAT64
);

-- Source file: raw_data/order_items_dataset.csv
-- shipping_limit_date has format "YYYY-MM-DD HH:MM:SS"; stored as TIMESTAMP.