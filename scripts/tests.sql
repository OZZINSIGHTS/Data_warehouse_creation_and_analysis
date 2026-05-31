
----------I HAVE MULTIPLE YEARS -------


WITH sales_cte AS
(
    SELECT 
        MONTH(due_date) AS month_number,
        SUM(sales_amount) AS total_sales
    FROM gold_layer.fact_sales
    GROUP BY MONTH(due_date)
)

SELECT 
    month_number,
    total_sales,

    LAG(total_sales) OVER(ORDER BY month_number) AS previous_month_sales,

    ROUND(
        (total_sales - LAG(total_sales) OVER(ORDER BY month_number))
        * 100.0
        / NULLIF(LAG(total_sales) OVER(ORDER BY month_number),0)
    ,2) AS growth_percentage

FROM sales_cte;

-----------------------------------------------------------
----------general information about activity-------
SELECT 'sales_amount' AS measure_value, SUM(sales_amount) measure_value FROM gold_layer.fact_sales
UNION ALL
SELECT 'total_item_sold' , SUM(quantity) FROM gold_layer.fact_sales
UNION ALL
SELECT 'avg_price' , AVG(price)  FROM gold_layer.fact_sales
UNION ALL
SELECT 'total_orders', COUNT(DISTINCT order_number) FROM gold_layer.fact_sales
UNION ALL
SELECT 'total_number_of_products', COUNT(DISTINCT product_key)  FROM gold_layer.dim_products
UNION ALL
SELECT 'number_of_customers', COUNT(DISTINCT customer_key)  FROM gold_layer.dim_customers
UNION ALL
SELECT 'number_of_active_customers', COUNT(DISTINCT customer_key)  FROM gold_layer.fact_sales

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
------------------------------number_of_customers_by_countries---------------------
SELECT country, COUNT(customer_key) number_of_customers FROM gold_layer.dim_customers
GROUP BY country
-------------------------------------------------------------------------
--------------------------gender_distribution______________________________
SELECT gender, COUNT(customer_key) number_of_customers FROM gold_layer.dim_customers
GROUP BY gender
--------------------------------------------------------------------------------
--------------------number_of_products_by_category----------------------
SELECT category, COUNT(product_key) number_of_products FROM gold_layer.dim_products
GROUP BY category
--------------------------------------------------------
----------------average_price_by_category-----------
SELECT a.category, AVG(a.cost) average_price ,
SUM(b.sales_amount) total_revenue
FROM gold_layer.dim_products a
LEFT JOIN gold_layer.fact_sales b
ON a.product_key = b.product_key
GROUP BY a.category
---------------------------------------------------------
---------------total_revenue_by_customers--------------
SELECT b.customer_key,b.firstname,b.lastname, SUM(a.sales_amount) total_revenue 
FROM gold_layer.fact_sales a
LEFT JOIN gold_layer.dim_customers b
ON a.customer_key = b.customer_key
GROUP BY b.customer_key , b.firstname, b.lastname
ORDER BY total_revenue DESC
-------------------------------------------------------
------------------total_revenue_by_gender------------
SELECT a.gender, SUM(b.sales_amount) total_revenue 
FROM gold_layer.fact_sales b
LEFT JOIN gold_layer.dim_customers a
ON a.customer_key = b.customer_key
GROUP BY a.gender 
ORDER BY total_revenue DESC
---------------------------------------------------------
-------------------items_sold_distribution-------------------
SELECT b.country ,COUNT( a.quantity ) items_sold_distribution FROM gold_layer.fact_sales a
LEFT JOIN 
gold_layer.dim_customers b
ON a.customer_key = b.customer_key
GROUP BY b.country
ORDER BY items_sold_distribution DESC
---------------------------------------------------
-------------------------------------------------I NEED TO CORRECT THIS 
WITH YEARLY_SALES AS (
SELECT YEAR(fs.order_date) Years ,dp.product_name pd_name,SUM(fs.sales_amount) TOTALSALES
FROM gold_layer.fact_sales fs
LEFT JOIN 
gold_layer.dim_products dp
ON 
dp.product_key = fs.product_key 
WHERE YEAR(fs.order_date) IS NOT NULL 
GROUP BY YEAR(fs.order_date), dp.product_name
)
SELECT Years, pd_name, TOTALSALES, 
COALESCE((TOTALSALES - LAG(TOTALSALES) OVER(PARTITION BY pd_name ORDER BY Years))/NULLIF(LAG(TOTALSALES) OVER(PARTITION BY pd_name ORDER BY Years),0)*100,0) prv_year_salesamount,
(TOTALSALES - AVG(TOTALSALES) OVER(PARTITION BY YEARS))/ NULLIF(AVG(TOTALSALES) OVER(PARTITION BY YEARS),0)*100 AS AVGG
FROM YEARLY_SALES
ORDER BY Years

--------------------------------------------------------------------------
-------------------------PART TO WHOLE BY CATEGORY----------------------------------------------------

WITH TOTAL_SALES AS (
SELECT DM.category CATEGORY, SUM(FS.sales_amount) SALES FROM gold_layer.fact_sales FS
LEFT JOIN gold_layer.dim_products DM
ON FS.product_key = DM.product_key
GROUP BY DM.category)
SELECT CATEGORY, SALES, SUM(SALES) OVER() OVERALLSALES
,CONCAT(ROUND((CAST(SALES AS FLOAT)/SUM(SALES) OVER() ) *100,2),'%') 'OVERALL_CHANGE%' FROM TOTAL_SALES
--------------------------------------------------------------------------------------------------------

---------------------------CUSTOMERS STATEMENT ---------------------------
	WITH INFO AS (
	
	SELECT C.customer_key CUSTOMERKEY
	, C.firstname FIRSTNAME
	, C.lastname LASTNAME 
	, SUM(F.sales_amount) SALES
	, DATEDIFF(MONTH,MIN(F.order_date),MAX(F.order_date)) span
FROM gold_layer.fact_sales F
LEFT JOIN gold_layer.dim_customers C
ON F.customer_key = C.customer_key
GROUP BY C.customer_key, C.firstname, C.lastname)
 SELECT CUSTOMER_STATEMENT , COUNT(DISTINCT CUSTOMERKEY) 
 FROM 
 (SELECT CUSTOMERKEY
, FIRSTNAME
, LASTNAME 
, CASE WHEN span > 12 AND SALES > 5000 THEN 'VIP'
 WHEN span > 12 AND SALES <= 5000 THEN 'REGULAR'
ELSE 'NEW'
END AS CUSTOMER_STATEMENT 
FROM INFO ) T 
GROUP BY CUSTOMER_STATEMENT
----------------------------------------------------------------------------------





