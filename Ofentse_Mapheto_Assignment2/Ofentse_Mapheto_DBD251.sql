CREATE DATABASE RandfonteinWheelsDB
ON PRIMARY 
(
NAME= MabopaneWheelsData,
FILENAME= 'C:\Users\Public\RandfonteinWheelData1.mdf',
SIZE= 50MB,
MAXSIZE=2GB,
FILEGROWTH= 10%
),
FILEGROUP SECONDARY
(
NAME= MabopaneWheelsData2,
FILENAME= 'C:\Users\Public\RandfonteinWheelData2.ndf',
MAXSIZE=UNLIMITED,
SIZE= 50MB,
FILEGROWTH= 10%
)
LOG ON 
(
NAME= MabopaneWheelsLog,
FILENAME= 'C:\Users\Public\RandfonteinWheelLog.ldf',
SIZE= 20MB,
MAXSIZE=1GB,
FILEGROWTH= 10MB
);

USE RandfonteinWheelsDB
GO
CREATE TABLE Product
(
Product_ID INT PRIMARY KEY,
Manufacturer_name VARCHAR(25) NOT NULL,
Model VARCHAR(25) NOT NULL,
Weight INT NOT NULL,
Type_of_Product VARCHAR(50) NOT NULL,
)

CREATE TABLE Customers
(
Customer_ID INT PRIMARY KEY,
Fname VARCHAR(25) NOT NULL,
Lname VARCHAR(25) NOT NULL,
Phone VARCHAR(13) NOT NULL,
Email_address VARCHAR(25),
BirthDate DATE
)

CREATE TABLE Customer_Address
(
Cus_AddressID INT PRIMARY KEY,
Customer_ID INT FOREIGN KEY REFERENCES Customers(Customer_ID),
Street VARCHAR(30),
PostalCode CHAR(5),
City VARCHAR(30),
Country VARCHAR(30)
)

CREATE TABLE Vehicles
(
 Vehicle_ID INT PRIMARY KEY,
 F_Location VARCHAR(25) NOT NULL,
 F_Destination VARCHAR(25)
)

CREATE TABLE Services
(
Service_ID INT PRIMARY KEY,
Product_ID INT FOREIGN KEY REFERENCES Product(Product_ID),
Type_Of_Service VARCHAR(25),
Companyname VARCHAR(30),
Phone VARCHAR(30),
Cost_of_service MONEY
)

CREATE TABLE Schedules
(
Schedule_ID INT PRIMARY KEY,
Product_ID INT FOREIGN KEY REFERENCES Product(Product_ID),
Vehicle_ID INT FOREIGN KEY REFERENCES Vehicles(Vehicle_ID),
Departure_time DATETIME NOT NULL,
Arrival_time DATETIME NOT NULL,
Seat_nr INT NOT NULL
)

CREATE TABLE Employees
(
Employee_ID INT PRIMARY KEY,
Schedule_ID INT FOREIGN KEY REFERENCES Schedules(Schedule_ID),
Fname VARCHAR(25) NOT NULL,
Lname VARCHAR(25) NOT NULL,
Phone VARCHAR(13) NOT NULL,
Email_address VARCHAR(25),
Job_Description VARCHAR(11) NOT NULL,
Salary MONEY ,
BirthDate DATE
)

CREATE TABLE Employee_Address
(
Emp_AddressID INT PRIMARY KEY,
Employee_ID INT FOREIGN KEY REFERENCES Employees(Employee_ID),
Street VARCHAR(30),
PostalCode CHAR(5),
City VARCHAR(30),
Country VARCHAR(30)
)

CREATE TABLE Orders
(
Order_ID INT PRIMARY KEY,
Schedule_ID INT FOREIGN KEY REFERENCES Schedules(Schedule_ID),
Customer_ID INT FOREIGN KEY REFERENCES Customers(Customer_ID),
Order_Type VARCHAR(25),
Order_Date DATETIME ,
Price MONEY NOT NULL,
No_of_Orders INT NOT NULL
)

--VIEWS
GO
CREATE VIEW FullCustomerdetails
AS
(
 SELECT *
 FROM Customers C
 INNER JOIN Customer_Address CA
 ON CA.Customer_ID=C.Customer_ID
)
GO

CREATE VIEW [Products Above Average Price] 
AS
SELECT Fname+' '+Lname'Full Name', Salary
FROM Employees
WHERE Salary > 5000

GO
CREATE VIEW Boardingpassengers
AS
SELECT C.Fname+' '+C.Lname 'Customer Full Name',E.Fname+' '+E.Lname 'Employee Full Name',F.F_Location,F.F_Destination,S.Departure_time,S.Arrival_time
FROM Customers C
INNER JOIN Orders B 
ON B.Customer_ID=C.Customer_ID
INNER JOIN Schedules S
ON S.Schedule_ID=B.Schedule_ID
INNER JOIN Employees E
ON E.Schedule_ID=S.Schedule_ID
INNER JOIN Vehicles F
ON F.Vehicle_ID=S.Vehicle_ID

GO
CREATE VIEW AllExpenseReport
AS
SELECT DISTINCT B.Order_Date,SUM(E.Salary),SUM(Cost_of_service)
FROM Employees E
INNER JOIN Schedules S
ON E.Schedule_ID=S.Schedule_ID
INNER JOIN Orders B
ON B.Schedule_ID=S.Schedule_ID
INNER JOIN Product A
ON A.Product_ID=S.Product_ID
INNER JOIN Services SE
ON SE.Product_ID=A.Product_ID
GO
CREATE VIEW ReservedSeats
AS
SELECT TOP 10 Fname+' '+Lname'Full Name',Phone,Email_address,COUNT()
FROM Customers C
INNER JOIN Orders B
ON B.Customer_ID=C.Customer_ID
INNER JOIN Schedules S
ON S.Schedule_ID=B.Schedule_ID
INNER JOIN Product A
ON A.Product_ID=S.Product_ID

GO
CREATE VIEW CustomerDetails
AS
SELECT Fname+' '+Lname 'Full Name',Phone,Email_address,Street,PostalCode,City,Country
FROM Customers C
INNER JOIN Customer_Address CA
ON C.Customer_ID=CA.Customer_ID

GO
CREATE VIEW EmployeeDetails
AS
SELECT Fname+' '+Lname 'Full Name',Phone,Email_address,Street,PostalCode,City,Country
FROM Employees E
INNER JOIN Employee_Address EA
ON E.Employee_ID=EA.Employee_ID

GO
CREATE VIEW BookedCustomers
AS
SELECT Fname+' '+Lname 'Full Name',Phone,Email_address,City+''+Country 'Travelling From',F_Destination'Going to',Departure_time,Seat_nr
FROM Customers C
INNER JOIN Customer_Address CA
ON C.Customer_ID=CA.Customer_ID
INNER JOIN Orders B
ON B.Customer_ID=C.Customer_ID
INNER JOIN Schedules S
ON S.Schedule_ID=B.Schedule_ID
INNER JOIN Vehicles F
ON F.Vehicle_ID=S.Vehicle_ID
---Procedures and Triggers

--C
GO
CREATE TRIGGER EmpUpdates
ON Employees
FOR UPDATE
AS
BEGIN
	BEGIN TRY
	BEGIN TRAN
		PRINT 'From'
		SELECT * FROM deleted
		PRINT 'To'
		SELECT * FROM inserted
	COMMIT TRAN
	PRINT 'Update successful'
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION
		PRINT 'Update unsuccessful'
	END CATCH
END
--2
GO
CREATE TRIGGER CusUpdates
ON Customers
FOR INSERT
AS
BEGIN
SELECT * FROM inserted
PRINT 'Has been successfully added'
END
 --3
 GO
 CREATE TRIGGER AddCustomer
 ON Customers
 FOR INSERT
 AS
 BEGIN
 UPDATE Orders
 SET No_of_Orders=No_of_Orders+1
 END
GO
--4
CREATE PROCEDURE Searchcompany @name VARCHAR(30)
AS
BEGIN
	SELECT Companyname , Phone
	FROM [Services]
	WHERE Companyname LIKE '%'+@name+'%'
END

GO
--5
CREATE PROCEDURE ExpenseReport @date DATE
AS
SELECT *
FROM AllExpenseReport
WHERE Order_Date=@date
--6
GO
CREATE TRIGGER Fullybooked
ON Orders
FOR INSERT
AS
BEGIN
DECLARE @maxseats INT ,
		@bookedseats INT
SET @bookedseats=(SELECT COUNT(Order_ID) FROM Orders)
SET @maxseats=(SELECT nr_of_seats FROM Product)
IF @bookedseats >@maxseats+10
	BEGIN
	PRINT 'The Vehicle is fully booked'
	ROLLBACK 
	END
ELSE
	PRINT 'Space is still available'
END
--7
GO
CREATE TRIGGER nodeletes
ON Customers
FOR DELETE
AS
BEGIN
ROLLBACK
PRINT 'You have no permissions to delete'
END
