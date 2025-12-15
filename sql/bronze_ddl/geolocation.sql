-- Bronze table DDL for geolocation (raw copy)
CREATE TABLE IF NOT EXISTS `fourth-library-296421.customer_analytics.geolocation` (
  geolocation_zip_code_prefix STRING,
  geolocation_lat FLOAT64,
  geolocation_lng FLOAT64,
  geolocation_city STRING,
  geolocation_state STRING
);

-- Source file: raw_data/geolocation_dataset.csv
-- Latitude/longitude stored as FLOAT64.