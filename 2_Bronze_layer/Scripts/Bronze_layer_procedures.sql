CREATE OR ALTER PROCEDURE bronze_layer.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @batch_start DATETIME2 = SYSDATETIME();
    DECLARE @batch_end DATETIME2;
    DECLARE @step_start DATETIME2;
    DECLARE @step_end DATETIME2;

    PRINT '==================================================';
    PRINT 'PROCEDURE: bronze_layer.load_bronze';
    PRINT 'BRONZE LAYER LOAD STARTED';
    PRINT 'START TIME: ' + CONVERT(VARCHAR(30), @batch_start, 120);
    PRINT '==================================================';

    BEGIN TRY

        PRINT ' ';
        PRINT '========== LOADING CRM SOURCE ==========';

        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: bronze_layer.crm_cust_info';

        TRUNCATE TABLE bronze_layer.crm_cust_info;
        BULK INSERT bronze_layer.crm_cust_info
        FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @step_end = SYSDATETIME();
        PRINT 'Completed: bronze_layer.crm_cust_info | Duration (seconds): '
            + CAST(DATEDIFF(SECOND, @step_start, @step_end) AS VARCHAR);

        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: bronze_layer.crm_prd_info';

        TRUNCATE TABLE bronze_layer.crm_prd_info;
        BULK INSERT bronze_layer.crm_prd_info
        FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @step_end = SYSDATETIME();
        PRINT 'Completed: bronze_layer.crm_prd_info | Duration (seconds): '
            + CAST(DATEDIFF(SECOND, @step_start, @step_end) AS VARCHAR);

        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: bronze_layer.crm_sales_details';

        TRUNCATE TABLE bronze_layer.crm_sales_details;
        BULK INSERT bronze_layer.crm_sales_details
        FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @step_end = SYSDATETIME();
        PRINT 'Completed: bronze_layer.crm_sales_details | Duration (seconds): '
            + CAST(DATEDIFF(SECOND, @step_start, @step_end) AS VARCHAR);

        PRINT '========== CRM SOURCE LOADED ==========';

        PRINT ' ';
        PRINT '========== LOADING ERP SOURCE ==========';

        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: bronze_layer.erp_CUST_AZ12';

        TRUNCATE TABLE bronze_layer.erp_CUST_AZ12;
        BULK INSERT bronze_layer.erp_CUST_AZ12
        FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @step_end = SYSDATETIME();
        PRINT 'Completed: bronze_layer.erp_CUST_AZ12 | Duration (seconds): '
            + CAST(DATEDIFF(SECOND, @step_start, @step_end) AS VARCHAR);

        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: bronze_layer.erp_LOC_A101';

        TRUNCATE TABLE bronze_layer.erp_LOC_A101;
        BULK INSERT bronze_layer.erp_LOC_A101
        FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @step_end = SYSDATETIME();
        PRINT 'Completed: bronze_layer.erp_LOC_A101 | Duration (seconds): '
            + CAST(DATEDIFF(SECOND, @step_start, @step_end) AS VARCHAR);

        SET @step_start = SYSDATETIME();
        PRINT 'Loading table: bronze_layer.erp_PX_CAT_G1V2';

        TRUNCATE TABLE bronze_layer.erp_PX_CAT_G1V2;
        BULK INSERT bronze_layer.erp_PX_CAT_G1V2
        FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @step_end = SYSDATETIME();
        PRINT 'Completed: bronze_layer.erp_PX_CAT_G1V2 | Duration (seconds): '
            + CAST(DATEDIFF(SECOND, @step_start, @step_end) AS VARCHAR);

        PRINT '========== ERP SOURCE LOADED ==========';

        SET @batch_end = SYSDATETIME();

        PRINT ' ';
        PRINT '==================================================';
        PRINT 'BRONZE LAYER LOAD COMPLETED SUCCESSFULLY';
        PRINT 'END TIME: ' + CONVERT(VARCHAR(30), @batch_end, 120);
        PRINT 'TOTAL BATCH DURATION (seconds): '
            + CAST(DATEDIFF(SECOND, @batch_start, @batch_end) AS VARCHAR);
        PRINT '==================================================';

    END TRY
    BEGIN CATCH
        PRINT ' ';
        PRINT '==================================================';
        PRINT 'ERROR IN PROCEDURE: bronze_layer.load_bronze';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT 'ERROR TIME: ' + CONVERT(VARCHAR(30), SYSDATETIME(), 120);
        PRINT 'TOTAL ELAPSED TIME BEFORE FAILURE (seconds): '
            + CAST(DATEDIFF(SECOND, @batch_start, SYSDATETIME()) AS VARCHAR);
        PRINT '==================================================';

        THROW;
    END CATCH
END;
GO
