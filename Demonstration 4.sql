--*************************************************************************--
-- Title: Assignment05
-- Author: NickHall
-- Desc: This file demonstrates how to process data in a database
-- Change Log: When,Who,What
-- 2017-01-01,NHall,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment05DB_NHall')
 Begin 
  Alter Database [Assignment05DB_NHall] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_NHall;
 End
go

Create Database Assignment05DB_NHall;
go

Use Assignment05DB_NHall;
go



-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Alter Table Categories 
 Add Constraint pkCategories 
  Primary Key (CategoryId);
go

Alter Table Categories 
 Add Constraint ukCategories 
  Unique (CategoryName);
go

Alter Table Products 
 Add Constraint pkProducts 
  Primary Key (ProductId);
go

Alter Table Products 
 Add Constraint ukProducts 
  Unique (ProductName);
go

Alter Table Products 
 Add Constraint fkProductsToCategories 
  Foreign Key (CategoryId) References Categories(CategoryId);
go

Alter Table Products 
 Add Constraint ckProductUnitPriceZeroOrHigher 
  Check (UnitPrice >= 0);
go

Alter Table Inventories 
 Add Constraint pkInventories 
  Primary Key (InventoryId);
go

Alter Table Inventories
 Add Constraint dfInventoryDate
  Default GetDate() For InventoryDate;
go

Alter Table Inventories
 Add Constraint fkInventoriesToProducts
  Foreign Key (ProductId) References Products(ProductId);
go

Alter Table Inventories 
 Add Constraint ckInventoryCountZeroOrHigher 
  Check ([Count] >= 0);
go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * from Categories;
go
Select * from Products;
go
Select * from Inventories;
go




--Inserting Data with basic insert commands
Insert Into dbo.Categories
(CategoryName)
Values
('Beverages');
go

Insert Into dbo.Products
(ProductName, CategoryID, UnitPrice)
Values
('Chai', 1, '18.00'),
('Chang', 1, '19.00');
go

Insert Into dbo.Inventories
(InventoryDate, ProductID, [Count])
Values
('2017-01-01', 1, 61),
('2017-01-01', 2, 17),
('2017-02-01', 1, 13),
('2017-02-01', 2, 12),
('2017-03-02', 1, 18),
('2017-03-02', 2, 12);
go

--Creating Stored Procedures for Categories
Create Procedure pInsCategories
 (@CategoryName nvarchar(100))
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Insert Into Categories( CategoryName)
	Values (@CategoryName)
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go


Create Procedure pUpdCategories
 (@CategoryID int
 ,@CategoryName nvarchar(100))
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Update Categories
	 Set CategoryName = @CategoryName
	 Where CategoryID = @CategoryID
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go


Create Procedure pDelCategories
(@CategoryID int)
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Delete 
    From Categories
     Where CategoryID = @CategoryID;
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go

--SProc for Products
Create Procedure pInsProducts
 (@ProductName nvarchar(100)
 ,@CategoryID int
 ,@UnitPrice money)
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Insert Into Products( ProductName, CategoryID, UnitPrice)
	Values (@ProductName, @CategoryID, @UnitPrice)
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go


Create Procedure pUpdProducts
 (@ProductID int
 ,@ProductName nvarchar(100)
 ,@CategoryID int
 ,@UnitPrice money)
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Update Products
	 Set ProductName = @ProductName
	  ,CategoryID = @CategoryID
	  ,UnitPrice = @UnitPrice
	 Where ProductID = @ProductID
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go


Create Procedure pDelProducts
(@ProductID int)
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Delete 
    From Products
     Where ProductID = @ProductID;
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go

--SProc for Inventories
Create Procedure pInsInventories
 (@InventoryDate date
 ,@ProductID int
 ,@Count int)
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Insert Into Inventories(InventoryDate, ProductID, [Count])
	Values (@InventoryDate, @ProductID, @Count)
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go


Create Procedure pUpdInventories
 (@InventoryID int
 ,@InventoryDate date
 ,@ProductID int
 ,@Count int)
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Update Inventories
	 Set InventoryDate = @InventoryDate
	  ,ProductID = @ProductID
	  ,[Count] = @Count
	 Where InventoryID = @InventoryID
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go


Create Procedure pDelInventories
(@InventoryID int)
/* Author: <NHall>
** Desc: Processes <Desc text>
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Delete 
    From Inventories
     Where InventoryID = @InventoryID;
   Commit Transaction;
   Set @RC = +1;
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction;
   Print Error_Message();
   Set @RC = -1
  End Catch
  Return @RC;
 End -- Body
go


--Testing Sprocs
Declare @Status int;
Exec @Status = pInsCategories @CategoryName = 'Tuna';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Categories;
go

Declare @Status int;
Exec @Status = pUpdCategories @CategoryID = 2, @CategoryName = 'Seafood';
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed!'
  End as [Status]
Select [The Updated ID Was:] = @@IDENTITY
Select * From Categories;
go

Declare @Status int;
Exec @Status = pDelCategories @CategoryID = 2;
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed!'
  End as [Status]
Select [The Deleted ID Was:] = @@IDENTITY
Select * From Categories;
go



Declare @Status int;
Exec @Status = pInsProducts @ProductName = 'Horchata', @CategoryID = 1,  @UnitPrice = '3.00';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Products;
go

Declare @Status int;
Exec @Status = pUpdProducts @ProductID = 3, @ProductName = 'Horchata', @CategoryID = 1,  @UnitPrice = '4.00';
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed!'
  End as [Status]
Select [The Updated ID Was:] = @@IDENTITY
Select * From Products;
go

Declare @Status int;
Exec @Status = pDelProducts @ProductID = 3;
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed!'
  End as [Status]
Select [The Deleted ID Was:] = @@IDENTITY
Select * From Products;
go

--('2017-03-02', 1, 18)

Declare @Status int;
Exec @Status = pInsInventories @InventoryDate = '2017-04-03', @ProductID = 1, @Count = 120;
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Inventories;
go

Declare @Status int;
Exec @Status = pUpdInventories  @InventoryID = 7, @InventoryDate = '2017-04-03', @ProductID = 1, @Count = 12;
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed!'
  End as [Status]
Select [The Updated ID Was:] = @@IDENTITY
Select * From Inventories;
go

Declare @Status int;
Exec @Status = pDelInventories @InventoryID = 7;
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed!'
  End as [Status]
Select [The Deleted ID Was:] = @@IDENTITY
Select * From Inventories;
go
