--**********************************************************************************************--
-- Title: Assigment06 
-- Author: NHall
-- Desc: This file demonstrates how to design and create; 
--       tables, constraints, views, stored procedures, and permissions
-- Change Log: When,Who,What
-- 2020-05-25,NHall,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'FinalDB_NHall')
	 Begin 
	  Alter Database [FinalDB_NHall] set Single_user With Rollback Immediate;
	  Drop Database FinalDB_NHall;
	 End
	Create Database FinalDB_NHall;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use FinalDB_NHall;

--Creating Tables
Create Table Clinics 
 (ClinicID int Identity (1,1) Not Null Primary Key
 ,ClinicName nvarchar(100) Unique Not Null
 ,ClinicPhoneNumber nvarchar(100) Not Null Check (ClinicPhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
 ,ClinicAddress nvarchar(100) Not Null
 ,ClinicCity nvarchar(100) Not Null
 ,ClinicState nvarchar(100) Not Null
 ,ClinicZipCode nvarchar(100) Not Null Check (ClinicZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR 
  ClinicZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'OR 
  ClinicZipCode LIKE '[A-Y][0-9][A-Z][0-9][A-Z][0-9]')
);
go

Create Table Patients 
 (PatientID int Identity (1,1) Not Null Primary Key
 ,PatientFirstName nvarchar(100) Not Null
 ,PatientLastName nvarchar(100) Not Null
 ,PatientPhoneNumber nvarchar(100) Not Null Check (PatientPhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
 ,PatientAddress nvarchar(100) Not Null
 ,PatientCity nvarchar(100) Not Null 
 ,PatientState nchar(2) Not Null
 ,PatientZipCode nvarchar(100) Not Null Check (PatientZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR 
  PatientZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'OR 
  PatientZipCode LIKE '[A-Y][0-9][A-Z][0-9][A-Z][0-9]')
);
go

Create Table Doctors
 (DoctorID int Identity (1,1) Not Null Primary Key
 ,DoctorFirstName nvarchar(100) Not Null
 ,DoctorLastName nvarchar(100) Not Null
 ,DoctorPhoneNumber nvarchar(100) Not Null Check (DoctorPhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
 ,DoctorAddress nvarchar(100) Not Null
 ,DoctorCity nvarchar(100) Not Null
 ,DoctorState nchar(2) Not Null
 ,DoctorZipCode nvarchar(100) Not Null Check (DoctorZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR 
  DoctorZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'OR 
  DoctorZipCode LIKE '[A-Y][0-9][A-Z][0-9][A-Z][0-9]')
);
go

Create Table Appointments
 (AppointmentID int Identity (1,1) Not Null Primary Key
 ,AppointmentDateTime datetime Not Null
 ,AppointmentPatientID int Foreign Key References Patients(PatientID)
 ,AppointmentDoctorID int Foreign Key References Doctors(DoctorID)
 ,AppointmentClinicID int Foreign Key References Clinics(ClinicID)
);
go

--Creating Views
Create View vClinics
As Select ClinicID
,ClinicName
,ClinicPhoneNumber
,ClinicAddress
,ClinicCity
,ClinicState
,ClinicZipCode
From Clinics;
go

Create View vPatients
As Select PatientID
,PatientFirstName
,PatientLastName
,PatientPhoneNumber
,PatientAddress
,PatientCity
,PatientState
,PatientZipCode
From Patients;
go

Create View vDoctors
As Select DoctorID
,DoctorFirstName
,DoctorLastName
,DoctorPhoneNumber
,DoctorAddress
,DoctorCity
,DoctorState
,DoctorZipCode
From Doctors;
go

Create View vAppointments
As Select AppointmentID
,AppointmentDateTime
,AppointmentPatientID
,AppointmentDoctorID
,AppointmentClinicID
From Appointments;
go

Create View vAppointmentsByPatientsDoctorsAndClinics
As Select a.AppointmentID
,[AppointmentDate] = convert(date, a.AppointmentDateTime, 101)
,[AppointmentTime] = Format(convert(time, a.AppointmentDateTime), N'hh\:mm')
,p.PatientID
,[PatientName] = concat(p.PatientFirstName, ' ' ,p.PatientLastName)
,p.PatientPhoneNumber
,p.PatientAddress
,p.PatientCity
,p.PatientState
,p.PatientZipCode
,d.DoctorID
,[DoctorName] = concat(d.DoctorFirstName, ' ' ,d.DoctorLastName)
,d.DoctorPhoneNumber
,d.DoctorAddress
,d.DoctorCity
,d.DoctorState
,d.DoctorZipCode
,c.ClinicID
,c.ClinicName
,c.ClinicPhoneNumber
,c.ClinicAddress
,c.ClinicCity
,c.ClinicState
,c.ClinicZipCode
From Appointments as a
 Full Outer Join Patients as p
  on a.AppointmentPatientID = p.PatientID
 Full Outer Join Doctors as d
  on a.AppointmentDoctorID = d.DoctorID
 Full Outer Join Clinics as c
  on a.AppointmentClinicID = c.ClinicID
;
go

--Stored Procedures
Create Procedure pInsClinics
(@ClinicName nvarchar(100)
,@ClinicPhoneNumber nvarchar(100)
,@ClinicAddress nvarchar(100)
,@ClinicCity nvarchar(100)
,@ClinicState nchar(2)
,@ClinicZipCode nvarchar(100)
)
/* Author: <NHall>
** Desc: Processes Inserts into Clinics table
** Change Log: When,Who,What
** 2020-05-25,Nick Hall,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Insert Into Clinics(
	ClinicName
	,ClinicPhoneNumber
	,ClinicAddress
	,ClinicCity
	,ClinicState
	,ClinicZipCode
	)
	Values (@ClinicName
	,@ClinicPhoneNumber
	,@ClinicAddress
	,@ClinicCity
	,@ClinicState
	,@ClinicZipCode
	)
	;
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

Create Procedure pUpdClinics
(@ClinicID Int
,@ClinicName nvarchar(100)
,@ClinicPhoneNumber nvarchar(100)
,@ClinicAddress nvarchar(100)
,@ClinicCity nvarchar(100)
,@ClinicState nchar(2)
,@ClinicZipCode nvarchar(100)
)
/* Author: <NHall>
** Desc: Processes updates to Clinics table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Update Clinics
	Set ClinicName = @ClinicName
	,ClinicPhoneNumber = @ClinicPhoneNumber
	,ClinicAddress = @ClinicAddress
	,ClinicCity = @ClinicCity
	,ClinicState = @ClinicState
	,ClinicZipCode = @ClinicZipCode
	Where ClinicID = @ClinicID;
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

Create Procedure pDelClinics
(@ClinicID int)
/* Author: <NHall>
** Desc: Processes deletions from Clinics Table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Delete 
	From Clinics
	 Where ClinicID = @ClinicID; 
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

Create Procedure pInsPatients
(@PatientFirstName nvarchar(100)
,@PatientLastName nvarchar(100)
,@PatientPhoneNumber nvarchar(100)
,@PatientAddress nvarchar(100)
,@PatientCity nvarchar(100)
,@PatientState nchar(2)
,@PatientZipCode nvarchar(100)
)
/* Author: <NHall>
** Desc: Processes insertions into Patients table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Insert Into Patients(
	PatientFirstName
	,PatientLastName
	,PatientPhoneNumber
	,PatientAddress
	,PatientCity
	,PatientState
	,PatientZipCode
	)
	Values (@PatientFirstName
	,@PatientLastName
	,@PatientPhoneNumber
	,@PatientAddress
	,@PatientCity
	,@PatientState
	,@PatientZipCode
	);
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

Create Procedure pUpdPatients
(@PatientID Int
,@PatientFirstName nvarchar(100)
,@PatientLastName nvarchar(100)
,@PatientPhoneNumber nvarchar(100)
,@PatientAddress nvarchar(100)
,@PatientCity nvarchar(100)
,@PatientState nchar(2)
,@PatientZipCode nvarchar(100)
)
/* Author: <NHall>
** Desc: Processes updates to Patients Table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Update Patients
	Set PatientFirstName = @PatientFirstName
	,PatientLastName = @PatientLastName
	,PatientPhoneNumber = @PatientPhoneNumber
	,PatientAddress = @PatientAddress
	,PatientCity = @PatientCity
	,PatientState = @PatientState
	,PatientZipCode = @PatientZipCode
	Where PatientID = @PatientID;
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

Create Procedure pDelPatients
(@PatientID int)
/* Author: <NHall>
** Desc: Processes deletions to Patients Table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Delete
	From Patients
	 Where PatientID = @PatientID;
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

Create Procedure pInsDoctors
(@DoctorFirstName nvarchar(100)
,@DoctorLastName nvarchar(100)
,@DoctorPhoneNumber nvarchar(100)
,@DoctorAddress nvarchar(100)
,@DoctorCity nvarchar(100)
,@DoctorState nchar(2)
,@DoctorZipCode nvarchar(100)
)
/* Author: <NHall>
** Desc: Processes insertions into Doctors Table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Insert Into Doctors(DoctorFirstName
	,DoctorLastName
	,DoctorPhoneNumber
	,DoctorAddress
	,DoctorCity
	,DoctorState
	,DoctorZipCode
	)
	Values(@DoctorFirstName
	,@DoctorLastName
	,@DoctorPhoneNumber
	,@DoctorAddress
	,@DoctorCity
	,@DoctorState
	,@DoctorZipCode
	);
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

Create Procedure pUpdDoctors
(@DoctorID int
,@DoctorFirstName nvarchar(100)
,@DoctorLastName nvarchar(100)
,@DoctorPhoneNumber nvarchar(100)
,@DoctorAddress nvarchar(100)
,@DoctorCity nvarchar(100)
,@DoctorState nchar(2)
,@DoctorZipCode nvarchar(100)
)
/* Author: <NHall>
** Desc: Processes updates to Doctors table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Update Doctors
	Set DoctorFirstName = @DoctorFirstName
	,DoctorLastName = @DoctorLastName
	,DoctorPhoneNumber = @DoctorPhoneNumber
	,DoctorAddress = @DoctorAddress
	,DoctorCity = @DoctorCity
	,DoctorState = @DoctorState
	,DoctorZipCode = @DoctorZipCode
	Where DoctorID = @DoctorID;
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

Create Procedure pDelDoctors
(@DoctorID int)
/* Author: <NHall>
** Desc: Processes deletions to Doctors Table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Delete
	From Doctors
	 Where DoctorID = @DoctorID;
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

Create Procedure pInsAppointments
(@AppointmentDateTime datetime
,@AppointmentPatientID int
,@AppointmentDoctorID int
,@AppointmentClinicID int
)
/* Author: <NHall>
** Desc: Processes insertions into Appointments
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Insert Into Appointments(AppointmentDateTime
	,AppointmentPatientID
	,AppointmentDoctorID
	,AppointmentClinicID)
	Values (@AppointmentDateTime
	,@AppointmentPatientID
	,@AppointmentDoctorID
	,@AppointmentClinicID);
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

Create Procedure pUpdAppointments
(@AppointmentID int
,@AppointmentDateTime datetime
,@AppointmentPatientID int
,@AppointmentDoctorID int
,@AppointmentClinicID int
)
/* Author: <NHall>
** Desc: Processes updates to Doctors Table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Update Appointments
	Set AppointmentDateTime = @AppointmentDateTime
	,AppointmentPatientID = @AppointmentPatientID
	,AppointmentDoctorID = @AppointmentDoctorID
	,AppointmentClinicID = @AppointmentClinicID
	Where AppointmentID = @AppointmentID;
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

Create Procedure pDelAppointments
(@AppointmentID int)
/* Author: <NHall>
** Desc: Processes deletions to Appointments table
** Change Log: When,Who,What
** <2020-05-26>,<Nick Hall>,Created Sproc.
*/
AS
 Begin -- Body
  Declare @RC int = 0;
  Begin Try
   Begin Transaction; 
    -- Transaction Code --
	Delete
	From Appointments
	 Where AppointmentID = @AppointmentID;
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

--Stored Proc testing

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pInsClinics 
 @ClinicName = 'Swedish'
 ,@ClinicPhoneNumber = '253-123-2132'
 ,@ClinicAddress = '1234 4th ave N'
 ,@ClinicCity = 'Seattle'
 ,@ClinicState = 'WA'
 ,@ClinicZipCode = '98105'
;
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Clinics;

*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pUpdClinics 
 @ClinicID = 1
 ,@ClinicName = 'Hospital'
 ,@ClinicPhoneNumber = '253-123-2132'
 ,@ClinicAddress = '1234 4th ave N'
 ,@ClinicCity = 'Seattle'
 ,@ClinicState = 'WA'
 ,@ClinicZipCode = '98105'
;
 Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Clinics;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pDelClinics
 @ClinicID = 1;
 Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Clinics;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pInsPatients
 @PatientFirstName = 'Nick'
 ,@PatientLastName = 'Hall'
 ,@PatientPhoneNumber = '253-123-4567'
 ,@PatientAddress = '1234 5th ave S'
 ,@PatientCity = 'Seattle'
 ,@PatientState = 'WA'
 ,@PatientZipCode = '12345'
;
 Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Patients;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pUpdPatients 
 @PatientID = 1
 ,@PatientFirstName = 'Joe'
 ,@PatientLastName = 'Hall'
 ,@PatientPhoneNumber = '253-123-4567'
 ,@PatientAddress = '1234 5th ave S'
 ,@PatientCity = 'Seattle'
 ,@PatientState = 'WA'
 ,@PatientZipCode = '12345'
;
 Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Patients;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pDelPatients 
 @PatientID = 1;
 Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Patients;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pInsDoctors
 @DoctorFirstName = 'Phil'
 ,@DoctorLastName = 'Null'
 ,@DoctorPhoneNumber = '123-123-1234'
 ,@DoctorAddress = '12345 6th ave W'
 ,@DoctorCity = 'Seattle'
 ,@DoctorState = 'WA'
 ,@DoctorZipCode = '12345'
;
 PSelect Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Doctors;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pUpdDoctors
 @DoctorID = 1
 ,@DoctorFirstName = 'Joe'
 ,@DoctorLastName = 'Small'
 ,@DoctorPhoneNumber = '123-232-2323'
 ,@DoctorAddress = '123 1st ave E'
 ,@DoctorCity = 'Seattle'
 ,@DoctorState = 'WA'
 ,@DoctorZipCode = '12343'
;
  Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Doctors;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pDelDoctors 
 @DoctorID = 1;
 Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Doctors;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pInsAppointments
 @AppointmentDateTime = '11/06/2021 11:46'
 ,@AppointmentPatientID = 1
 ,@AppointmentDoctorID = 1
 ,@AppointmentClinicID = 1
;
 Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Appointments;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pUpdAppointments
 @AppointmentID = 1
 ,@AppointmentDateTime = '11/06/2021 11:46'
 ,@AppointmentPatientID = 1
 ,@AppointmentDoctorID = 1
 ,@AppointmentClinicID = 1
;
  Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Appointments;
*/

/* Informal Testing Code:
 Declare @Status int;
 Exec @Status = pDelAppointments
 @AppointmentID = 1;
 Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Common Issues: Duplicate Data'
  End as [Status]
Select [The New ID Was:] = @@IDENTITY
Select * From Appointments;
*/


--Setting permissions

Deny Select, Insert, Update, Delete On Clinics to Public;
Deny Select, Insert, Update, Delete On Patients to Public;
Deny Select, Insert, Update, Delete On Doctors to Public;
Deny Select, Insert, Update, Delete On Appointments to Public;
Grant Select On vClinics to Public;
Grant Select On vPatients to Public;
Grant Select On vDoctors to Public;
Grant Select On vAppointments to Public;
Grant Select On vAppointmentsByPatientsDoctorsAndClinics to Public;
Grant Execute On pInsClinics to Public;
Grant Execute On pUpdClinics to Public;
Grant Execute On pDelClinics to Public;
Grant Execute On pInsPatients to Public;
Grant Execute On pUpdPatients to Public;
Grant Execute On pDelPatients to Public;
Grant Execute On pInsDoctors to Public;
Grant Execute On pUpdDoctors to Public;
Grant Execute On pDelDoctors to Public;
Grant Execute On pInsAppointments to Public;
Grant Execute On pUpdAppointments to Public;
Grant Execute On pDelAppointments to Public;
go


Create View vAppointmentsPerPatient
As Select p.PatientID
,[PatientName] = concat(p.PatientFirstName, ' ', p.PatientLastName)
,[Appointments] = Count(a.AppointmentPatientID)
From Patients as p
Full Outer Join Appointments as a
 on p.PatientID = a.AppointmentPatientID
Group By p.PatientID, p.PatientFirstName, p.PatientLastName
;
go

Create View vAppointmentsPerClinic
As Select c.ClinicID
, c.ClinicName
, [Appointments] = Count(a.AppointmentClinicID)
From Clinics as c
Full Outer Join FinalDB_NHall.dbo.Appointments as a
 on c.ClinicID = a.AppointmentClinicID
Group By c.ClinicID, c.ClinicName
;
go

Create View vAppoinmentsPerDoctor
As Select d.DoctorID
, [DoctorName] = Concat(d.DoctorFirstName, ' ', d.DoctorLastName)
, [Appointments] = Count(a.AppointmentDoctorID)
From Doctors as d
Full Outer Join Appointments as a
 on d.DoctorID = a.AppointmentClinicID
Group By d.DoctorID, d.DoctorFirstName, d.DoctorLastName
;
go

