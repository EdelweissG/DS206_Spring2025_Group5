USE ORDER_DDS;
GO

-- 1) Expire old records when data changes
UPDATE ds
SET 
  ds.ExpirationDate = SYSUTCDATETIME(),
  ds.IsCurrent      = 0
FROM dbo.DimShippers    AS ds
JOIN dbo.Staging_Shippers AS ss
  ON ds.ShipperID = ss.ShipperID
WHERE ds.IsCurrent = 1
  AND (
     ds.CompanyName <> ss.CompanyName
  OR ds.Phone       <> ss.Phone
);

-- 2) Insert new versions
INSERT INTO dbo.DimShippers (
    SORKey,
    ShipperID,
    CompanyName,
    Phone,
    EffectiveDate,
    ExpirationDate,
    IsCurrent
)
SELECT
    1,
    ss.ShipperID,
    ss.CompanyName,
    ss.Phone,
    SYSUTCDATETIME(),
    NULL,
    1
FROM dbo.Staging_Shippers AS ss
WHERE NOT EXISTS (
    SELECT 1 
      FROM dbo.DimShippers ds2
     WHERE ds2.ShipperID    = ss.ShipperID
       AND ds2.IsCurrent    = 1
       AND ds2.CompanyName  = ss.CompanyName
       AND ds2.Phone        = ss.Phone
);
GO
