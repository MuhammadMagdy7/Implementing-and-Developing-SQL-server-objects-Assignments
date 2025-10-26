/*
Note: Use ITI DB
1. Create a view that displays student full name, course name if the student
has a grade more than 50
*/
USE ITI;

CREATE VIEW Vst_grede AS
SELECT CONCAT_WS(' ', St_Fname, St_Lname) AS [Full Name], C.Crs_Name
From Student S INNER JOIN Stud_Course SC
ON S.St_Id = SC.St_Id
INNER JOIN Course C
ON SC.Crs_Id = C.Crs_Id
WHERE SC.Grade > 50;

SELECT * FROM Vst_grede;

-- 2. Create an Encrypted view that displays manager names and the topics they teach.
CREATE VIEW VManTopic 
WITH ENCRYPTION
AS
SELECT DISTINCT I.Ins_Name [Ins Name], T.Top_Name [Top Name]
FROM Instructor I
INNER JOIN Ins_Course IC
ON I.Ins_Id = IC.Ins_Id
INNER JOIN Department D
ON I.Ins_Id = D.Dept_Manager
INNER JOIN Course C
ON IC.Crs_Id = C.Crs_Id
INNER JOIN Topic T
ON T.Top_Id = C.Top_Id;

SELECT * FROM VManTopic
ORDER BY Ins_Name;

DROP VIEW VManTopic;

--3. Create a view that will display Instructor Name, Department Name for the ‘SD’ or ‘Java’ Department
CREATE VIEW VIns_Dept AS
SELECT I.Ins_Name [Ins Name], D.Dept_Name [Dept Name]
FROM Instructor I
INNER JOIN Department D ON I.Dept_Id = D.Dept_Id
WHERE D.Dept_Name IN ('SD', 'Java');

SELECT * FROM VIns_Dept;

DROP VIEW VIns_Dept;

/*
4. Create a view “V1” that displays student data for student who lives in
Alex or Cairo.
Note: Prevent the users to run the following query
Update V1 set st_address=’tanta’
Where st_address=’alex’;
*/
CREATE VIEW V1 AS
SELECT *
FROM Student 
WHERE st_address IN ('Alex', 'Cairo')
WITH CHECK OPTION;

SELECT * FROM V1;

DROP VIEW V1;

--5. Create a view that will display the project name and the number of employees work on it. “Use SD database”
USE sd;

CREATE VIEW VPr_Emp AS
SELECT ProjectNo Pro_No, Count(EmpNo) AS [Count of Emp]
FROM Works_on
GROUP BY ProjectNo

SELECT * FROM VPr_Emp 

DROP VIEW VPr_Emp;

--6. Create index on column (Hiredate) that allow u to cluster the data in table Department. What will happen?
use ITI
CREATE Clustered index i2 
ON Department(manager_hiredate)

-- error - Cannot create more than one clustered index on table 'Department'. Drop the existing clustered index 'PK_Department' before creating another.
CREATE nonClustered index i2 
ON Department(manager_hiredate)

drop index i2
ON Department

--7. Create index that allow u to enter unique ages in student table. What will happen?
CREATE nonClustered index i3 
ON Student(st_age)

drop index i3
ON Student

--8. Using Merge statement between the following two tables [User ID, Transaction Amount]
-- Create the Target table
CREATE TABLE Last_Transactions (
    UserID INT PRIMARY KEY,
    Amount INT
);

-- Create the Source table
CREATE TABLE Daily_Transactions (
    UserID INT,
    Amount INT
);

-- Insert data from your image
INSERT INTO Last_Transactions (UserID, Amount)
VALUES
(1, 4000),
(4, 2000),
(2, 10000);

INSERT INTO Daily_Transactions (UserID, Amount)
VALUES
(1, 1000),
(2, 2000),
(3, 1000);

PRINT '--- BEFORE MERGE ---';
SELECT * FROM Last_Transactions;

-- I can't find backup file for SD_DB in mahara-tech
/*
Part2: use SD_DB
1) Create view named “v_clerk” that will display employee#,project#, the date of hiring of
all the jobs of the type 'Clerk'.
*/

/*
2) Create view named “v_without_budget” that will display all the projects data
without budget
*/

/*
3) Create view named “v_count “ that will display the project name and the # of jobs in it
*/

/*
4) Create view named ” v_project_p2” that will display the emp# for the project# ‘p2’
use the previously created view “v_clerk”
*/

--5) modifey the view named “v_without_budget” to display all DATA in project p1 and p2

-- 6) Delete the views “v_ clerk” and “v_count”


-- 7) Create view that will display the emp# and emp lastname who works on dept# is ‘d2’


/*
8) Display the employee lastname that contains letter “J”
Use the previous view created in Q#7
*/


-- 9) Create view named “v_dept” that will display the department# and department name.


/*
10) using the previous view try enter new department data where dept# is ’d4’ and dept
name is ‘Development’
*/


/*
11) Create view name “v_2006_check” that will display employee#, the project #where he
works and the date of joining the project which must be from the first of January and
the last of December 2006.
*/