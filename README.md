## 🔗 View Dashboard
**[→ View Interactive Dashboard on Tableau Public](https://public.tableau.com/views/CustomerSalesInsight/Dashboard2?:language=en-GB&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

# customer-sales-insight-tableau

Customer Sales analytics project that builds an ELT pipeline from raw CSVs into BigQuery and produces gold tables useful for tableau BI dashboards.

## Overview
This repo ingests raw datasets (CSV) into a bronze layer, applies data-quality & normalization to create a silver layer, then aggregates and enriches data into gold tables for reporting and feature consumption.

Datasets used in SQLs (BigQuery project: `fourth-library-296421`):
- `customer_analytics` (bronze DDLs) — raw table definitions
- `customer_analytics_stage` (silver) — cleaned & validated data
- `customer_analytics_features` — (gold) — reporting-ready tables

## Repository layout
- `raw_data/` — source CSV files (renamed & cleaned)
- `sql/bronze_ddl/` — bronze CREATE TABLE scripts
- `sql/silver_sql/` — silver transformation DDLs (cleaning, type coercion, DQ checks)
- `sql/gold_sql/` — gold reporting scripts (aggregations and denormalized tables)
- `sql/dq/` — (optional) data quality checks

## Important SQL files added/updated
- `sql/silver_sql/*.sql` — cleaned versions of source tables (customers, orders, order_items, products, etc.)
- `sql/gold_sql/date_dim.sql` — date dimension (2016-01-01 through 2019-01-01)
- `sql/gold_sql/orders_fact.sql` — (intermediate) orders-product-level fact (order_id, product_id, customer_id granularity)
- `sql/gold_sql/product_sales_summary.sql` — product-level aggregates (units, total sales) and category translation
- `sql/gold_sql/orders_product_summary.sql` — merged orders + aggregated order_items + product aggregates (main reporting table)
- `sql/gold_sql/customer_churn.sql` — churn snapshot with 90-day default window
- `sql/gold_sql/payment_type_date.sql` — payment totals by `payment_type` and order date

## How to run
1. Upload raw CSVs to BigQuery or stage them in GCS as needed.
2. Run bronze DDL scripts to create raw tables (if not already present).
3. Run each file in `sql/silver_sql/` to populate the cleaned `customer_analytics_stage` tables.
4. Run files in `sql/gold_sql/` to create reporting tables in `customer_analytics_features`.

Example (bq CLI):

bq query --use_legacy_sql=false "$(cat sql/silver_sql/customers.sql)"

Or paste the SQL into the BigQuery UI and run.

## Notes, decisions and assumptions
- `order_items.freight_value` was aliased to `shipping_charge` in the silver layer; gold scripts were updated to use `shipping_charge`.
- `orders_product_summary` is built at (order_id, product_id, customer_id) granularity and keeps important order fields repeated per product row for reporting convenience.
- `date_dim` covers 2016-01-01 through 2019-01-01 as requested.
- Customer churn uses a 90-day inactivity window (configurable in the SQL file).

## Next improvements (optional)
- Partition big tables (e.g., `orders_product_summary` by `order_purchase_timestamp`) and cluster by `product_id`/`customer_id`.
- Materialize `product_sales_summary` as a persistent table if it's reused frequently.
- Add simple validation queries/tests to assert row counts and sums between layers.

## Quick sample queries
- Total revenue (price only):
  SELECT SUM(order_product_price) FROM `fourth-library-296421.customer_analytics_gold.orders_product_summary`;

- Top products by revenue:
  SELECT product_id, SUM(order_product_price) AS revenue FROM `fourth-library-296421.customer_analytics_gold.orders_product_summary` GROUP BY product_id ORDER BY revenue DESC LIMIT 20;

- Payment totals by type and date:
  SELECT * FROM `fourth-library-296421.customer_analytics_gold.payment_type_date` LIMIT 50;

## KPIs used in the Tableau dashboard
The project includes ready-to-use metrics (KPIs) surfaced in the Tableau dashboard screenshot. Below are the KPIs and the tables/fields used to compute them (so you can reproduce the numbers in Power BI/Tableau).

- Total_Sales
  - Definition: sum of revenue. Use `order_product_sales` (price + shipping) or `order_product_price` (price-only) depending on whether you include shipping.
  - Source: `fourth-library-296421.customer_analytics_gold.orders_product_summary` (column `order_product_sales` or `order_product_price`) or aggregate from `product_sales_summary`.

- TotalCustomer
  - Definition: number of unique customers.
  - Source: `fourth-library-296421.customer_analytics_gold.orders_product_summary` -> COUNT(DISTINCT customer_id)

- TotalOrder
  - Definition: number of unique orders.
  - Source: `fourth-library-296421.customer_analytics_gold.orders_product_summary` -> COUNT(DISTINCT order_id)

- CLV (Customer Lifetime Value)
  - Definition: average lifetime revenue per customer (simple metric = SUM(revenue) / COUNT(DISTINCT customer_id)).
  - Source: compute from `orders_product_summary` grouping by `customer_id` and averaging the sum of `order_product_sales`.

- AOV (Average Order Value)
  - Definition: average revenue per order. e.g., AVG(order_total) where order_total is SUM(order_product_sales) per `order_id`.
  - Source: `orders_product_summary` aggregated to order level.

- Top 10 Products
  - Definition: products ranked by total revenue.
  - Source: `fourth-library-296421.customer_analytics_gold.orders_product_summary` aggregated by `product_id` OR `fourth-library-296421.customer_analytics_gold.product_sales_summary` (product_total_sales_all_orders).

- Revenue Trend By Year (time series)
  - Source: `orders_product_summary` joined to `date_dim` (or using `order_purchase_timestamp`) and aggregated by year.

- Detailed Sales Table
  - Definition: table view with product category, total orders, CLV etc.
  - Source: `orders_product_summary` + `product_agg` fields (category translation available via `product_category_name_english`).

- Customer Segmentation & Churn
  - Churn flag: uses `fourth-library-296421.customer_analytics_gold.customer_churn` (column `is_churned`) where churn is defined as no orders in the last 90 days relative to snapshot.
  - Segment customers by lifetime value or recency using `orders_product_summary` and `customer_churn`.

- Payment totals by type and date
  - Source: `fourth-library-296421.customer_analytics_gold.payment_type_date` (aggregates `payment_value` per `payment_type` and `order_date`).

## Reproducing the KPIs
- Use the `orders_product_summary` table as the primary reporting table for most KPIs. It is at `(order_id, product_id, customer_id)` granularity.
- Typical SQL patterns:
  - Total Sales (including shipping): SELECT SUM(order_product_sales) FROM `...orders_product_summary`;
  - AOV: SELECT AVG(order_total) FROM (SELECT order_id, SUM(order_product_sales) AS order_total FROM `...orders_product_summary` GROUP BY order_id);
  - Top products: SELECT product_id, SUM(order_product_sales) AS revenue FROM `...orders_product_summary` GROUP BY product_id ORDER BY revenue DESC LIMIT 10;
