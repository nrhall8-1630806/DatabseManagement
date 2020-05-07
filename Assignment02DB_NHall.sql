/**************************************************************************
--Title: Assignment02DB_NHall
--Desc:Code for Assignment02
--ChangeLog(When,Who,What)
--4/11/20, NHall, Created Script
**************************************************************************/

Use Master;
go
--Drop as needed
If Exists(Select Name From SysDatabases Where Name = 'Assignment02DB_NHall')
	Drop Database Assignment02DB_NHall;
go

--Create Database
Create Database Assignment02DB_NHall
go
Use Assignment02DB_NHall
go

--Create Tables
Create Table Customers
(CustomerID int Constraint pkCustomers Primary Key Not Null Identity(1,1)
,CustomerName nvarchar(100) Not Null
);

Create Table Categories
(CategoryID int Constraint pkCategories Primary Key Not Null Identity(1,1)
,CategoryName nvarchar(100) Not Null 
);

Create Table SubCategories
(SubCategoryID int Constraint pkSubCategories Primary Key Not Null Identity(1,1)
,SubCategoryName nvarchar(100) Not Null
,CategoryID int Not Null
);
go
Alter Table SubCategories 
	Add Constraint fkCategories Foreign Key (CategoryID) 
		References Categories(CategoryID);
go

Create Table Products
(ProductID int Constraint pkPorducts Primary Key Not Null Identity(1,1)
,ProductName nvarchar(100) Not Null 
,ProductPrice money Not Null
,SubcategoryID int
);
Alter Table Products
	Add Constraint fkSubCategories Foreign Key (SubcategoryID) 
		References SubCategories(SubcategoryID);
go
Alter Table Products
	Add Constraint uqProductName Unique (ProductName)
go

Create Table Orders
(OrderID int Constraint pkOrders Primary Key Not Null Identity(1,1)
,CustomerID int Not Null
,OrderDate date Not Null
);
go
Alter Table Orders
	Add Constraint fkCustomers Foreign Key (CustomerID) 
		References Customers(CustomerID);
go

Create Table OrderDetails
(OrderID int Not Null
,ProductID int Not Null
,OrderPrice money not null
,OrderQuantity smallint not null
);
go
Alter Table OrderDetails
	Add Constraint fkOrders Foreign Key (OrderID) 
		References Orders(OrderID);
go
Alter Table OrderDetails
	Add Constraint fkProducts Foreign Key (ProductID) 
		References Products(ProductID);
go


--Create Views
Create View vCustomers
As Select CustomerID, CustomerName From Customers;
go
			
Create View	vCategories
As Select CategoryID, CategoryName From Categories;
go
			
Create View	vSubCategories
As Select SubCategoryID, SubCategoryName, CategoryID From SubCategories
go

Create View	vProducts
As Select ProductID, ProductName, SubCategoryID, ProductPrice From Products
go
			
Create View	vOrderDetails
As Select OrderID, ProductID, OrderPrice, OrderQuantity From OrderDetails
go 

Create View	vOrders
As Select OrderID, CustomerID, OrderDate From Orders
go