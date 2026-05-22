-----------activity of the company over years-------------
SELECT YEAR(a.due_date),b.category ,
    FORMAT(SUM(a.sales_amount), 'C0') AS salesamount
FROM gold_layer.fact_sales a
LEFT JOIN 
gold_layer.dim_products b
ON a.product_key = b.product_key
GROUP BY YEAR(a.due_date), b.category
ORDER BY year(a.due_date), b.category
-------------------------------------------------------
