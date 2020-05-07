--*************************************************************************--
-- Title: Assignment03
-- Author: NickHall
-- Desc: This file demonstrates how to select data from a database
-- Change Log: When,Who,What
-- 2020-04-18,NickHall,Created File
--**************************************************************************--


/********************************* Questions and Answers *********************************/
-- Data Request: 0301
-- Date: 1/1/2020
-- From: Jane Encharge CEO
-- Request: I want a list of customer companies and their contact people
-- Needed By: ASAP
Select * From Customers --Viewing Table

Use Northwind
Select CompanyName, ContactName
 From Customers


-- Data Request: 0302
-- Date: 1/2/2020
-- From: Jane Encharge CEO
-- Request: I want a list of customer companies and their contact people, but only the ones in US and Canada
-- Needed By: ASAP

Select CompanyName, ContactName
 From Customers
  Where Country = 'USA' Or Country = 'Canada'

-- Data Request: 0303
-- Date: 1/2/2020
-- From: Jane Encharge CEO
-- Request: I want a list of products, their standard price and their categories. Order the results by Category Name 
-- and then Product Name, in alphabetical order
-- Needed By: ASAP

Select * From Products --Viewing Table

Select c.CategoryName, p.ProductName, p.UnitPrice AS [Standard Price]
 From Products as p --Gving the Products table an alias of "p"
 Join Categories as c --Joining the tables while giving the Categories table an alias of "c"
  On p.CategoryID = c.CategoryID
  Order By CategoryName ASC, ProductName ASC;

-- Data Request: 0304
-- Date: 1/3/2020
-- From: Jane Encharge CEO
-- Request: I want a list of how many customers we have in the US
-- Needed By: ASAP

Select * From Customers --Viewing Table

Select [Count] = Count(*), Country
 From Customers
  Where Country = 'USA'
  Group By Country

-- Data Request: 0305
-- Date: 1/4/2020
-- From: Jane Encharge CEO
-- Request: I want a list of how many customers we have in the US and Canada, with subtotals for each
-- Needed By: ASAP

Select [Count] = Count(Country), Country
 From Customers
  Where Country = 'USA' Or Country = 'Canada'
  Group By Country

/***************************************************************************************/