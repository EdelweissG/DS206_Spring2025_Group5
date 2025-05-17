USE ORDER_DDS;
GO

-- Then run your SCD2 update/insert
-- 1. Expire old records
UPDATE dbo.DimCustomers
SET ExpirationDate = GETDATE(), IsCurrent = 0
FROM dbo.DimCustomers dc
JOIN dbo.Staging_Customers sc ON dc.CustomerID = sc.CustomerID
WHERE dc.IsCurrent = 1 AND (
    dc.CompanyName <> sc.CompanyName OR
    dc.ContactName <> sc.ContactName OR
    dc.ContactTitle <> sc.ContactTitle OR
    dc.Address <> sc.Address OR
    dc.City <> sc.City OR
    dc.Region <> sc.Region OR
    dc.PostalCode <> sc.PostalCode OR
    dc.Country <> sc.Country OR
    dc.Phone <> sc.Phone OR
    dc.Fax <> sc.Fax
);

-- 2. Insert new versions
INSERT INTO dbo.DimCustomers (
    SORKey, CustomerID, CompanyName, ContactName, ContactTitle,
    Address, City, Region, PostalCode, Country,
    Phone, Fax, EffectiveDate, ExpirationDate, IsCurrent
)
SELECT 
    1, CustomerID, CompanyName, ContactName, ContactTitle,
    Address, City, Region, PostalCode, Country,
    Phone, Fax, GETDATE(), NULL, 1
FROM dbo.Staging_Customers AS sc
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DimCustomers dc
    WHERE dc.CustomerID = sc.CustomerID AND dc.IsCurrent = 1 AND
          dc.CompanyName = sc.CompanyName AND
          dc.ContactName = sc.ContactName AND
          dc.ContactTitle = sc.ContactTitle AND
          dc.Address = sc.Address AND
          dc.City = sc.City AND
          dc.Region = sc.Region AND
          dc.PostalCode = sc.PostalCode AND
          dc.Country = sc.Country AND
          dc.Phone = sc.Phone AND
          dc.Fax = sc.Fax
);
