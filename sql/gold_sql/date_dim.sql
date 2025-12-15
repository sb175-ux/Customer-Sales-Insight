-- Gold: Date dimension
-- Generates one row per date from 2016-01-01 through 2019-01-01 (inclusive)
-- Columns: date, year, quarter, month, month_name, day

CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_features.date_dim` AS
WITH dates AS (
  SELECT d AS day
  FROM UNNEST(GENERATE_DATE_ARRAY('2016-01-01', '2019-01-01')) AS d
)
SELECT
  day AS date,
  EXTRACT(YEAR FROM day) AS year,
  EXTRACT(QUARTER FROM day) AS quarter,
  EXTRACT(MONTH FROM day) AS month,
  FORMAT_DATE('%B', day) AS month_name,
  EXTRACT(DAY FROM day) AS day
FROM dates
ORDER BY date;