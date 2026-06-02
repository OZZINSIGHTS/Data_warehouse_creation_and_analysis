WITH CUSTOMER_TABLE1 AS(
SELECT F.order_number
, F.customer_key
,CONCAT(C.firstname,' ',C.lastname) full_name
, C.gender
,DATEDIFF(YEAR,C.birthdate,'01-01-2015') age -----------FOR ACCUARACY I CHOOSE THIS DATE (01-01-2015)--------
, F.product_key 
, F.quantity
, F.order_date
,F.sales_amount
FROM gold_layer.fact_sales F
LEFT JOIN gold_layer.dim_customers C
ON F.customer_key = C.customer_key)
,CUSTOMER_TABLE2 AS(
SELECT customer_key
, full_name
, gender
,age 
,COUNT(DISTINCT order_number) total_orders
,SUM(sales_amount) total_sales
,SUM(quantity) total_quantity_purchased
,COUNT(DISTINCT product_key) number_of_product_purchased
,MAX(order_date) recent_order_date
,DATEDIFF(MONTH,MIN(order_date)
,MAX(order_date)) AS lifespan
FROM CUSTOMER_TABLE1
GROUP BY customer_key
, full_name
, gender
,age) 
SELECT * FROM CUSTOMER_TABLE2
