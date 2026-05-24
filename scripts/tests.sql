
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
