-- pipeline_dimensional_data/queries/update_dim_DimSOR.sql

USE ORDER_DDS;
GO

-- Merge all new staging keys into Dim_SOR:
MERGE dbo.Dim_SOR AS target
USING (
    -- one row per staging record per table
    SELECT 'Staging_Categories'     AS TableName, CAST(staging_raw_id AS NVARCHAR(255)) AS SORKey FROM dbo.Staging_Categories
    UNION
    SELECT 'Staging_Customers'     , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_Customers
    UNION
    SELECT 'Staging_Employees'     , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_Employees
    UNION
    SELECT 'Staging_Products'      , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_Products
    UNION
    SELECT 'Staging_Region'        , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_Region
    UNION
    SELECT 'Staging_Shippers'      , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_Shippers
    UNION
    SELECT 'Staging_Suppliers'     , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_Suppliers
    UNION
    SELECT 'Staging_Territories'   , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_Territories
    UNION
    SELECT 'Staging_Orders'        , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_Orders
    UNION
    SELECT 'Staging_OrderDetails'  , CAST(staging_raw_id AS NVARCHAR(255)) FROM dbo.Staging_OrderDetails
) AS src
ON target.TableName = src.TableName
   AND target.SORKey     = src.SORKey
WHEN NOT MATCHED BY TARGET THEN
  INSERT (TableName, SORKey, LoadDate)
  VALUES (src.TableName, src.SORKey, SYSUTCDATETIME());
GO
