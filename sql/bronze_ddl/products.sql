-- Bronze table DDL for products (raw copy)
CREATE TABLE IF NOT EXISTS `fourth-library-296421.customer_analytics.products` (
  product_id STRING,
  product_category_name STRING,
  product_name_lenght INT64,
  product_description_lenght INT64,
  product_photos_qty INT64,
  product_weight_g INT64,
  product_length_cm INT64,
  product_height_cm INT64,
  product_width_cm INT64
);

-- Source file: raw_data/products_dataset.csv
-- Note: column name misspelling "lenght" preserved to match raw header.