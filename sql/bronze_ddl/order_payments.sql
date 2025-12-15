-- Bronze table DDL for order_payments (raw copy)
CREATE TABLE IF NOT EXISTS `fourth-library-296421.customer_analytics.order_payments` (
  order_id STRING,
  payment_sequential INT64,
  payment_type STRING,
  payment_installments INT64,
  payment_value FLOAT64
);

-- Source file: raw_data/order_payments_dataset.csv