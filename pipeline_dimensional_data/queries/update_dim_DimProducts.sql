USE ORDER_DDS;
GO

MERGE dbo.DimProducts AS target
USING dbo.Staging_Products AS source
ON target.ProductID = source.ProductID
WHEN MATCHED THEN
    UPDATE SET 
        ProductName = source.ProductName,
        SupplierID = source.SupplierID,
        CategoryID = source.CategoryID,
        QuantityPerUnit = source.QuantityPerUnit,
        UnitPrice = source.UnitPrice,
        UnitsInStock = source.UnitsInStock,
        UnitsOnOrder = source.UnitsOnOrder,
        ReorderLevel = source.ReorderLevel,
        Discontinued = source.Discontinued
WHEN NOT MATCHED BY TARGET THEN
    INSERT (SORKey, ProductID, ProductName, SupplierID, CategoryID,
            QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder,
            ReorderLevel, Discontinued)
    VALUES (1, source.ProductID, source.ProductName, source.SupplierID, source.CategoryID,
            source.QuantityPerUnit, source.UnitPrice, source.UnitsInStock, source.UnitsOnOrder,
            source.ReorderLevel, source.Discontinued);
