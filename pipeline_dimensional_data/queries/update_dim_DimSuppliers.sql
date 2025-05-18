USE ORDER_DDS;
GO

-- 1) Expire old records when any field changes
UPDATE ds
SET 
  ds.ExpirationDate = SYSUTCDATETIME(),
  ds.IsCurrent      = 0
FROM dbo.DimSuppliers    AS ds
JOIN dbo.Staging_Suppliers AS ss
  ON ds.SupplierID = ss.SupplierID
WHERE ds.IsCurrent = 1
  AND (
     ds.CompanyName     <> ss.CompanyName
  OR ds.ContactName     <> ss.ContactName
  OR ds.ContactTitle    <> ss.ContactTitle
  OR ds.Address         <> ss.Address
  OR ds.City            <> ss.City
  OR ds.Region          <> ss.Region
  OR ds.PostalCode      <> ss.PostalCode
  OR ds.Country         <> ss.Country
  OR ds.Phone           <> ss.Phone
  OR ds.Fax             <> ss.Fax
  OR ds.HomePage        <> ss.HomePage
);

-- 2) Insert new versions
INSERT INTO dbo.DimSuppliers (
    SORKey,
    SupplierID,
    CompanyName,
    ContactName,
    ContactTitle,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    Phone,
    Fax,
    HomePage,
    EffectiveDate,
    ExpirationDate,
    IsCurrent
)
SELECT
    1,
    ss.SupplierID,
    ss.CompanyName,
    ss.ContactName,
    ss.ContactTitle,
    ss.Address,
    ss.City,
    ss.Region,
    ss.PostalCode,
    ss.Country,
    ss.Phone,
    ss.Fax,
    ss.HomePage,
    SYSUTCDATETIME(),
    NULL,
    1
FROM dbo.Staging_Suppliers AS ss
WHERE NOT EXISTS (
    SELECT 1 
      FROM dbo.DimSuppliers ds2
     WHERE ds2.SupplierID   = ss.SupplierID
       AND ds2.IsCurrent    = 1
       AND ds2.CompanyName  = ss.CompanyName
       AND ds2.ContactName  = ss.ContactName
       AND ds2.ContactTitle = ss.ContactTitle
       AND ds2.Address      = ss.Address
       AND ds2.City         = ss.City
       AND ds2.Region       = ss.Region
       AND ds2.PostalCode   = ss.PostalCode
       AND ds2.Country      = ss.Country
       AND ds2.Phone        = ss.Phone
       AND ds2.Fax          = ss.Fax
       AND ds2.HomePage     = ss.HomePage
);
GO
