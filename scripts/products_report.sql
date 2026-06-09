/*============================================================
REPORT NAME: Product Report
LAYER: Gold Layer
OBJECT TYPE: View

PURPOSE:
This report provides a product-level summary of sales performance,
customer demand, and product revenue metrics. It is designed to
support product performance analysis, inventory planning, and
business decision-making.

CONTENT:

1. Product Information
   - Product Key
   - Product ID
   - Product Number
   - Product Name
   - Sub Category
   - Category

2. Sales Performance Metrics
   - Total Orders
   - Total Sales Revenue
   - Total Quantity Sold
   - Total Customers

3. Product Activity Metrics
   - Most Recent Order Date
   - Product Lifespan (months between first and last sale)
   - Recency (months since last sale)

4. Product Revenue Metrics
   - Average Order Revenue
   - Average Monthly Revenue

BUSINESS USE CASES:
   - Identify top-performing products
   - Analyze product demand trends
   - Evaluate category and subcategory performance
   - Monitor product sales activity
   - Identify inactive or declining products
   - Support inventory and procurement decisions
   - Build product performance dashboards and KPIs

NOTES:
   - Recency is calculated using the fixed reference date
     ('2015-01-01') for testing purposes.
   - Revenue metrics are based on sales transactions
     recorded in the fact_sales table.
============================================================*/
CREATE VIEW gold_layer.product_report AS WITH INITIAL_TABLE AS (SELECT 
S.order_number
,S.customer_key
,P.product_key 
, P.product_id 
, P.product_number
, P.product_name
, P.sub_category
, P.category
, P.cost
, S.price
, S.quantity
,S.order_date
,S.sales_amount FROM gold_layer.fact_sales S
LEFT JOIN  gold_layer.dim_products P
ON S.product_key = P.product_key)
, METRICS_TABLE AS (SELECT product_key 
, product_id 
, product_number
, product_name
, sub_category
, category
,MAX(order_date) recent_order_date
,DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) LIFE_SPAN
, COUNT(DISTINCT order_number) TOTAL_ORDERS
, SUM(sales_amount) TOTAL_SALES
, COUNT(DISTINCT customer_key) TOTAL_CUSTOMERS
,SUM(quantity) TOTAL_QUANTITY_SOLD 
FROM INITIAL_TABLE
GROUP BY product_key 
, product_id 
, product_number
, product_name
, sub_category
, category)
,
KPIs_TABLE AS
( SELECT product_key,product_id
, product_number
, sub_category
, category
, LIFE_SPAN
, TOTAL_ORDERS
,TOTAL_SALES
,TOTAL_CUSTOMERS
,TOTAL_QUANTITY_SOLD
,DATEDIFF(MONTH,MAX(recent_order_date),'01-01-2015') RECENCY
,ROUND(TOTAL_SALES/TOTAL_ORDERS,2) AVERAGE_ORDER_REVENUE
,ROUND(TOTAL_SALES/LIFE_SPAN,2) AVERAGE_MONTHLY_REVENUE
FROM METRICS_TABLE
GROUP BY product_key,product_id
, product_number
, sub_category
, category
, LIFE_SPAN
, TOTAL_ORDERS
,TOTAL_SALES
,TOTAL_CUSTOMERS
,TOTAL_QUANTITY_SOLD)
SELECT * FROM KPIs_TABLE
