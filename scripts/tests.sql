
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
----------TOTAL SALES-------
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



