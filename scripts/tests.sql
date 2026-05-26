
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
SELECT a.category, AVG(b.price) average_price ,
SUM(b.sales_amount) AVERAGE_REVENUE
FROM gold_layer.dim_products a
LEFT JOIN gold_layer.fact_sales b
ON a.product_key = b.product_key
GROUP BY a.category
---------------------------------------------------------
---------------total_revenue_by_customers--------------
SELECT a.customer_key, SUM(b.sales_amount) total_revenue 
FROM gold_layer.dim_customers a
LEFT JOIN gold_layer.fact_sales b
ON a.customer_key = b.customer_key
GROUP BY a.customer_key 
ORDER BY total_revenue DESC
-------------------------------------------------------
------------------total_revenue_by_gender------------
SELECT a.gender, SUM(b.sales_amount) total_revenue 
FROM gold_layer.dim_customers a
LEFT JOIN gold_layer.fact_sales b
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
---------------------------------------------------------------------------------------------



