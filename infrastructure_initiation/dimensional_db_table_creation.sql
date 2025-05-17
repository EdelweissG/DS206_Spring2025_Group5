-- infrastructure_initiation/dimensional_db_table_creation.sql

-- 1. Required SET options for indexed objects
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- 2. Switch to your DDS
USE ORDER_DDS;
GO

-- 3. SCD Store‐of‐Record table (Dim_SOR)
IF OBJECT_ID('dbo.Dim_SOR','U') IS NOT NULL
    DROP TABLE dbo.Dim_SOR;
CREATE TABLE dbo.Dim_SOR (
    SOR_SK      INT           IDENTITY(1,1) PRIMARY KEY,
    TableName   NVARCHAR(128) NOT NULL,
    SORKey      NVARCHAR(255) NOT NULL,      -- renamed from SourceKey
    LoadDate    DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpireDate  DATETIME2
);
GO

-- 4. Dimension: Customers
IF OBJECT_ID('dbo.DimCustomers','U') IS NOT NULL
    DROP TABLE dbo.DimCustomers;
CREATE TABLE dbo.DimCustomers (
    CustomerSK     INT           IDENTITY(1,1) PRIMARY KEY,
    SORKey         INT           NOT NULL REFERENCES dbo.Dim_SOR(SOR_SK),
    CustomerID     NVARCHAR(5)   NOT NULL,
    CompanyName    NVARCHAR(255),
    ContactName    NVARCHAR(255),
    ContactTitle   NVARCHAR(255),
    Address        NVARCHAR(255),
    City           NVARCHAR(255),
    Region         NVARCHAR(255),
    PostalCode     NVARCHAR(20),
    Country        NVARCHAR(255),
    Phone          NVARCHAR(50),
    Fax            NVARCHAR(50),
    EffectiveDate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpirationDate DATETIME2,
    IsCurrent      BIT           NOT NULL DEFAULT 1
);
GO

-- 5. Dimension: Employees
IF OBJECT_ID('dbo.DimEmployees','U') IS NOT NULL
    DROP TABLE dbo.DimEmployees;
CREATE TABLE dbo.DimEmployees (
    EmployeeSK     INT           IDENTITY(1,1) PRIMARY KEY,
    SORKey         INT           NOT NULL REFERENCES dbo.Dim_SOR(SOR_SK),
    EmployeeID     INT           NOT NULL,
    LastName       NVARCHAR(255),
    FirstName      NVARCHAR(255),
    Title          NVARCHAR(255),
    TitleCourtesy  NVARCHAR(255),
    BirthDate      DATETIME2,
    HireDate       DATETIME2,
    Address        NVARCHAR(255),
    City           NVARCHAR(255),
    Region         NVARCHAR(255),
    PostalCode     NVARCHAR(20),
    Country        NVARCHAR(255),
    HomePhone      NVARCHAR(50),
    Extension      NVARCHAR(10),
    Notes          NVARCHAR(MAX),
    ReportsTo      INT,
    EffectiveDate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpirationDate DATETIME2,
    IsCurrent      BIT           NOT NULL DEFAULT 1
);
GO

-- 6. Dimension: Products
IF OBJECT_ID('dbo.DimProducts','U') IS NOT NULL
    DROP TABLE dbo.DimProducts;
CREATE TABLE dbo.DimProducts (
    ProductSK        INT           IDENTITY(1,1) PRIMARY KEY,
    SORKey           INT           NOT NULL REFERENCES dbo.Dim_SOR(SOR_SK),
    ProductID        INT           NOT NULL,
    ProductName      NVARCHAR(255),
    SupplierID       INT,
    CategoryID       INT,
    QuantityPerUnit  NVARCHAR(255),
    UnitPrice        DECIMAL(10,2),
    UnitsInStock     SMALLINT,
    UnitsOnOrder     SMALLINT,
    ReorderLevel     SMALLINT,
    Discontinued     BIT,
    EffectiveDate    DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpirationDate   DATETIME2,
    IsCurrent        BIT           NOT NULL DEFAULT 1
);
GO

-- 7. Dimension: Categories
IF OBJECT_ID('dbo.DimCategories','U') IS NOT NULL
    DROP TABLE dbo.DimCategories;
CREATE TABLE dbo.DimCategories (
    CategorySK     INT           IDENTITY(1,1) PRIMARY KEY,
    SORKey         INT           NOT NULL REFERENCES dbo.Dim_SOR(SOR_SK),
    CategoryID     INT           NOT NULL,
    CategoryName   NVARCHAR(255),
    Description    NVARCHAR(MAX),
    EffectiveDate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpirationDate DATETIME2,
    IsCurrent      BIT           NOT NULL DEFAULT 1
);
GO

-- 8. Dimension: Region
IF OBJECT_ID('dbo.DimRegion','U') IS NOT NULL
    DROP TABLE dbo.DimRegion;
CREATE TABLE dbo.DimRegion (
    RegionSK       INT           IDENTITY(1,1) PRIMARY KEY,
    SORKey         INT           NOT NULL REFERENCES dbo.Dim_SOR(SOR_SK),
    RegionID       INT           NOT NULL,
    RegionDesc     NVARCHAR(255),
    EffectiveDate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpirationDate DATETIME2,
    IsCurrent      BIT           NOT NULL DEFAULT 1
);
GO

-- 9. Dimension: Shippers
IF OBJECT_ID('dbo.DimShippers','U') IS NOT NULL
    DROP TABLE dbo.DimShippers;
CREATE TABLE dbo.DimShippers (
    ShipperSK      INT           IDENTITY(1,1) PRIMARY KEY,
    SORKey         INT           NOT NULL REFERENCES dbo.Dim_SOR(SOR_SK),
    ShipperID      INT           NOT NULL,
    CompanyName    NVARCHAR(255),
    Phone          NVARCHAR(50),
    EffectiveDate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpirationDate DATETIME2,
    IsCurrent      BIT           NOT NULL DEFAULT 1
);
GO

-- 10. Dimension: Suppliers
IF OBJECT_ID('dbo.DimSuppliers','U') IS NOT NULL
    DROP TABLE dbo.DimSuppliers;
CREATE TABLE dbo.DimSuppliers (
    SupplierSK     INT           IDENTITY(1,1) PRIMARY KEY,
    SORKey         INT           NOT NULL REFERENCES dbo.Dim_SOR(SOR_SK),
    SupplierID     INT           NOT NULL,
    CompanyName    NVARCHAR(255),
    ContactName    NVARCHAR(255),
    ContactTitle   NVARCHAR(255),
    Address        NVARCHAR(255),
    City           NVARCHAR(255),
    Region         NVARCHAR(255),
    PostalCode     NVARCHAR(20),
    Country        NVARCHAR(255),
    Phone          NVARCHAR(50),
    Fax            NVARCHAR(50),
    HomePage       NVARCHAR(MAX),
    EffectiveDate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpirationDate DATETIME2,
    IsCurrent      BIT           NOT NULL DEFAULT 1
);
GO

-- 11. Dimension: Territories
IF OBJECT_ID('dbo.DimTerritories','U') IS NOT NULL
    DROP TABLE dbo.DimTerritories;
CREATE TABLE dbo.DimTerritories (
    TerritorySK    INT           IDENTITY(1,1) PRIMARY KEY,
    SORKey         INT           NOT NULL REFERENCES dbo.Dim_SOR(SOR_SK),
    TerritoryID    NVARCHAR(20)  NOT NULL,
    TerritoryDesc  NVARCHAR(255),
    RegionID       INT,
    EffectiveDate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    ExpirationDate DATETIME2,
    IsCurrent      BIT           NOT NULL DEFAULT 1
);
GO

-- 12. Fact Table: Orders
IF OBJECT_ID('dbo.FactOrders','U') IS NOT NULL
    DROP TABLE dbo.FactOrders;
CREATE TABLE dbo.FactOrders (
    OrderSK        INT           IDENTITY(1,1) PRIMARY KEY,
    CustomerSK     INT           NOT NULL REFERENCES dbo.DimCustomers(CustomerSK),
    EmployeeSK     INT           NOT NULL REFERENCES dbo.DimEmployees(EmployeeSK),
    ProductSK      INT           NOT NULL REFERENCES dbo.DimProducts(ProductSK),
    CategorySK     INT           NOT NULL REFERENCES dbo.DimCategories(CategorySK),
    RegionSK       INT           NOT NULL REFERENCES dbo.DimRegion(RegionSK),
    ShipperSK      INT           NOT NULL REFERENCES dbo.DimShippers(ShipperSK),
    SupplierSK     INT           NOT NULL REFERENCES dbo.DimSuppliers(SupplierSK),
    TerritorySK    INT           NOT NULL REFERENCES dbo.DimTerritories(TerritorySK),
    OrderDate      DATETIME2,
    RequiredDate   DATETIME2,
    ShippedDate    DATETIME2,
    Freight        DECIMAL(10,2),
    OrderQuantity  INT,
    TotalAmount    DECIMAL(12,2),
    LoadDate       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
