--------CHECKING VALUES CONSISTENCY----
SELECT DISTINCT  CID
FROM silver_layer.erp_CUST_AZ12


-------------NO NULLS------
SELECT * FROM silver_layer.erp_CUST_AZ12
WHERE CID IS NULL



---------DUPLICATES CHECK-----

SELECT CID, COUNT(*) FROM silver_layer.erp_CUST_AZ12
GROUP BY CID
HAVING COUNT(*) > 1

--------CHECKING WHITE SPACES------
SELECT * FROM silver_layer.erp_CUST_AZ12
WHERE CID != TRIM(CID)


-----------CHECKING COST/PRICE ERRORS---------

SELECT * FROM silver_layer.crm_sales_details
WHERE sls_sales <= 0 OR sls_sales IS NULL  
      OR sls_quantity <= 0 OR sls_quantity IS NULL
      OR sls_price <= 0 OR sls_price IS NULL


-------------CHECKING IDS AND KEYS RELATIONSHIPS--------
SELECT * FROM silver_layer.erp_CUST_AZ12
WHERE CID NOT IN ( SELECT cst_key FROM silver_layer.crm_cust_info)

-------------DATES QUALITY----------------------------
SELECT sls_ship_dt FROM silver_layer.crm_sales_details
ORDER BY sls_ship_dt DESC 

SELECT sls_ship_dt FROM silver_layer.crm_sales_details
ORDER BY sls_ship_dt ASC 

---OVERLAPPING BETWEEN DATES---
SELECT * FROM silver_layer.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt
