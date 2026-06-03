/*============================================================

-----gold_layercustomers_report-------------

REPORT NAME: Customers Report
LAYER: Gold Layer
OBJECT TYPE: View

PURPOSE:
This report provides a customer-centric summary of sales activity,
customer demographics, purchasing behavior, and customer value metrics.
It is designed to support customer segmentation, retention analysis,
and business decision-making.

CONTENT:

1. Customer Information
   - Customer Key
   - Full Name
   - Gender
   - Age
   - Age Group

2. Purchase Metrics
   - Total Orders
   - Total Sales
   - Total Quantity Purchased
   - Number of Distinct Products Purchased

3. Customer Activity Metrics
   - Most Recent Order Date
   - Customer Lifespan (months between first and last purchase)
   - Recency (months since last purchase)

4. Customer Value Metrics
   - Average Order Value (AOV)
   - Average Monthly Spend

BUSINESS USE CASES:
   - Identify high-value customers
   - Analyze customer purchasing patterns
   - Segment customers by age group
   - Support retention and loyalty analysis
   - Monitor customer engagement and recency
   - Build customer dashboards and KPIs

NOTES:
   - Age is calculated using a fixed reference date
     ('2015-01-01') for testing purposes.
   - Recency is calculated relative to the same
     reference date for testing purposes.
============================================================*/
CREATE OR ALTER VIEW gold_layer.customers_report AS 
WITH CUSTOMER_TABLE1 AS(
SELECT F.order_number
, F.customer_key
,CONCAT(C.firstname,' ',C.lastname) full_name
, C.gender
,DATEDIFF(YEAR,C.birthdate,'01-01-2015') age -----------FOR ACCUARACY I CHOOSE THIS DATE (01-01-2015) is just for tests--------
, F.product_key 
, F.quantity
, F.order_date
,F.sales_amount
FROM gold_layer.fact_sales F
LEFT JOIN gold_layer.dim_customers C
ON F.customer_key = C.customer_key
WHERE order_date IS NOT NULL )
,CUSTOMER_TABLE2 AS(
SELECT customer_key
, full_name
, gender
,age 
, CASE WHEN age IS NULL THEN 'unknown'
WHEN age < 19 THEN 'Up to 19'
WHEN age >= 20 AND age <= 29 THEN '20s'
WHEN age >= 30 AND age <= 39 THEN '30s'------------Age groups 
WHEN age >= 40 AND age <= 49 THEN '40s'
ELSE '50+' 
END AS Age_group
,COUNT(DISTINCT order_number) total_orders
,SUM(sales_amount) total_sales
,SUM(quantity) total_quantity_purchased
,COUNT(DISTINCT product_key) number_of_product_purchased
,MAX(order_date) recent_order_date
,DATEDIFF(MONTH,MIN(order_date) , MAX(order_date)) AS lifespan

FROM CUSTOMER_TABLE1
GROUP BY customer_key
, full_name
, gender
,age )
, CUSTOMER_TABLE3 AS (
SELECT customer_key
, full_name
, gender
, age
, Age_group
, total_orders 
,total_sales,total_quantity_purchased
, number_of_product_purchased
, recent_order_date 
,lifespan
,DATEDIFF(MONTH,recent_order_date,'01-01-2015') recency  -----------FOR ACCUARACY I CHOOSE THIS DATE (01-01-2015) is just for tests--------
,CASE WHEN total_orders = 0 THEN total_sales
ELSE total_sales/total_orders
END AS Average_order_value
,CASE WHEN lifespan = 0 THEN total_sales
ELSE total_sales/lifespan 
END AS Average_monthly_spend
FROM CUSTOMER_TABLE2 ) 

SELECT * FROM CUSTOMER_TABLE3
