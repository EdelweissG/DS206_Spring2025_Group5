USE ORDER_DDS;
GO

-- 1) Expire old records when the region description changes
UPDATE dr
SET 
    dr.ExpirationDate = SYSUTCDATETIME(),
    dr.IsCurrent      = 0
FROM dbo.DimRegion    AS dr
JOIN dbo.Staging_Region AS sr
  ON dr.RegionID = sr.RegionID
WHERE dr.IsCurrent = 1
  AND dr.RegionDesc <> sr.RegionDescription;
GO

-- 2) Insert new versions for any changed or new regions
INSERT INTO dbo.DimRegion (
    SORKey,
    RegionID,
    RegionDesc,
    EffectiveDate,
    ExpirationDate,
    IsCurrent
)
SELECT
    1,                       -- temporary SORKey; replace with real lookup if needed
    sr.RegionID,
    sr.RegionDescription,
    SYSUTCDATETIME(),        -- EffectiveDate
    NULL,                    -- ExpirationDate
    1                        -- IsCurrent
FROM dbo.Staging_Region AS sr
WHERE NOT EXISTS (
    SELECT 1
      FROM dbo.DimRegion dr2
     WHERE dr2.RegionID   = sr.RegionID
       AND dr2.IsCurrent  = 1
       AND dr2.RegionDesc = sr.RegionDescription
);
GO
