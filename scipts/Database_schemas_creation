IF DB_ID('Data_warehouse') IS NOT NULL
BEGIN
    ALTER DATABASE Data_Warehouse 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE Data_Warehouse;
END;

GO 

create database Data_warehouse

GO 

create schema bronze_layer
go
create schema silver_layer
go
create schema gold_layer
