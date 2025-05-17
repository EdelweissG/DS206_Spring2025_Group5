USE ORDER_DDS;
GO

-- 1) Soft‐expire old records on EmployeeID mismatch
UPDATE dbo.DimEmployees
SET
  ExpirationDate = SYSUTCDATETIME(),
  IsCurrent      = 0
WHERE EmployeeID NOT IN (
    SELECT EmployeeID
      FROM dbo.Staging_Employees
)
AND IsCurrent = 1;
GO

-- 2) SCD2‐style Merge into DimEmployees
MERGE dbo.DimEmployees AS target
USING dbo.Staging_Employees AS source
  ON target.EmployeeID = source.EmployeeID
WHEN MATCHED 
  AND target.IsCurrent = 1
  AND (
       target.LastName    <> source.LastName
    OR target.FirstName   <> source.FirstName
    OR target.Title       <> source.Title
    OR target.BirthDate   <> source.BirthDate
    OR target.HireDate    <> source.HireDate
    OR target.Address     <> source.Address
    OR target.City        <> source.City
    OR target.Region      <> source.Region
    OR target.PostalCode  <> source.PostalCode
    OR target.Country     <> source.Country
    OR target.HomePhone   <> source.HomePhone
    OR target.Extension   <> source.Extension
    OR target.Notes       <> source.Notes
    OR target.ReportsTo   <> source.ReportsTo
  )
THEN
  -- expire the old current row
  UPDATE SET
    ExpirationDate = SYSUTCDATETIME(),
    IsCurrent      = 0

WHEN NOT MATCHED BY TARGET THEN
  -- insert brand-new row
  INSERT (
    SORKey,
    EmployeeID,
    LastName,
    FirstName,
    Title,
    BirthDate,
    HireDate,
    Address,
    City,
    Region,
    PostalCode,
    Country,
    HomePhone,
    Extension,
    Notes,
    ReportsTo,
    EffectiveDate,
    ExpirationDate,
    IsCurrent
  )
  VALUES (
    1,                  -- SOR placeholder
    source.EmployeeID,
    source.LastName,
    source.FirstName,
    source.Title,
    source.BirthDate,
    source.HireDate,
    source.Address,
    source.City,
    source.Region,
    source.PostalCode,
    source.Country,
    source.HomePhone,
    source.Extension,
    source.Notes,
    source.ReportsTo,
    SYSUTCDATETIME(),
    NULL,
    1
  );
GO
