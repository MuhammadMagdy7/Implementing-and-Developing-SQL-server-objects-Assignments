/*
1-Create it by code
2-Create a new user data type
named loc with the following
Criteria:
● nchar(2)
● default:NY
● create a rule for this
Datatype :values in
(NY,DS,KW)) and
associate it to the
location column
*/

CREATE TABLE Department (
	DeptNo varchar(20) primary key,
	DeptName varchar(20),
	Location nchar(2) default 'NY'
	constraint c1 check (Location in ('NY','DS','KW'))
)

/*
1-Create it by code
2-PK constraint on EmpNo
3-FK constraint on DeptNo
4-Unique constraint on Salary
5-EmpFname, EmpLname
don’t accept null values
6-Create a rule on Salary
column to ensure that it is less
than 6000
*/

CREATE TABLE Employee (
	EmpNo int primary key ,
	EmpFname varchar(20) NOT NULL,
	EmpLname varchar(20) NOT NULL,
	DeptNo varchar(20),
	Salary int unique,
	CONSTRAINT c2 FOREIGN KEY (DeptNo) REFERENCES Department(DeptNo),
	CONSTRAINT c3 check (Salary < 6000)
)


-- Testing Referential Integrity 4-Delete the employee with id 10102
delete from Employee
where EmpNo = 10102

/*
Msg 547, Level 16, State 0, Line 46
The DELETE statement conflicted with the REFERENCE constraint "FK_Works_on_Employee". The conflict occurred in database "sd"
*/
-- -------------------------------------
/*
Table modification
1-Add TelephoneNumber column to the employee table[programmatically]
2-drop this column[programmatically]
3-Bulid A diagram to show Relations between tables
*/


ALTER Table Employee ADD TelephoneNumber varchar(20)

ALTER Table Employee DROP COLUMN TelephoneNumber


/*
2. Create the following schema and transfer the following tables to it
a. Company Schema
i. Department table (Programmatically)
ii. Project table (using wizard)
b. Human Resource Schema
i. Employee table (Programmatically)
*/

CREATE SChema Company

CREATE TABLE Company.Department (
	DeptNo varchar(20) primary key,
	DeptName varchar(20),
	Location nchar(2) default 'NY'
	constraint c1 check (Location in ('NY','DS','KW'))
)

CREATE SCHEMA HumanResource

CREATE TABLE HumanResource.Employee (
	EmpNo int primary key ,
	EmpFname varchar(20) NOT NULL,
	EmpLname varchar(20) NOT NULL,
	DeptNo varchar(20),
	Salary int unique,
	CONSTRAINT c2 FOREIGN KEY (DeptNo) REFERENCES Company.Department(DeptNo),
	CONSTRAINT c3 check (Salary < 6000)
)

-- 3. Write query to display the constraints for the Employee table.
-- Copies data from old schema to new schema 
INSERT INTO Company.Department (DeptNo, DeptName, Location)
SELECT DeptNo, DeptName, Location
FROM dbo.Department;

INSERT INTO HumanResource.Employee (EmpNo ,	EmpFname,EmpLname,DeptNo, Salary)
SELECT EmpNo ,	EmpFname,EmpLname,DeptNo, Salary
FROM dbo.Employee;

SELECT DE.DeptNo, Salary
FROM HumanResource.Employee HE
INNER JOIN Company.Department DE
on HE.DeptNo = DE.DeptNo

/*
4. Create Synonym for table Employee as Emp and then run the
following queries and describe the results
a. Select * from Employee
b. Select * from [Human Resource].Employee
c. Select * from Emp
d. Select * from [Human Resource].Emp
*/

CREATE SYNONYM Emp FOR Employee;
Select * from Employee
Select * from [HumanResource].Employee
Select * from EmpSelect * from [HumanResource].Emp

-- 5. Increase the budget of the project where the manager number is 10102 by 10%.
update [HumanResource].Employee 
set Salary = Salary * 1.10 
WHERE EmpNo = 10102

/*
6. Change the name of the department for which the employee named
James works.The new department name is Sales.
*/

update Company.Department 
set DeptName = 'Sales'
WHERE DeptNo IN (SELECT DeptNo FROM [HumanResource].Employee WHERE EmpFname = 'James')

/*
7. Change the enter date for the projects for those employees who work
in project p1 and belong to department ‘Sales’. The new date is
12.12.2007.
*/
update Works_on
set Enter_Date = '12.12.2007'
WHERE  EmpNo IN (SELECT E.EmpNo FROM Employee E INNER JOIN Company.Department D
				 ON E.DeptNo = D.DeptNo WHERE D.DeptName = 'Sales')
		AND ProjectNo = 'p1'

/*
8. Delete the information in the works_on table for all employees who
work for the department located in KW.
*/
DELETE
FROM Works_on
WHERE EmpNo IN (SELECT E.EmpNo FROM Employee E INNER JOIN Company.Department D
				 ON E.DeptNo = D.DeptNo WHERE D.Location = 'KW') 


/*
9. Try to Create Login Named(ITIStud) who can access Only student and
Course tablesfrom ITI DB then allow him to select and insert data into
tables and deny Delete and update .(Use ITI DB)
*/
USE master;
GO
CREATE LOGIN ITIStud
WITH PASSWORD = 'Mm123456789#'; -- الرجاء استخدام كلمة مرور قوية
GO
USE ITI;
GO
CREATE USER ITIStud FOR LOGIN ITIStud;
GO
GRANT SELECT, INSERT ON student TO ITIStud;
GRANT SELECT, INSERT ON Course TO ITIStud;
DENY UPDATE, DELETE ON student TO ITIStud;
DENY UPDATE, DELETE ON Course TO ITIStud;
GO

-- other comands
DROP SChema Company
drop table Employee