
INSERT INTO dbo.HistoricalTerritories (TerritoryID, TerritoryDescription, RegionID, EffectiveDate)
SELECT d.TerritoryID, s.TerritoryDescription, s.RegionID, GETDATE()
FROM dbo.Staging_Territories s
JOIN dbo.DimTerritories d ON s.TerritoryID = d.TerritoryID
WHERE s.TerritoryDescription <> d.TerritoryDescription;

-- Update main
MERGE dbo.DimTerritories AS target
USING dbo.Staging_Territories AS source
ON target.TerritoryID = source.TerritoryID
WHEN MATCHED THEN
    UPDATE SET 
        TerritoryDescription = source.TerritoryDescription,
        RegionID = source.RegionID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (SORKey, TerritoryID, TerritoryDescription, RegionID)
    VALUES (1, source.TerritoryID, source.TerritoryDescription, source.RegionID);
