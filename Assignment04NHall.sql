--*************************************************************************--
-- Title: Assignment04
-- Author: NHall
-- Desc: This file demonstrates how to process data from a database
-- Change Log: When,Who,What
-- 2020-04-26,NHall,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name from SysDatabases Where Name = 'Assignment04DB_NHall')
 Begin 
  Alter Database [Assignment04DB_NHall] set Single_user With Rollback Immediate;
  Drop Database Assignment04DB_NHall;
 End
go

Create Database Assignment04DB_NHall;
go

Use Assignment04DB_NHall;
go

-- Add Your Code Below ---------------------------------------------------------------------

Select * From Northwind.dbo.Customers;
-- Data Request: 0301
-- Request: I want a list of customer companies and their contact people
Create -- Drop
View vCustomerContacts
As
 Select CompanyName, ContactName
  From Northwind.dbo.Customers;
go


-- Test with this statement --
Select * from vCustomerContacts;


-- Data Request: 0302
-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada
Create -- Drop
View vUSAandCanadaCustomerContacts
As
 Select TOP 1000000
 CompanyName
 , ContactName
 , Country
  From Northwind.dbo.Customers
  Where Country = 'USA' or Country = 'Canada'
  Order By Country, CompanyName
go
-- Test with this statement --
Select * from vUSAandCanadaCustomerContacts;
  
-- Data Request: 0303
-- Request: I want a list of products, their standard price and their categories. 
-- Order the results by Category Name and then Product Name, in alphabetical order.

--Writing out code before placing into view
--Select p.ProductName, p.UnitPrice, c.CategoryName
-- From Northwind.dbo.Products as p
-- Inner Join Northwind.dbo.Categories as c
-- On p.CategoryID = c.CategoryID
-- Order By 3,1;
--go

Create --Alter
View vProductPricesByCategories
As
 Select TOP 1000000000
  c.CategoryName
  , p.ProductName
  , [StandardPrice] = format(p.UnitPrice, 'C', 'en-US')
  From Northwind.dbo.Products as p
  Inner Join Northwind.dbo.Categories as c
  On p.CategoryID = c.CategoryID
  Order By 1,2;
go 
-- Test with this statement --
Select * from vProductPricesByCategories;

-- Data Request: 0304
-- Request: I want a list of products, their standard price and their categories. 
-- Order the results by Category Name and then Product Name, in alphabetical order but only for the seafood category

--Writing out rudementary code
--Select p.ProductName, p.UnitPrice, c.CategoryName
-- From Northwind.dbo.Products as p
-- Inner Join Northwind.dbo.Categories as c
-- On p.CategoryID = c.CategoryID
-- Where p.CategoryID = '8'
-- Order By 3,1;
--go


Create -- Drop
Function dbo.fProductPricesByCategories(@CategoryName VARCHAR(50))
 Returns Table
 As
  Return(
   Select TOP 100000000
    c.CategoryName
	, p.ProductName
	, [StandardPrice] = format(p.UnitPrice, 'C', 'en-US')
    From Northwind.dbo.Products as p
    Inner Join Northwind.dbo.Categories as c
    On p.CategoryID = c.CategoryID
    Where c.CategoryName = @CategoryName
    Order By 1,2
  );
go
-- Test with this statement --
Select * from dbo.fProductPricesByCategories('seafood');


-- Data Request: 0305
-- Request: I want a list of how many orders our customers have placed each year

--Rudementary code
--Select TOP 1000000
--  c.CompanyName
--  ,[NumberOfOrders] = Count(o.OrderID)
--  ,[Order Year] = Year(o.OrderDate)
-- From Northwind.dbo.Orders as o
-- Inner Join Northwind.dbo.Customers as c
--  On  o.CustomerID = c.CustomerID
--  Group By CompanyName, year(OrderDate)
--  Order By CompanyName;

Create --Alter
View vCustomerOrderCounts 
As
 Select TOP 1000000
   c.CompanyName
   ,[NumberOfOrders] = Count(o.OrderID)
   ,[Order Year] = Year(o.OrderDate)
  From Northwind.dbo.Orders as o
  Inner Join Northwind.dbo.Customers as c
   On  o.CustomerID = c.CustomerID
   Group By CompanyName, year(OrderDate)
   Order By CompanyName;
go
-- Test with this statement --
Select * from vCustomerOrderCounts

-- Data Request: 0306
-- Request: I want a list of total order dollars our customers have placed each year

--Viewing Order Details data
Select * From Northwind.dbo.[Order Details]
go

Create -- Alter
View vCustomerOrderDollars
As
 Select TOP 1000000
   c.CompanyName
   ,[TotalDollars] = format(Sum(od.UnitPrice * od.Quantity), 'C', 'en-US')
   ,[Order Year] = Year(o.OrderDate)
  From Northwind.dbo.Orders as o
  Inner Join Northwind.dbo.Customers as c
   On  o.CustomerID = c.CustomerID
  Inner Join Northwind.dbo.[Order Details] as od
   On o.OrderID = od.OrderID
   Group By CompanyName, year(OrderDate)
   Order By CompanyName;
go

-- Test with this statement --
Select * from vCustomerOrderDollars;

