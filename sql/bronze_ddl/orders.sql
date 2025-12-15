-- Bronze table DDL for orders (raw copy)
CREATE TABLE IF NOT EXISTS `fourth-library-296421.customer_analytics.orders` (
  order_id STRING,
  customer_id STRING,
  order_status STRING,
  order_purchase_timestamp TIMESTAMP,
  order_approved_at TIMESTAMP,
  order_delivered_carrier_date TIMESTAMP,
  order_delivered_customer_date TIMESTAMP,
  order_estimated_delivery_date TIMESTAMP
);

-- Source file: raw_data/orders_dataset.csv
-- All timestamp columns use format "YYYY-MM-DD HH:MM:SS" where present.