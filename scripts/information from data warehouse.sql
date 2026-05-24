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

--------------activity of the company over months----------
SELECT 
    MONTH(due_date) AS MONTHS,
    FORMAT(SUM(CASE 
            WHEN YEAR(due_date) = 2011 
            THEN sales_amount 
        END),'C') AS SALES_2011,
    FORMAT(SUM(CASE 
            WHEN YEAR(due_date) = 2012 
            THEN sales_amount 
        END),'C') AS SALES_2012,
    FORMAT(SUM(CASE 
            WHEN YEAR(due_date) = 2013 
            THEN sales_amount 
        END),'C') AS SALES_2013,
    FORMAT(SUM(CASE 
            WHEN YEAR(due_date) = 2014 
            THEN sales_amount 
        END),'C') AS SALES_2014
FROM gold_layer.fact_sales
GROUP BY MONTH(due_date)
ORDER BY MONTH(due_date);

--------------------------------------------------------------


-------------------sales amount by product over years---------
SELECT b.sub_category, FORMAT(SUM(CASE WHEN YEAR(a.due_date) = 2011 THEN a.sales_amount END),'C') YEARN2011,
FORMAT(SUM(CASE WHEN YEAR(a.due_date) = 2012 THEN a.sales_amount END),'C') YEAR2012
,FORMAT(SUM(CASE WHEN YEAR(a.due_date) = 2013 THEN a.sales_amount END),'C') YEAR2013
,FORMAT(SUM(CASE WHEN YEAR(a.due_date) = 2014 THEN a.sales_amount END),'C') YEAR2014
FROM gold_layer.fact_sales a
LEFT JOIN gold_layer.dim_products b
ON a.product_key = b.product_key
GROUP BY b.sub_category
ORDER BY b.sub_category ASC

------------------------------------------------------------------

    
------------------MoM% Growth filtered by years---------------
WITH sales_cte AS
(
    SELECT 
        MONTH(due_date) AS month_number,
        SUM(sales_amount) AS total_sales
    FROM gold_layer.fact_sales
    WHERE YEAR(due_date) = 2014 --------> year filter
   GROUP BY MONTH(due_date)
)
SELECT * FROM (
SELECT 
    month_number,
    total_sales,

    LAG(total_sales) OVER(ORDER BY month_number) AS previous_month_sales,

    CAST(
        (total_sales - LAG(total_sales) OVER(ORDER BY month_number))
        * 100.0
        / NULLIF(LAG(total_sales) OVER(ORDER BY month_number),0)
    AS DECIMAL(10,2)) AS growth_percentage

FROM sales_cte ) N 
WHERE previous_month_sales IS NOT NULL

--Note: June had several sales amount growth spikes for over +20% to +44% over 2011 / 2012 / 2013
--------sales significally dropped from dec 2013 to jan 2014 by -69.12% then by -97.40% in Feb as the last month where records had ended.
