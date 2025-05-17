-- pipeline_dimensional_data/queries/update_fact_error.sql

:SETVAR start_date $(start_date)
:SETVAR end_date   $(end_date)
GO

USE ORDER_DDS;
GO

-- Capture any orders in the window that failed to join all dimensions
INSERT INTO dbo.fact_error (
    SORKey,
    TableName,
    ErrorDate,
    ErrorDescription,
    StagingRawID
)
SELECT
    sor.SOR_SK,
    'Staging_Orders',
    SYSUTCDATETIME(),
    CASE
      WHEN dc.CustomerSK      IS NULL THEN 'Missing Customer dimension'
      WHEN de.EmployeeSK      IS NULL THEN 'Missing Employee dimension'
      WHEN dp.ProductSK       IS NULL THEN 'Missing Product dimension'
      WHEN dcat.CategorySK    IS NULL THEN 'Missing Category dimension'
      WHEN dr.RegionSK        IS NULL THEN 'Missing Region dimension'
      WHEN ds.ShipperSK       IS NULL THEN 'Missing Shipper dimension'
      WHEN dsu.SupplierSK     IS NULL THEN 'Missing Supplier dimension'
      WHEN dt.TerritorySK     IS NULL THEN 'Missing Territory dimension'
      ELSE 'Unknown load error'
    END,
    so.staging_raw_id
FROM dbo.Staging_Orders       AS so
JOIN dbo.Staging_OrderDetails AS od
  ON so.OrderID = od.OrderID
JOIN dbo.Dim_SOR              AS sor
  ON sor.TableName = 'Staging_Orders'
 AND sor.SORKey    = CAST(so.staging_raw_id AS NVARCHAR(255))
LEFT JOIN dbo.DimCustomers    AS dc
  ON so.CustomerID = dc.CustomerID AND dc.IsCurrent = 1
LEFT JOIN dbo.DimEmployees    AS de
  ON so.EmployeeID = de.EmployeeID AND de.IsCurrent = 1
LEFT JOIN dbo.DimProducts     AS dp
  ON od.ProductID = dp.ProductID AND dp.IsCurrent = 1
LEFT JOIN dbo.DimCategories   AS dcat
  ON dp.CategoryID = dcat.CategoryID AND dcat.IsCurrent = 1
LEFT JOIN dbo.DimRegion       AS dr
  ON so.ShipRegion = dr.RegionDesc AND dr.IsCurrent = 1
LEFT JOIN dbo.DimShippers     AS ds
  ON so.ShipVia = ds.ShipperID AND ds.IsCurrent = 1
LEFT JOIN dbo.DimSuppliers    AS dsu
  ON dp.SupplierID = dsu.SupplierID AND dsu.IsCurrent = 1
LEFT JOIN dbo.DimTerritories  AS dt
  ON so.TerritoryID = dt.TerritoryID AND dt.IsCurrent = 1
WHERE so.OrderDate BETWEEN '$(start_date)' AND '$(end_date)'
  AND (
       dc.CustomerSK   IS NULL
    OR de.EmployeeSK   IS NULL
    OR dp.ProductSK    IS NULL
    OR dcat.CategorySK IS NULL
    OR dr.RegionSK     IS NULL
    OR ds.ShipperSK    IS NULL
    OR dsu.SupplierSK  IS NULL
    OR dt.TerritorySK  IS NULL
  );
GO
