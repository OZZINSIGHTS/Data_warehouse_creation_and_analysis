CREATE OR ALTER PROCEDURE gold_layer.load_gold
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @batch_start DATETIME2 = SYSDATETIME();
    DECLARE @batch_end DATETIME2;
    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;

    PRINT '==================================================';
    PRINT 'PROCEDURE: gold_layer.load_gold';
    PRINT 'GOLD LAYER LOAD STARTED';
    PRINT 'START TIME: ' + CONVERT(VARCHAR(30), @batch_start, 120);
    PRINT '==================================================';

    BEGIN TRY

    --------------------------------------------------
    -- dim_customers
    --------------------------------------------------

        SET @step_start = SYSDATETIME();

        PRINT 'Dropping and Creating View: gold_layer.dim_customers';

        IF OBJECT_ID('gold_layer.dim_customers','V') IS NOT NULL
        DROP VIEW gold_layer.dim_customers; 
       
        EXEC('
        CREATE VIEW gold_layer.dim_customers
        AS
        SELECT ROW_NUMBER() OVER ( ORDER BY a.cst_id ASC ) AS customer_key
        ,a.cst_id AS customer_id
        , a.cst_key AS customer_number
        , a.cst_firstname AS firstname
        , a.cst_lastname  AS lastname
        ,CASE WHEN a.cst_gndr != ''UNKNOWN'' THEN a.cst_gndr
        ELSE COALESCE(b.GEN,''UNKNOWN'')
        END AS gender
        , a.cst_marital_status AS marital_status 
        , c.CNTRY country
        , b.BDATE birthdate
        , a.cst_create_date
        FROM silver_layer.crm_cust_info a
        LEFT JOIN 
        silver_layer.erp_CUST_AZ12 b
        ON 
        a.cst_key = b.CID
        LEFT JOIN 
        silver_layer.erp_LOC_A101 c
        ON 
        a.cst_key = c.CID
        ');

        SET @step_end = SYSDATETIME();

        PRINT 'Completed gold_layer.dim_customers in '
        + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- dim_products
    --------------------------------------------------

        SET @step_start = SYSDATETIME();

        PRINT 'Dropping and Creating View: gold_layer.dim_products';

        IF OBJECT_ID('gold_layer.dim_products','V') IS NOT NULL
        DROP VIEW gold_layer.dim_products;

        EXEC('
        CREATE VIEW gold_layer.dim_products
        AS
        SELECT ROW_NUMBER() OVER (ORDER BY a.prd_start_dt , a.prd_id ASC) product_key
        ,a.prd_id product_id
        , a.prd_key product_number
        , a.prd_nm product_name
        , b.SUBCAT sub_category
        , a.prd_cost cost
        , b.CAT category
        , a.prd_line product_line
        , b.MAINTENANCE maintenance
        , a.prd_start_dt product_start_dt
        FROM silver_layer.crm_prd_info a
        LEFT JOIN silver_layer.erp_PX_CAT_G1V2 b
        ON 
        a.cat_key = b.ID 
        WHERE a.prd_end_dt IS NULL
        ');

        SET @step_end = SYSDATETIME();

        PRINT 'Completed gold_layer.dim_products in '
        + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- fact_sales
    --------------------------------------------------

        SET @step_start = SYSDATETIME();

        PRINT 'Dropping and Creating View: gold_layer.fact_sales';

        IF OBJECT_ID('gold_layer.fact_sales','V') IS NOT NULL
        DROP VIEW gold_layer.fact_sales; 

        EXEC('
        CREATE VIEW gold_layer.fact_sales
        AS 
        SELECT a.sls_ord_num order_number
        ,b.customer_key customer_key
        ,c.product_key product_key
        , a.sls_price price
        , a.sls_quantity quantity
        , a.sls_sales sales_amount
        , a.sls_order_dt order_date
        , a.sls_ship_dt ship_date
        , a.sls_due_dt due_date
        FROM silver_layer.crm_sales_details a
        LEFT JOIN gold_layer.dim_customers b
        ON
        a.sls_cust_id = b.customer_id
        LEFT JOIN gold_layer.dim_products c
        ON
        a.sls_prd_key = c.product_number
        ');

        SET @step_end = SYSDATETIME();

        PRINT 'Completed gold_layer.fact_sales in '
        + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- Batch completed
    --------------------------------------------------

        SET @batch_end = SYSDATETIME();

        PRINT ' ';
        PRINT '==================================================';
        PRINT 'GOLD LAYER LOAD COMPLETED SUCCESSFULLY';
        PRINT 'END TIME: ' + CONVERT(VARCHAR(30), @batch_end, 120);
        PRINT 'TOTAL BATCH DURATION (seconds): '
        + CAST(DATEDIFF(SECOND,@batch_start,@batch_end) AS VARCHAR);
        PRINT '==================================================';

    END TRY

    BEGIN CATCH

        PRINT ' ';
        PRINT '==================================================';
        PRINT 'ERROR IN PROCEDURE: gold_layer.load_gold';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR TIME: ' + CONVERT(VARCHAR(30), SYSDATETIME(), 120);
        PRINT 'TOTAL ELAPSED TIME BEFORE FAILURE (seconds): '
        + CAST(DATEDIFF(SECOND,@batch_start,SYSDATETIME()) AS VARCHAR);
        PRINT '==================================================';

        THROW;

    END CATCH

END;
GO
