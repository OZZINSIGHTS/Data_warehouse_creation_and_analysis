CREATE OR ALTER PROCEDURE silver_layer.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @batch_start DATETIME2 = SYSDATETIME();
    DECLARE @batch_end DATETIME2;
    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;

    PRINT '==================================================';
    PRINT 'PROCEDURE: silver_layer.load_silver';
    PRINT 'SILVER LAYER LOAD STARTED';
    PRINT 'START TIME: ' + CONVERT(VARCHAR(30), @batch_start, 120);
    PRINT '==================================================';

    BEGIN TRY

    --------------------------------------------------
    -- crm_cust_info
    --------------------------------------------------
        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: silver_layer.crm_cust_info';

        TRUNCATE TABLE silver_layer.crm_cust_info;

        INSERT INTO silver_layer.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE
                WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'Single'
                WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'UNKNOWN'
            END,
            CASE
                WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Female'
                WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'UNKNOWN'
            END,
            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                        PARTITION BY cst_id
                        ORDER BY cst_create_date DESC
                   ) AS latestflag
            FROM bronze_layer.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE latestflag = 1;

        SET @step_end = SYSDATETIME();
        PRINT 'Completed crm_cust_info in '
            + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- crm_prd_info
    --------------------------------------------------
        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: silver_layer.crm_prd_info';

        TRUNCATE TABLE silver_layer.crm_prd_info;

        INSERT INTO silver_layer.crm_prd_info
        (
            prd_id,
            prd_key,
            cat_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            SUBSTRING(prd_key,7,LEN(prd_key)),
            REPLACE(SUBSTRING(prd_key,1,5),'-','_'),
            prd_nm,
            ISNULL(prd_cost,0),
            CASE TRIM(UPPER(prd_line))
                WHEN 'M' THEN 'MOUNTAIN'
                WHEN 'S' THEN 'OTHERSALES'
                WHEN 'R' THEN 'ROAD'
                WHEN 'T' THEN 'TOURING'
                ELSE 'UNKNOWN'
            END,
            prd_start_dt,
            DATEADD(
                DAY,-1,
                LEAD(prd_start_dt) OVER(
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt ASC
                )
            )
        FROM bronze_layer.crm_prd_info;

        SET @step_end = SYSDATETIME();
        PRINT 'Completed crm_prd_info in '
            + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- crm_sales_details
    --------------------------------------------------
        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: silver_layer.crm_sales_details';

        TRUNCATE TABLE silver_layer.crm_sales_details;

        INSERT INTO silver_layer.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE
                WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,

            CASE
                WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,

            CASE
                WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,

            CASE
                WHEN sls_sales IS NULL
                    OR sls_sales <= 0
                    OR sls_sales != ABS(sls_quantity * sls_price)
                THEN ABS(sls_quantity * sls_price)
                ELSE sls_sales
            END,

            sls_quantity,

            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                THEN ABS(sls_sales / NULLIF(sls_quantity,0))
                ELSE sls_price
            END
        FROM bronze_layer.crm_sales_details;

        SET @step_end = SYSDATETIME();
        PRINT 'Completed crm_sales_details in '
            + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- erp_CUST_AZ12
    --------------------------------------------------
        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: silver_layer.erp_CUST_AZ12';

        TRUNCATE TABLE silver_layer.erp_CUST_AZ12;

        INSERT INTO silver_layer.erp_CUST_AZ12
        (
            CID,
            GEN,
            BDATE
        )
        SELECT
            CASE
                WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
                ELSE CID
            END,
            CASE
                WHEN UPPER(TRIM(GEN)) IN ('MALE','M') THEN 'Male'
                WHEN UPPER(TRIM(GEN)) IN ('FEMALE','F') THEN 'Female'
                ELSE 'UNKNOWN'
            END,
            CASE
                WHEN BDATE > CAST(GETDATE() AS DATE) THEN NULL
                ELSE BDATE
            END
        FROM bronze_layer.erp_CUST_AZ12;

        SET @step_end = SYSDATETIME();
        PRINT 'Completed erp_CUST_AZ12 in '
            + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- erp_LOC_A101
    --------------------------------------------------
        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: silver_layer.erp_LOC_A101';

        TRUNCATE TABLE silver_layer.erp_LOC_A101;

        INSERT INTO silver_layer.erp_LOC_A101
        (
            CID,
            CNTRY
        )
        SELECT
            REPLACE(CID,'-',''),
            CASE
                WHEN UPPER(TRIM(CNTRY)) = '' OR CNTRY IS NULL THEN 'UNKNOWN'
                WHEN UPPER(TRIM(CNTRY)) IN ('US','USA','UNITED STATES') THEN 'United States'
                WHEN UPPER(TRIM(CNTRY)) IN ('DE','GERMANY') THEN 'Germany'
                ELSE CNTRY
            END
        FROM bronze_layer.erp_LOC_A101;

        SET @step_end = SYSDATETIME();
        PRINT 'Completed erp_LOC_A101 in '
            + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- erp_PX_CAT_G1V2
    --------------------------------------------------
        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: silver_layer.erp_PX_CAT_G1V2';

        TRUNCATE TABLE silver_layer.erp_PX_CAT_G1V2;

        INSERT INTO silver_layer.erp_PX_CAT_G1V2
        (
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
        )
        SELECT
            CASE
                WHEN ID LIKE '%PD' THEN REPLACE(ID,'PD','PE')
                ELSE ID
            END,
            TRIM(CAT),
            TRIM(SUBCAT),
            TRIM(MAINTENANCE)
        FROM bronze_layer.erp_PX_CAT_G1V2;

        SET @step_end = SYSDATETIME();
        PRINT 'Completed erp_PX_CAT_G1V2 in '
            + CAST(DATEDIFF(SECOND,@step_start,@step_end) AS VARCHAR) + ' sec';


    --------------------------------------------------
    -- Batch completed
    --------------------------------------------------
        SET @batch_end = SYSDATETIME();

        PRINT '==================================================';
        PRINT 'SILVER LAYER LOAD COMPLETED SUCCESSFULLY';
        PRINT 'END TIME: ' + CONVERT(VARCHAR(30), @batch_end, 120);
        PRINT 'TOTAL DURATION (seconds): '
            + CAST(DATEDIFF(SECOND,@batch_start,@batch_end) AS VARCHAR);
        PRINT '==================================================';

    END TRY

    BEGIN CATCH
        PRINT '==================================================';
        PRINT 'ERROR IN PROCEDURE: silver_layer.load_silver';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR TIME: ' + CONVERT(VARCHAR(30),SYSDATETIME(),120);
        PRINT '==================================================';

        THROW;
    END CATCH
END;
