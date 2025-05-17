-- Parameters
DECLARE @DatabaseName NVARCHAR(128) = 'YourDatabaseName'; -- Provide the database name
DECLARE @SchemaName NVARCHAR(128) = 'dbo';                -- Provide the schema name
DECLARE @StartDate DATE = '2023-01-01';                    -- Start date for filtering
DECLARE @EndDate DATE = '2023-12-31';                      -- End date for filtering
DECLARE @TableName NVARCHAR(128) = 'FactOrders';           -- Fact table name
DECLARE @ErrorReason NVARCHAR(500) = 'Missing/Invalid Key'; -- Default error reason for invalid keys

DECLARE @SQL NVARCHAR(MAX);

-- Build the dynamic SQL query to ingest faulty rows into FactOrders_Error
SET @SQL = N'
INSERT INTO ' + QUOTENAME(@SchemaName) + '.FactOrders_Error (
    OrderID,
    CustomerID,
    EmployeeID,
    ProductID,
    ShipperID,
    TerritoryID,
    OrderDate,
    RequiredDate,
    ShippedDate,
    Freight,
    Quantity,
    UnitPrice,
    Discount,
    TotalAmount,
    staging_raw_id,
    SORKey,
    ErrorReason
)
SELECT 
    s.OrderID,
    dc.CustomerID,
    de.EmployeeID,
    dp.ProductID,
    dv.ShipperID,
    dt.TerritoryID,
    s.OrderDate,
    s.RequiredDate,
    s.ShippedDate,
    s.Freight,
    od.Quantity,
    od.UnitPrice,
    od.Discount,
    (od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalAmount,  -- Calculating TotalAmount
    od.staging_raw_id, -- Staging raw ID from the Staging_OrderDetails table
    ds.SORKey,  -- Surrogate key from the Dim_SOR table
    @ErrorReason AS ErrorReason -- Default error reason for missing or invalid keys
FROM ' + QUOTENAME(@SchemaName) + '.Staging_Orders s
LEFT JOIN ' + QUOTENAME(@SchemaName) + '.Staging_OrderDetails od ON od.OrderID = s.OrderID  -- Proper join condition between Staging_Orders and Staging_OrderDetails
LEFT JOIN ' + QUOTENAME(@SchemaName) + '.DimCustomers dc ON dc.CustomerID = s.CustomerID
LEFT JOIN ' + QUOTENAME(@SchemaName) + '.DimEmployees de ON de.EmployeeID = s.EmployeeID
LEFT JOIN ' + QUOTENAME(@SchemaName) + '.DimProducts dp ON dp.ProductID = od.ProductID  -- Corrected reference to Staging_OrderDetails (od)
LEFT JOIN ' + QUOTENAME(@SchemaName) + '.DimShippers dv ON dv.ShipperID = s.ShipVia
LEFT JOIN ' + QUOTENAME(@SchemaName) + '.DimTerritories dt ON dt.TerritoryID = s.TerritoryID
LEFT JOIN ' + QUOTENAME(@SchemaName) + '.Dim_SOR ds ON ds.StagingTableName = ''Staging_OrderDetails'' 
    AND ds.TablePrimaryKeyColumn = CAST(od.staging_raw_id AS NVARCHAR)  -- Corrected reference to Staging_OrderDetails (od)
WHERE 
    (dc.CustomerID IS NULL OR de.EmployeeID IS NULL OR dp.ProductID IS NULL OR dv.ShipperID IS NULL OR dt.TerritoryID IS NULL) 
    AND s.OrderDate BETWEEN @StartDate AND @EndDate;
';

-- Execute the dynamic SQL query
EXEC sp_executesql @SQL, N'@StartDate DATE, @EndDate DATE, @ErrorReason NVARCHAR(500)', @StartDate, @EndDate, @ErrorReason;
