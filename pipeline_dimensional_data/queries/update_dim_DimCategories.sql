MERGE dbo.DimCategories AS target
USING dbo.Staging_Categories AS source
ON target.CategoryID = source.CategoryID
WHEN MATCHED THEN
    UPDATE SET 
        CategoryName = source.CategoryName,
        Description = source.Description
WHEN NOT MATCHED BY TARGET THEN
    INSERT (SORKey, CategoryID, CategoryName, Description)
    VALUES (1, source.CategoryID, source.CategoryName, source.Description);
