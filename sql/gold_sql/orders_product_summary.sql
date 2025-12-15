-- Gold: Orders + aggregated order_items merged with product-level aggregates using CTEs
-- Produces one row per (order_id, product_id, customer_id) enriched with full order columns, product,customers and reiews details
-- Granularity: (order_id, product_id, customer_id)

CREATE OR REPLACE TABLE `fourth-library-296421.customer_analytics_features.orders_product_summary` AS
WITH
items AS (
  SELECT
    NULLIF(TRIM(order_id), '') AS order_id,
    NULLIF(TRIM(product_id), '') AS product_id,
    NULLIF(TRIM(seller_id), '') AS seller_id,
    COALESCE(SAFE_CAST(shipping_limit_date AS TIMESTAMP), NULL) AS shipping_limit_date,
    COALESCE(SAFE_CAST(price AS FLOAT64), 0.0) AS price,
    COALESCE(SAFE_CAST(shipping_charge AS FLOAT64), 0.0) AS shipping_charge,
    COALESCE(no_items, 1) AS no_items
  FROM `fourth-library-296421.customer_analytics_stage.order_items`
),
-- aggregate items at order_id + product_id level
items_agg AS (
  SELECT
    ia.order_id,
    ia.product_id,
    SUM(ia.price) AS item_total_price,
    SUM(ia.shipping_charge) AS item_total_shipping_charge,
    SUM(ia.no_items) AS item_total_units,
    COUNT(1) AS item_rows,
    max(ia.seller_id) AS any_seller_id,
    max(ia.shipping_limit_date) AS any_shipping_limit_date,
    t.product_category_name_english as product_category_name
  FROM items ia
  LEFT JOIN `fourth-library-296421.customer_analytics_stage.products` p USING(product_id)
  LEFT JOIN `fourth-library-296421.customer_analytics_stage.product_category_name_translation` t
    ON p.product_category_name = t.product_category_name
  GROUP BY ia.order_id, ia.product_id, t.product_category_name_english
)

SELECT
  ord.*,
  ia.product_id,
    customers_dataset.customer_city,
    customers_dataset.customer_state,
    customers_dataset.customer_zip_code_prefix,
  ia.item_total_price,
  ia.item_total_shipping_charge,
  ia.item_total_units,
  ia.item_rows,
  ia.any_seller_id AS seller_id,
  ia.any_shipping_limit_date AS shipping_limit_date,
  ia.product_category_name,
  order_reviews.review_score,
  order_reviews.review_creation_date,
  order_reviews.review_answer_timestamp
FROM `fourth-library-296421.customer_analytics_stage.orders` ord
LEFT JOIN items_agg ia
ON NULLIF(TRIM(ord.order_id), '') = ia.order_id
LEFT JOIN `fourth-library-296421.customer_analytics_stage.customers` AS customers_dataset
ON NULLIF(TRIM(customers_dataset.customer_id), '') = ord.customer_id
left join `fourth-library-296421.customer_analytics_stage.order_reviews` AS order_reviews
ON NULLIF(TRIM(order_reviews.order_id), '') = ord.order_id
ORDER BY ord.order_id, ia.product_id, ord.customer_id;