
CREATE DATABASE SalesOrderDB
ON PRIMARY
(NAME= SalesOrderDataFile1,
FILENAME= "C:\newFolder\data\SalesOrderDataFile1.mdf")

LOG ON 
(NAME =SalesOrderLogFile1,
FILENAME= "C:\newFolder\data\SalesOrderDataFile1.ldf")
CREATE DATABASE SalesOrdersDb;
GO
/***********Question1**************/
CREATE TABLE Customer (
    CustomerID int  NOT NULL IDENTITY(1, 1),
    FirstName Varchar(50)  NULL,
     MiddleInitials Varchar(5) NULL,
     LastName Varchar(50) NULL,
     CompanyName Varchar(50) NULL,
     EmailAddress Varchar(50) NULL,
    CONSTRAINT CustomerID PRIMARY KEY  (CustomerID)
);

CREATE TABLE CustomerAddress (
   FOREIGN KEY (CustomerID) REFERENCES customer (CustomerId),
   FOREIGN KEY (AddressID) REFERENCES Address (AddressID),
    AddressType Varchar(50)  NULL,
);
CREATE TABLE Address (
AddressID int  NOT NULL IDENTITY(1, 1),
AddressLine1 Varchar(50)  NULL,
AddressLine2 Varchar(50)  NULL,
City Varchar(50)  NULL,
StateProvince Varchar(50)  NULL,
CountryRegion Varchar(50)  NULL,
PostalCode Varchar(10)  NULL,
   FOREIGN KEY (CountryID) REFERENCES Country (CountryID),
);

CREATE TABLE SalesOrderHeader (
SalesOrderID int NOT NULL IDENTITY(1,1),
RevisionNumber int NULL,
OrderDate date NULL,
 FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID),
   FOREIGN KEY (BilltoAddressID) REFERENCES Address (AddressID),
   FOREIGN KEY (ShipToAddressID) REFERENCES Address (AddressID),
ShipMethod Varchar(50) NULL,
Subtotal INT NULL,
TaxAmt decimal(18,2) NULL,
Freight int NULL);

CREATE TABLE SalesOrderDetail (
FOREIGN KEY (SalesOrderID) REFERENCES SalesOrderHeader (SalesOrderID),
SalesOrderDetailID int NOT NULL IDENTITY(1,1),
OrderQty int NULL,
FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
UnitPrice decimal(18,2) NULL,
UnitPriceDiscount(18,2) NULL);

CREATE TABLE Product (
ProductID int NOT NULL IDENTITY(1,1),
Name varchar(50) NULL,
Colour varchar(50) NULL,
ListPrice decimal(18,2) NULL,
Size int NULL,
Weight int NULL,
FOREIGN KEY (ProductModelID) REFERENCES ProductModel (ProductModelID),
FOREIGN KEY (ProductCategoryID) REFERENCES ProductCategory (ProductCategoryID)
);

CREATE TABLE ProductModel (
ProductModelID int NOT NULL IDENTITY(1,1),
Name VARCHAR(50));
CREATE TABLE ProductCategory (
ProductCategoryID int NOT NULL IDENTITY(1,1),
FOREIGN KEY (ParentProductCategoryID) REFERENCES ProductCategory (ProductCategoryID),
Name Varchar(50) NULL));

CREATE TABLE ProductModelProductDescription (
FOREIGN KEY (ProductModelID) REFERENCES ProductModel (ProductModelID),
ProductDescription varchar(50) NULL,
Culture Varchar(50) NULL)):

CREATE TABLE Country (
Country	ID int NOT NULL IDENTITY(1,1),
Name Varchar(50) NULL,
Continent varchar(50) NULL,
Area varchar(50) NULL,
Population varchar(50) NULL,
GDP Varchar(50) NULL));


/***** Question2  ******/
/*2a.*/ Select CompanyName from Customer where FirstName =’Mary’ and MiddleInitials = ‘Louise’ and LastName = ‘Kent’
/*2b.*/ Select FirstName+’ ’+MiddleInitials+’ ’+LastName as FullName, EmailAddress 
From Customer JOIN CustomerAddress on CustomerAddress.CustomerID = Customer.CustomerID
JOIN Address on Address.AddressID = CustomerAddress.AddressID
Where Address.City = ‘Boston’
/*2c.*/ Select count(ProdcutID) as NumberOfItemsSold
 from Product 
inner join SalesOrderDetail on SalesOrderDetail.ProductID = Product.ProductID
where Product.ListPrice >2500

/*2d.*/ Select SalesOrderID, UnitPrice 
from SalesOrderDetail where OrderQty = 1
/*2e.*/ select SalesOrderHeader.SalesOrderId, SalesOrderHeader.SubTotal as Subtotal1, sum(SalesOrderDetail.OrderQty* SalesOrderDetail.UnitPrice) as Subtotal2, 
sum(SalesOrderDetail.OrderQty*Product.ListPrice) as Subtotal3 from SalesOrderHeader 
inner join SalesOrderDetail on SalesOrderHeader.SalesOrderId= SalesOrderDetail.SalesOrderId
inner join Product  on Product.ProductId= SalesOrderDetail.productId
group by SalesOrderHeader.salesOrderId, SalesOrderHeader.SubTotal;

/*2f.*/ select Name from Country where (Country.Area >= 3000000 and Country.Population <250000000) or (Country.Population>=250000000 and Country.Area<3000000)

/*2g.*/ select convert(numeric(10,2),population/1000000), convert(numeric(10,2),GDP/1000000000), From Country where Continent = ‘South America’
/*2h.*/ select name, case 
when continent = 'Europe' or continent = ‘Asia’ then 'Eurasia'
when continent ='North America' or continent =  'South America' or continent = 'Caribbean' then 'America'
ELSE END as continent
FROM Country








