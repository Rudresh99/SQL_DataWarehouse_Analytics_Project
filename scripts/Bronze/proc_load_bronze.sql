/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL load_Bronze();
===============================================================================
*/

DELIMITER //

DROP PROCEDURE IF EXISTS load_Bronze //

CREATE PROCEDURE load_Bronze()
BEGIN

    -------------------------------------------------------------------
    -- Variable Declaration
    -------------------------------------------------------------------
    DECLARE v_batch_start DATETIME;
    DECLARE v_batch_end DATETIME;
    DECLARE v_table_start DATETIME;
    DECLARE v_table_end DATETIME;

    -------------------------------------------------------------------
    -- Error Handler (Equivalent of TRY...CATCH)
    -------------------------------------------------------------------
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @message = MESSAGE_TEXT;

        SELECT
            'ERROR OCCURRED DURING BRONZE LOAD' AS Status,
            @errno AS Error_Code,
            @sqlstate AS SQL_State,
            @message AS Error_Message;

        ROLLBACK;
    END;

    -- -----------------------------------------------------------------
    -- Batch Start
    -- -----------------------------------------------------------------
    SET v_batch_start = NOW();

    SELECT '=========================================' AS Message;
    SELECT 'Starting Bronze Layer Load...' AS Message;
    SELECT CONCAT('Batch Started At : ', v_batch_start) AS Message;
    SELECT '=========================================' AS Message;

    START TRANSACTION;

    -- -----------------------------------------------------------------
    -- CRM Customer Information
    -- -----------------------------------------------------------------
    SET v_table_start = NOW();

    TRUNCATE TABLE crm_cust_info;

    LOAD DATA LOCAL INFILE '/Users/rudresh/Data_Warehouse_Project-SQL/datasets/source_crm/cust_info.csv'
    INTO TABLE crm_cust_info
    CHARACTER SET utf8mb4
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;

    SET v_table_end = NOW();

    SELECT CONCAT(
        'crm_cust_info Loaded Successfully in ',
        TIMESTAMPDIFF(MICROSECOND,v_table_start,v_table_end)/1000000,
        ' Seconds'
    ) AS Status;

    -- -----------------------------------------------------------------
    -- CRM Product Information
    -- -----------------------------------------------------------------
    SET v_table_start = NOW();

    TRUNCATE TABLE crm_prd_info;

    LOAD DATA LOCAL INFILE '/Users/rudresh/Data_Warehouse_Project-SQL/datasets/source_crm/prd_info.csv'
    INTO TABLE crm_prd_info
    CHARACTER SET utf8mb4
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;

    SET v_table_end = NOW();

    SELECT CONCAT(
        'crm_prd_info Loaded Successfully in ',
        TIMESTAMPDIFF(MICROSECOND,v_table_start,v_table_end)/1000000,
        ' Seconds'
    ) AS Status;

    -- -----------------------------------------------------------------
    -- CRM Sales Details
    -- -----------------------------------------------------------------
    SET v_table_start = NOW();

    TRUNCATE TABLE crm_sales_details;

    LOAD DATA LOCAL INFILE '/Users/rudresh/Data_Warehouse_Project-SQL/datasets/source_crm/sales_details.csv'
    INTO TABLE crm_sales_details
    CHARACTER SET utf8mb4
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;

    SET v_table_end = NOW();

    SELECT CONCAT(
        'crm_sales_details Loaded Successfully in ',
        TIMESTAMPDIFF(MICROSECOND,v_table_start,v_table_end)/1000000,
        ' Seconds'
    ) AS Status;

    -- -----------------------------------------------------------------
    -- ERP Customer
    -- -----------------------------------------------------------------
    SET v_table_start = NOW();

    TRUNCATE TABLE erp_cust_az12;

    LOAD DATA LOCAL INFILE '/Users/rudresh/Data_Warehouse_Project-SQL/datasets/source_erp/CUST_AZ12.csv'
    INTO TABLE erp_cust_az12
    CHARACTER SET utf8mb4
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

    SET v_table_end = NOW();

    SELECT CONCAT(
        'erp_cust_az12 Loaded Successfully in ',
        TIMESTAMPDIFF(MICROSECOND,v_table_start,v_table_end)/1000000,
        ' Seconds'
    ) AS Status;

    -- -----------------------------------------------------------------
    -- ERP Location
    -- -----------------------------------------------------------------
    SET v_table_start = NOW();

    TRUNCATE TABLE erp_loc_a101;

    LOAD DATA LOCAL INFILE '/Users/rudresh/Data_Warehouse_Project-SQL/datasets/source_erp/LOC_A101.csv'
    INTO TABLE erp_loc_a101
    CHARACTER SET utf8mb4
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

    SET v_table_end = NOW();

    SELECT CONCAT(
        'erp_loc_a101 Loaded Successfully in ',
        TIMESTAMPDIFF(MICROSECOND,v_table_start,v_table_end)/1000000,
        ' Seconds'
    ) AS Status;

    -- -----------------------------------------------------------------
    -- ERP Product Category
    -- -----------------------------------------------------------------
    SET v_table_start = NOW();

    TRUNCATE TABLE erp_px_cat_g1v2;

    LOAD DATA LOCAL INFILE '/Users/rudresh/Data_Warehouse_Project-SQL/datasets/source_erp/PX_CAT_G1V2.csv'
    INTO TABLE erp_px_cat_g1v2
    CHARACTER SET utf8mb4
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS;

    SET v_table_end = NOW();

    SELECT CONCAT(
        'erp_px_cat_g1v2 Loaded Successfully in ',
        TIMESTAMPDIFF(MICROSECOND,v_table_start,v_table_end)/1000000,
        ' Seconds'
    ) AS Status;

    -- -----------------------------------------------------------------
    -- Batch End
    -- -----------------------------------------------------------------
    COMMIT;

    SET v_batch_end = NOW();

    SELECT '=========================================' AS Message;

    SELECT CONCAT(
        'Bronze Layer Loaded Successfully in ',
        TIMESTAMPDIFF(SECOND,v_batch_start,v_batch_end),
        ' Seconds'
    ) AS Status;

    SELECT CONCAT('Batch Completed At : ', v_batch_end) AS Message;

    SELECT '=========================================' AS Message;

END //

DELIMITER ;
