--------------database creation step---------------


--PURPOSE : -Create the data base in which where the data base will be stored and schemas
--            for the 'Medallion architecture'

--This file Checks if the data base exists if yes; it is going to Log out all other users and rollback all their actions
--     before creating the database and schemas

--RESULTS : -DB: "Data_warehouse"
--            Schemas: "bronze_layer" , "silver_layer", "gold_layer"

-----------------Script----------------------------
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
------------End of Script---------------------
