-- Use ITI DB
use ITI

-- 1. Create a scalar function that takes date and returns Month name of that date.
CREATE FUNCTION getMonth(@date date)	returns varchar(10)	BEGIN 		declare @month varchar(10) = DATENAME(month,@date)		return @month	END-- callingselect dbo.getMonth('2025-10-21')Drop function dbo.getMonth/*2. Create a multi-statements table-valued function that takes 2 integers and
returns the values between them.*/CREATE FUNCTION RetSal(@from int, @to int)	returns @t table(		id int,		salary int	) 		as 		begin			INSERT INTO @t (id, salary)			SELECT Ins_id, Salary			FROM Instructor			WHERE Salary between @from and @to		return		end-- callingSELECT * FROM dbo.RetSal(1000, 3000)Drop function dbo.RetSal-- same example but with inline funcationCREATE FUNCTION RetSalInline(@from int, @to int)	returns table		as return(			SELECT Ins_id, Salary			FROM Instructor			WHERE Salary between @from and @to			)-- callingSELECT * FROM dbo.RetSalInline(1000, 3000)Drop function dbo.RetSalInline/*3. Create inline function that takes Student No and returns Department
Name with Student full name.*/CREATE FUNCTION RetFnameDp(@id int)	returns table		as return(			SELECT CONCAT( S.St_Fname,' ', S.St_Lname) as FullName, D.Dept_Name 			FROM Student S INNER JOIN Department D ON S.Dept_Id = D.Dept_Id			WHERE S.St_Id = @id			)SELECT * FROM dbo.RetFnameDp(5)Drop function dbo.RetFnameDp/*4. Create a scalar function that takes Student ID and returns a message to
user
a. If first name and Last name are null then display 'First name &
last name are null'
b. If First name is null then display 'first name is null'
c. If Last name is null then display 'last name is null'
d. Else display 'First name & last name are not null'
*/
CREATE FUNCTION CheckMes(@id int)
	returns varchar(50)
	as
	begin
		declare @message varchar(50)

		declare @Fname varchar(50)
		declare @Lname varchar(50)
		
		SELECT @Fname=St_Fname ,@Lname=St_Lname
		from Student WHERE St_Id = @id

		if @Fname IS NULL AND @Lname IS NULL
			SET @message='First name & last name are null' 
		ELSE IF @Fname IS NULL
			SET @message='first name is null'
		ELSE IF @Lname IS NULL
			SET @message='last name is null'
		return @message
	end


SELECT * FROM Student

SELECT dbo.CheckMes(14)
DROP FUNCTION dbo.CheckMes


/*
5. Create inline function that takes integer which represents manager ID
and displays department name, Manager Name and hiring date
*/

CREATE FUNCTION getManager(@id int)
	returns table
	as 
		return (
			SELECT D.Dept_Manager, I.Ins_Name, D.Manager_hiredate
			FROM Department D
			INNER JOIN Instructor I
			ON D.Dept_Manager = I.Ins_Id
			WHERE D.Dept_Manager = @id
			)
		
SELECT * FROM Department

SELECT * FROM dbo.getManager(2)
DROP FUNCTION dbo.getManager


/*
6. Create multi-statements table-valued function that takes a string
If string='first name' returns student first name
If string='last name' returns student last name
If string='full name' returns Full Name from student table
Note: Use “ISNULL” function
*/

CREATE FUNCTION ReName(@str varchar(20))
	returns @t table(
		name varchar(20)
	) as 
		begin
			if @str = 'first name'
				insert into @t
				SELECT ISNULL(St_Fname, 'None First name') FROM Student
			else if @str = 'last name'
				insert into @t
				SELECT ISNULL(St_Lname, 'None Last name') FROM Student
			else if @str = 'full name'
				insert into @t
				SELECT ISNULL(CONCAT(St_Fname, ' ', St_Lname), 'None Full name') FROM Student
		return
		end

SELECT * FROM Student

SELECT * FROM dbo.ReName('full name')
DROP FUNCTION dbo.ReName
	
/*
7. Write a query that returns the Student No and Student first name
without the last char
*/
SELECT
    St_id,
    LEFT(St_Fname, LEN(St_Fname) - 1) AS FirstNameWithoutLastChar
FROM
    Student;

/*
8. Write query to delete all grades for the students Located in SD
Department
*/
Select COUNT(*) FROM Stud_Course

DELETE C
FROM Stud_Course C 
INNER JOIN Student S ON C.St_Id = S.St_Id
WHERE S.Dept_Id = (SELECT Dept_Id FROM Department WHERE Dept_Name = 'SD')

Select COUNT(*) FROM Stud_Course
