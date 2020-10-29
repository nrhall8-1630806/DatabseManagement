--**********************************************************************************************--
-- Title: Assigment06 
-- Author: NHall
-- Desc: This file demonstrates how to design and create; 
--       tables, constraints, views, stored procedures, and permissions
-- Change Log: When,Who,What
-- 2017-05-08,NHall,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_NHall')
	 Begin 
	  Alter Database [Assignment06DB_NHall] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_NHall;
	 End
	Create Database Assignment06DB_NHall;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_NHall;

-- Create Tables (Module 01)-- 
Create --Drop
Table Students
(StudentID int IDENTITY(1,1) Not Null
,StudentNumber nVarchar(100) Not Null    
,StudentFirstName nVarchar(100) Not Null
,StudentLastName nVarchar(100) Not Null
,StudentEmail nVarchar(100) Not Null
,StudentPhone nVarchar(100) 
,StudentAddress1 nVarchar(100) Not Null
,StudentAddress2 nVarchar(100)
,StudentCity nVarchar(100) 
,StudentStateCode nVarchar(100) Not Null
,StudentZipCode nVarchar(100) 
);
go

Create --Drop
Table Courses
(CourseID int IDENTITY(1,1) Not Null
 ,CourseName nVarchar(100) Not Null 
 ,CourseStartDate Date
 ,CourseEndDate Date
 ,CourseStartTime Time
 ,CourseEndTime Time
 ,CourseWeekDays nVarchar(100)
 ,CourseCurrentPrice Money
);
go

Create --Drop
Table Enrollments
(EnrollmentID Int IDENTITY(1,1) Not Null 
 ,StudentID int Not Null 
 ,CourseID int Not Null 
 ,EnrollmentDateTime Datetime Not Null 
 ,EnrollmentPrice Money Not Null 
);
go

-- Add Constraints (Module 02) -- 
Alter Table Students
 Add Constraint pkStudents
  Primary Key (StudentID);
go

Alter Table Students
 Add Constraint ukStudents
  Unique (StudentNumber, StudentEmail);
go

Alter Table Courses
 Add Constraint pkCourses
  Primary Key (CourseID);
go

Alter Table Courses
 Add Constraint ukCourses
  Unique (CourseName);
go

Alter Table Courses
 Add Constraint ckCourses
  Check (CourseEndDate > CourseStartDate and CourseEndTime > CourseStartTime);
go

Alter Table Enrollments
 Add Constraint pkEnrollments
  Primary Key (EnrollmentID);
go

Alter Table Enrollments
 Add Constraint fkEnrollments1
  Foreign Key (StudentID) References Students(StudentID);
go

Alter Table Enrollments
 Add Constraint fkEnrollments2
  Foreign Key (CourseID) References Courses(CourseID);
go

Alter Table Enrollments
 Add Constraint dfEnrollments
  Default GetDate() For EnrollmentDateTime;
go

Create Function dbo.fGetCourseStartDate
(@CourseID int)
 Returns Date
  As
   Begin
    Return (Select CourseStartDate 
	 From Courses
	  Where CourseID = @CourseID)
   End
go

Alter Table Enrollments
 Add Constraint ckEnrollments
  Check (EnrollmentDateTime < dbo.fGetCourseStartDate(CourseID));
go


  -- Add Views (Module 03 and 04) -- 
Create View vStudents
As Select StudentID
, StudentNumber
, StudentFirstName
, StudentLastName
, StudentEmail
, StudentPhone
, StudentAddress1
, StudentAddress2
, StudentCity
, StudentStateCode
, StudentZipCode   
 From Students;
go

Create View vEnrollments
As Select EnrollmentID
, StudentID
, CourseID
, EnrollmentDateTime
, EnrollmentPrice
 From Enrollments;
go

Create View vCourses
As Select CourseID
, CourseName
, CourseStartDate
, CourseEndDate
, CourseStartTime
, CourseEndTime
, CourseWeekDays
, CourseCurrentPrice
 From Courses;
go

Create View vReport
As Select s.StudentID
, s.StudentNumber
, s.StudentFirstName
, s.StudentLastName
, s.StudentEmail
, s.StudentPhone
, s.StudentAddress1
, s.StudentAddress2
, s.StudentCity
, s.StudentStateCode
, s.StudentZipCode
, e.EnrollmentID
, e.EnrollmentDateTime
, e.EnrollmentPrice
, c.CourseID
, c.CourseName
, c.CourseStartDate
, c.CourseEndDate
, c.CourseStartTime
, c.CourseEndTime
, c.CourseWeekDays
, c.CourseCurrentPrice
 from Students as s
  Full Outer Join Enrollments as e
   On s.StudentID = e.StudentID
  Full Outer Join Courses as c
   On e.CourseID = c.CourseID
go
-- Add Stored Procedures (Module 04 and 05) --
Create Procedure pInsStudents
(@StudentNumber nvarchar(100)
, @StudentFirstName nvarchar(100)
, @StudentLastName nvarchar(100)
, @StudentEmail nvarchar(100)
, @StudentPhone nvarchar(100)
, @StudentAddress1 nvarchar(100)
, @StudentAddress2 nvarchar(100)
, @StudentCity nvarchar(100)
, @StudentStateCode nvarchar(100)
, @StudentZipCode nvarchar(100))
/* Author: <NHall>
** Desc: Processes Inserts into the Student table
** Change Log: When,Who,What
** <2020-05-09>,<Nick Hall>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    Insert Into Students(StudentNumber
	, StudentFirstName
	, StudentLastName
	, StudentEmail
	, StudentPhone
	, StudentAddress1
	, StudentAddress2
	, StudentCity
	, StudentStateCode
	, StudentZipCode)
	Values (@StudentNumber
	, @StudentFirstName
	, @StudentLastName
	, @StudentEmail
	, @StudentPhone
	, @StudentAddress1
	, @StudentAddress2
	, @StudentCity
	, @StudentStateCode
	, @StudentZipCode)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
/* Testing Code:
 Declare @Status int;
 Exec @Status = pInsStudents @StudentNumber = 'B-Smith-071'
	, @StudentFirstName = 'Bob'
	, @StudentLastName = 'Smith'
	, @StudentEmail = 'Bsmith@HipMail.com'
	, @StudentPhone = '(206)-111-2222'
	, @StudentAddress1 = '123 Main St.'
	, @StudentAddress2 = ''
	, @StudentCity = ' Seattle'
	, @StudentStateCode = 'WA'
	, @StudentZipCode = '98001-1234';
 Print @Status;
*/

Create Procedure pUpdStudents
(@StudentID int
, @StudentNumber nvarchar(100)
, @StudentFirstName nvarchar(100)
, @StudentLastName nvarchar(100)
, @StudentEmail nvarchar(100)
, @StudentPhone nvarchar(100)
, @StudentAddress1 nvarchar(100)
, @StudentAddress2 nvarchar(100)
, @StudentCity nvarchar(100)
, @StudentStateCode nvarchar(100)
, @StudentZipCode nvarchar(100))
/* Author: <NHall>
** Desc: Processes updates the Student table
** Change Log: When,Who,What
** <2020-05-09>,<Nick Hall>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    Update Students
	Set StudentNumber = @StudentNumber
	, StudentFirstName = @StudentFirstName
	, StudentLastName = @StudentLastName
	, StudentEmail = @StudentEmail
	, StudentPhone = @StudentPhone
	, StudentAddress1 = @StudentAddress1
	, StudentAddress2 = @StudentAddress2
	, StudentCity = @StudentCity
	, StudentStateCode = @StudentStateCode
	, StudentZipCode = @StudentZipCode
	Where StudentID = @StudentID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pUpdStudents @StudentID = 1
    , @StudentNumber = '1234'
	, @StudentFirstName = 'bob'
	, @StudentLastName = 'flop'
	, @StudentEmail = 'bf@uw.edu'
	, @StudentPhone = '234343546'
	, @StudentAddress1 = '43234 4th ave N'
	, @StudentAddress2 = ''
	, @StudentCity = 'Seattle'
	, @StudentStateCode = 'WA'
	, @StudentZipCode = '98109';
 Print @Status;
*/

Create Procedure pDelStudents
(@StudentID int)
/* Author: <NHall>
** Desc: Deletes data from Students Table
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Delete 
    From Students
     Where StudentID = @StudentID;
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

/* Testing Code:
 Declare @Status int;
 Exec @Status = pDelStudents @StudentID = 1;
 Print @Status;
*/


Create Procedure pInsCourses
(@CourseName nVarchar(100)
 ,@CourseStartDate Date
 ,@CourseEndDate Date
 ,@CourseStartTime Time
 ,@CourseEndTime Time
 ,@CourseWeekDays nVarchar(100)
 ,@CourseCurrentPrice Money)
/* Author: <NHall>
** Desc: Processes Inserts into the Courses table
** Change Log: When,Who,What
** <2020-05-09>,<Nick Hall>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    Insert Into Courses(CourseName
	 ,CourseStartDate
	 ,CourseEndDate
	 ,CourseStartTime
	 ,CourseEndTime
	 ,CourseWeekDays
	 ,CourseCurrentPrice)
	Values (@CourseName
	 ,@CourseStartDate
	 ,@CourseEndDate
	 ,@CourseStartTime
	 ,@CourseEndTime
	 ,@CourseWeekDays
	 ,@CourseCurrentPrice)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
/* Testing Code:
 Declare @Status int;
 Exec @Status = pInsCourses @CourseName = 'Math'
	 ,@CourseStartDate = '12-02-2001'
	 ,@CourseEndDate = '12-03-2001'
	 ,@CourseStartTime = '11:01'
	 ,@CourseEndTime = '12:02'
	 ,@CourseWeekDays = 'T'
	 ,@CourseCurrentPrice = 12.32;
 Print @Status;
*/

Create Procedure pUpdCourses
(@CourseID Int 
 ,@CourseName nVarchar(100)
 ,@CourseStartDate Date
 ,@CourseEndDate Date
 ,@CourseStartTime Time
 ,@CourseEndTime Time
 ,@CourseWeekDays nVarchar(100)
 ,@CourseCurrentPrice Money)
/* Author: <NHall>
** Desc: Processes updates the Courses table
** Change Log: When,Who,What
** <2020-05-09>,<Nick Hall>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    Update Courses
	Set CourseName = @CourseName
	 ,CourseStartDate = @CourseStartDate
	 ,CourseEndDate = @CourseEndDate
	 ,CourseStartTime = @CourseStartTime
	 ,CourseEndTime = @CourseEndTime
	 ,CourseWeekDays = @CourseWeekDays
	 ,CourseCurrentPrice = @CourseCurrentPrice
	Where CourseID = @CourseID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pUpdCourses @CourseID = 1
	 ,@CourseName = 'Math'
	 ,@CourseStartDate = '12-02-2001'
	 ,@CourseEndDate = '12-03-2001'
	 ,@CourseStartTime = '11:01'
	 ,@CourseEndTime = '12:02'
	 ,@CourseWeekDays = 'T'
	 ,@CourseCurrentPrice = 12.32;
 Print @Status;
*/

Create Procedure pDelCourses
(@CourseID int)
/* Author: <NHall>
** Desc: Deletes data from Courses Table
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Delete 
    From Courses
     Where CourseID = @CourseID;
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

/* Testing Code:
 Declare @Status int;
 Exec @Status = pDelCourses @CourseID = 2;
 Print @Status;
*/




Create Procedure pInsEnrollments
(@StudentID int
 ,@CourseID int 
 ,@EnrollmentDateTime Datetime 
 ,@EnrollmentPrice Money)
/* Author: <NHall>
** Desc: Processes Inserts into the Enrollments table
** Change Log: When,Who,What
** <2020-05-09>,<Nick Hall>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    Insert Into Enrollments(StudentID
	, CourseID
	, EnrollmentDateTime
	, EnrollmentPrice)
	Values (@StudentID
	, @CourseID
	, @EnrollmentDateTime
	, @EnrollmentPrice)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
/* Testing Code:
 Declare @Status int;
 Exec @Status = pInsEnrollments @StudentID = 1
	, @CourseID = 1
	, @EnrollmentDateTime = '12-03-2000'
	, @EnrollmentPrice = 19.21;
 Print @Status;
*/

Create Procedure pUpdEnrollments
(@EnrollmentID Int 
 ,@StudentID int
 ,@CourseID int 
 ,@EnrollmentDateTime Datetime 
 ,@EnrollmentPrice Money)
/* Author: <NHall>
** Desc: Processes updates the Enrollments table
** Change Log: When,Who,What
** <2020-05-09>,<Nick Hall>,Created Sproc.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
    Update Enrollments
	Set StudentID = @StudentID	
	, CourseID = @CourseID
	, EnrollmentDateTime = @EnrollmentDateTime
	, EnrollmentPrice = @EnrollmentPrice
	Where EnrollmentID = @EnrollmentID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

/* Testing Code:
 Declare @Status int;
 Exec @Status = pUpdEnrollments @EnrollmentID = 1
	, @StudentID = 1
	, @CourseID = 1
	, @EnrollmentDateTime = '12-03-19'
	, @EnrollmentPrice = 19.21;
 Print @Status;
*/

Create Procedure pDelEnrollments
(@EnrollmentID int)
/* Author: <NHall>
** Desc: Deletes data from Enrollments Table
** Change Log: When,Who,What
** <2020-05-04>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    Delete 
    From Enrollments
     Where EnrollmentID = @EnrollmentID;
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

/* Testing Code:
 Declare @Status int;
 Exec @Status = pDelEnrollments @EnrollmentID = 1;
 Print @Status;
*/
-- Set Permissions (Module 06) --
Deny Select, Insert, Update, Delete On Students to Public;
Deny Select, Insert, Update, Delete On Enrollments to Public;
Deny Select, Insert, Update, Delete On Courses to Public;
Grant Select On vStudents to Public;
Grant Select On vEnrollments to Public;
Grant Select On vCourses to Public;
Grant Execute On pInsStudents to Public;
Grant Execute On pUpdStudents to Public;
Grant Execute On pDelStudents to Public;
Grant Execute On pInsEnrollments to Public;
Grant Execute On pUpdEnrollments to Public;
Grant Execute On pDelEnrollments to Public;
Grant Execute On pInsCourses to Public;
Grant Execute On pUpdCourses to Public;
Grant Execute On pDelCourses to Public;
go
--< Test Views and Sprocs >-- 
Exec pInsStudents @StudentNumber = 'B-Smith-071'
	, @StudentFirstName = 'Bob'
	, @StudentLastName = 'Smith'
	, @StudentEmail = 'Bsmith@HipMail.com'
	, @StudentPhone = '(206)-111-2222'
	, @StudentAddress1 = '123 Main St.'
	, @StudentAddress2 = ''
	, @StudentCity = ' Seattle'
	, @StudentStateCode = 'WA'
	, @StudentZipCode = '98001-1234';
go

Exec pInsCourses @CourseName = 'SQL1 - Winter 2017'
	 ,@CourseStartDate = '1/10/2017'
	 ,@CourseEndDate = '1/24/2017'
	 ,@CourseStartTime = '1:00'
	 ,@CourseEndTime = '1:01'
	 ,@CourseWeekDays = 'T-Th'
	 ,@CourseCurrentPrice = 399;
go

Exec pInsEnrollments @StudentID = 1
	, @CourseID = 1
	, @EnrollmentDateTime = '1-03-2017'
	, @EnrollmentPrice = 19.21;
go
--{ IMPORTANT }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/