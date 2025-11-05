/* 1. Create a stored procedure without parameters to show the number of
students per department name.[use ITI DB] */
use iti 

CREATE PROC GetTootsOfStudents AS 
begin
	SELECT COUNT(*)
	FROM Student;
end

exec GetTootsOfStudents
DROP PROC GetTootsOfStudents

/* 2. Create a stored procedure that will check for the # of employees in the
project p1 if they are more than 3 print message to the user “'The number
of employees in the project p1 is 3 or more'” if they are less display a
message to the user “'The following employees work for the project p1'” in
addition to the first name and last name of each one. [Company DB] */
use Company_DB

Create proc checkEmploye AS 
DECLARE @EmployeeCount INT;
DECLARE @ProjectID INT;
begin
	SELECT @ProjectID = Pno
	FROM Works_for
	WHERE Pno = (SELECT Pnumber FROM Project Where Pname = 'p1');

	SELECT @EmployeeCount = COUNT(*)
	FROM Works_for
	WHERE Pno = (SELECT Pnumber FROM Project Where Pname = 'p1');

	IF (@EmployeeCount >= 3)
	BEGIN
		PRINT 'The number of employees in the project p1 is 3 or more';	
	END
	ELSE IF (@EmployeeCount < 3 and @EmployeeCount > 0 )
	BEGIN
		PRINT 'The following employees work for the project p1';

		SELECT E.Fname, E.Lname
        FROM Employee AS E
        JOIN Works_for AS W ON E.Ssn = W.ESSn
		JOIN Project AS P ON W.Pno = P.Pnumber
        WHERE W.Pno = @ProjectID;
	END
	ELSE
	BEGIN
		SELECT 'The Project is not excited'
	END

END

exec checkEmploye

DROP PROC checkEmploye

/*3. Create a stored procedure that will be used in case there is an old employee
has left the project and a new one become instead of him. The procedure
should take 3 parameters (old Emp. number, new Emp. number and the
project number) and it will be used to update works_on table. [Company
DB] */
CReate proc pr_updateEmp 
@oldEmp int, @newEmp int, @proNum int
AS 
Begin 
	if @newEmp in (SELECT SSN FROM Employee)
	begin 
		update Works_for
		SET ESSn = @newEmp
		WHERE ESSn = @oldEmp and Pno = @proNum;
	end
	else
		print 'New employee do not exicted in Employee table '
End

exec pr_updateEmp 521634 , 112233, 500

DROP PROC pr_updateEmp


/*4. add column budget in project table and insert any draft values in it then
then Create an Audit table with the following structure
-------------------------------------------------------------
ProjectNo UserName ModifiedDate Budget_Old Budget_New
p2          Dbo      2008-01-31  95000       200000
-------------------------------------------------------------
This table will be used to audit the update trials on the Budget column
(Project table, Company DB)
Example:
If a user updated the budget column then the project number, user name
that made that update, the date of the modification and the value of the
old and the new budget will be inserted into the Audit table
Note: This process will take place only if the user updated the budget
column
 */
SELECT * FROM Project

Alter table project add budget decimal(10,2)

create table Audit (
	projectNo varchar(20) ,
	UserName varchar(50),
	ModifiedDate datetime default getdate(),
	Budget_Old DECIMAL(10, 2),
	Budget_New DECIMAL(10, 2)
)

SELECT * FROM Audit
truncate table audit

alter trigger tg_AduitProjectBudget on project 
after UPdate AS 
begin
	if update(budget)
		begin
			insert into Audit(projectNo, UserName, Budget_Old, Buget_New)
			select New.Pnumber, SUSER_NAME(), Old.budget, New.budget
			From INSERTED  New
			Inner join DELETED Old 
			ON New.Pnumber = Old.Pnumber 
		end
End

DROP trigger tg_AduitProjectBudget
/*5. Create a trigger to prevent anyone from inserting a new record in the
Department table [ITI DB]
“Print a message for user to tell him that he can’t insert a new record in that
table” */
use iti

Create trigger tr_preventDepartment 
ON Department 
instead of insert 
AS 
Begin 
	print('You can not add anyone col in that table')
END

insert into Department values (80, 'SD', 'JAVA', 'Cairo' , 5, Null)

DROP trigger tr_preventDepartment


/*6. Create a trigger that prevents the insertion Process for Employee table in
March [Company DB].*/
use company_db

create trigger tr_prev_empl_march 
ON Employee
After insert

AS 
Begin
	if (month(getdate()) = 3 )
		begin
			RAISERROR ('Insertion failed. New employees cannot be added during March.', 16, 1);
			ROLLBack
			END
End


/*7. Create a trigger on student table after insert to add Row in Student Audit
table (Server User Name , Date, Note) where note will be “[username]
Insert New Row with Key=[Key Value] in table [table name]” */
use iti

create table Std_audit(
[Server User Name] varchar(50),
Date datetime default getdate(),
note varchar(100)
)

drop table std_audit


alter trigger tr_ins_st
ON Student
After insert
AS 
begin
	insert into Std_audit ([Server User Name], note)
	Select suser_name(), CONCAT(SUSER_NAME(), ' ' ,'Insert New Row with key=', st_id,' '
	, 'in table',' ', 'Student')
	FROM inserted

end

insert into student 
values (15,	'Mohamed',	'Magdy'	,'Cairo',	25	,10	,12)

select * from student
select * from Std_audit

/*8. Create a trigger on student table instead of delete to add Row in Student
Audit table (Server User Name, Date, Note) where note will be“ try to
delete Row with Key=[Key Value]”
 */
 CREATE TRIGGER tr_del_st 
 ON Student instead of delete
 AS
 begin 
	Print('You have not permission to delete that')
	insert into Std_audit ([Server User Name], Note)
 	Select suser_name(), CONCAT('try to delete Row with Key=', st_Id)
	-- Select *
	from deleted
 end

 select * from Student;
 delete from Student
 where St_Id = 14;

 select * from Std_audit;

 drop trigger tr_del_st 


/*10. Display Each Department Name with its instructors. “Use ITI DB”
A) Use XML Auto
B) Use XML Path
 */
 -- Use XML Auto
 SELECT Department.Dept_Name , Instructor.Ins_Name 
 FROM Department 
 INNER JOIN Instructor 
 ON Department.Dept_Id = Instructor.Dept_Id
 order by Department.Dept_Id
 FOR xml auto , ELEMENTS

 -- Use XML Path
 SELECT	Department.Dept_Name '@Department' ,
			Instructor.Ins_Name 'Instructor'
 FROM Department 
 INNER JOIN Instructor 
 ON Department.Dept_Id = Instructor.Dept_Id
 order by Department.Dept_Id
 FOR xml path , ELEMENTS


 /*12. Create a cursor for Employee table that increases
Employee salary by 10% if Salary <3000 and increases it by
20% if Salary >=3000. Use company DB */

use Company_DB

declare c1 cursor
for select SSN, Salary FROM Employee

for read only -- foor update
declare @id int, @sal int, @newsal int
open c1
fetch NEXT FROM c1 into @id, @sal
while @@FETCH_STATUS =0 
	begin
	if @sal < 3000 
		SET @newsal = @sal * 1.1
	else
		SET @newsal = @sal * 1.2

	update Employee
	set Salary = @newsal
	where SSN = @id
	fetch NEXT FROM c1 into @id, @sal

	end
close c1
DEALLOCATE c1;

/*13. Display Department name with its manager name using
cursor. Use ITI DB */
USE ITI

declare @nameDept varchar(40), @nameIns varchar(40)
declare c1 cursor  for 
SELECT D.Dept_Name, I.Ins_Name
FROM Department D
INNER JOIN Instructor I
on D.Dept_Manager= I.Ins_Id

open c1
fetch next from c1 into @nameDept ,@nameIns

while @@FETCH_STATUS = 0
begin
PRINT @nameDept + ' (Manager: ' + @nameIns + ')';
fetch next from c1 into @nameDept ,@nameIns
end

close c1;
deallocate c1;



/*14. Try to display all students first name in one cell
separated by comma. Using Cursor */
use iti
DECLARE @Fname VARCHAR(50);

DECLARE @AllNames VARCHAR(MAX);
SET @AllNames = ''; 

DECLARE c1 CURSOR FOR
    SELECT St_Fname 
    FROM Student
    WHERE St_Fname IS NOT NULL; 

OPEN c1;

FETCH NEXT FROM c1 INTO @Fname;

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @AllNames = @AllNames + @Fname + ', '; 
    
    FETCH NEXT FROM c1 INTO @Fname;
END;

CLOSE c1;
DEALLOCATE c1;

SELECT @AllNames AS All_Student_Names; 


/*15. Create full, differential Backup for SD DB. */
use sd

backup database SD
to disk = 'e:\db\SD_DB.bak'

/*
This command backs up only the changes made since the last full backup. You must have a full backup first for this to be useful.
*/
BACKUP DATABASE SD
TO DISK = 'E:\db\SD_Diff.bak'
WITH DIFFERENTIAL, INIT; -- The 'DIFFERENTIAL' keyword is required.

backup log SD
to disk = 'e:\db\SD_DB.bak'

/*16. Use import export wizard to display students data (ITI
DB) in excel sheet */


/*17. Try to generate script from DB ITI that describes all
tables and views in this DB */
