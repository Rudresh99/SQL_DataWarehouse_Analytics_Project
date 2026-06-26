/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

/*The following script is for SQL Server*/
USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

/* This is for MYSQL Workbench */
  
/*
=============================================================
Create Bronze, Silver and Gold Databases
=============================================================
Script Purpose:
    This script recreates the Bronze, Silver and Gold databases.
    If they already exist, they are dropped and recreated.

WARNING:
    Running this script will permanently delete all data stored
    in the Bronze, Silver and Gold databases.
=============================================================
*/

-- Drop existing databases
DROP DATABASE IF EXISTS bronze;
DROP DATABASE IF EXISTS silver;
DROP DATABASE IF EXISTS gold;

-- Create databases
CREATE DATABASE bronze;
CREATE DATABASE silver;
CREATE DATABASE gold;

