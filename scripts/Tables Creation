
IF OBJECT_ID('bronze_layer.crm_cust_info','U') IS NOT NULL
 DROP TABLE bronze_layer.crm_cust_info;
GO
CREATE TABLE bronze_layer.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);



IF OBJECT_ID('bronze_layer.crm_prd_info','U') IS NOT NULL
 DROP TABLE bronze_layer.crm_prd_info;
GO
CREATE TABLE bronze_layer.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);


IF OBJECT_ID('bronze_layer.crm_sales_details','U') IS NOT NULL
 DROP TABLE bronze_layer.crm_sales_details;
GO
CREATE TABLE bronze_layer.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT ,
    sls_quantity INT,
    sls_price INT
);



IF OBJECT_ID('bronze_layer.erp_PX_CAT_G1V2','U') IS NOT NULL
 DROP TABLE bronze_layer.erp_PX_CAT_G1V2;
GO

CREATE TABLE bronze_layer.erp_PX_CAT_G1V2(
ID	VARCHAR (50),
CAT	VARCHAR (50),
SUBCAT	VARCHAR (50),
MAINTENANCE VARCHAR (50),);






IF OBJECT_ID('bronze_layer.erp_LOC_A101','U') IS NOT NULL
 DROP TABLE bronze_layer.erp_LOC_A101;
GO
CREATE TABLE bronze_layer.erp_LOC_A101(
CID	VARCHAR (50),
CNTRY VARCHAR (50),);







IF OBJECT_ID('bronze_layer.erp_CUST_AZ12','U') IS NOT NULL
 DROP TABLE bronze_layer.erp_CUST_AZ12;
GO
CREATE TABLE bronze_layer.erp_CUST_AZ12 (
CID	VARCHAR (50),
BDATE DATE,
GEN VARCHAR (50),);



----------
TRUNCATE  TABLE bronze_layer.crm_cust_info;
BULK INSERT bronze_layer.crm_cust_info 
FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH ( FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR= '\n',
TABLOCK 
);


TRUNCATE  TABLE bronze_layer.crm_prd_info;
BULK INSERT bronze_layer.crm_prd_info 
FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH ( FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR= '\n',
TABLOCK 
);


TRUNCATE  TABLE bronze_layer.crm_sales_details;
BULK INSERT bronze_layer.crm_sales_details
FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
WITH ( FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR= '\n',
TABLOCK 
);
----------



TRUNCATE  TABLE bronze_layer.erp_CUST_AZ12;
BULK INSERT bronze_layer.erp_CUST_AZ12 
FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
WITH ( FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR= '\n',
TABLOCK 
);


TRUNCATE  TABLE bronze_layer.erp_LOC_A101;
BULK INSERT bronze_layer.erp_LOC_A101
FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
WITH ( FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR= '\n',
TABLOCK 
);



TRUNCATE  TABLE bronze_layer.erp_PX_CAT_G1V2;
BULK INSERT bronze_layer.erp_PX_CAT_G1V2 
FROM 'D:\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH ( FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR= '\n',
TABLOCK 
);



-----(TRUNCATE TABLE bronze_layer.crm_cust_info GO BULK INSERT....)-------
----------is for full load and TO FIX DUPLICATED INSERT --------

-------CHECKING IF DDL PROCESS DONE CORRECLTY---------

SELECT *
  FROM [Data_warehouse].[bronze_layer].[crm_cust_info]

SELECT *
  FROM [Data_warehouse].[bronze_layer].[crm_prd_info]


SELECT *
  FROM [Data_warehouse].[bronze_layer].[crm_sales_details]


SELECT *
  FROM [Data_warehouse].[bronze_layer].[erp_LOC_A101]


SELECT *
  FROM [Data_warehouse].[bronze_layer].[erp_PX_CAT_G1V2]


SELECT *
  FROM [Data_warehouse].[bronze_layer].[erp_CUST_AZ12]
