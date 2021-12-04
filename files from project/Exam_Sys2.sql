-- Examination System 2
---------------------------------------------------------------------------
-- create database and create files and file groups 
BEGIN

create database Examination_System2
on 
  (
   Name=ExamSys_mainA,
   FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys_mainA.mdf',
   SIZE=5,
   MAXSIZE=20,
   FILEGROWTH=2
  ),
  (
  Name=ExamSys2A,
  FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys2A.ndf',
  SIZE=5,
  MAXSIZE=20,
  FILEGROWTH=2
  ),
  FILEGROUP SecondryExamSys 
  (
      Name=ExamSys3A,
	  FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys3A.ndf',
	  SIZE=5,
	  MAXSIZE=20,
	  FILEGROWTH=2
  ),
  (
      Name=ExamSys4A,
	  FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys4A.ndf',
	  SIZE=5,
	  MAXSIZE=20,
	  FILEGROWTH=2
  )
  log on
    (
      Name=ExamSys_logA,
	  FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys_logA.ldf',
	  SIZE=5,
	  MAXSIZE=20,
	  FILEGROWTH=2
  ) 

END





---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- create tables and constraints 

--create schema exs

-- Student Table  -------------------------------------
BEGIN 
create table exs.Students(
    St_Id int primary key not null identity(1,1),
	St_Fname nvarchar(20),
	St_Lname nvarchar(20),
	St_Address nvarchar(max)
)
END

-- Instructor table -------------------------------------
BEGIN
create table exs.Instructor(
    Inst_Id int primary key not null identity(1,1),
	Inst_Fname nvarchar(20),
	Inst_Lname nvarchar(20)
)
END

-- Course table -------------------------------------
BEGIN
create table exs.Course(
    Co_Id int primary key not null identity(1,1),
	Co_Name nvarchar(50),
	Co_MinDegree int,
	Co_MaxDegree int
)
END


-- Exam table -------------------------------------
BEGIN
create table exs.Exam(
    Ex_Id int primary key not null identity(1,1),
	Ex_Type nvarchar(20) check (Ex_Type='exam' OR Ex_Type='corrective'),
	Ex_TotalDegree int,
	Ex_StartTime time,
	Ex_EndTime time,
	Ex_date date,
	Ex_Year date,
	CourseId int foreign key references exs.Course(Co_Id),
	InstId int foreign key references exs.Instructor(Inst_Id),
	--constraint ExCourse_Fk foreign key (CourseId) references exs.Course(Co_Id),
	--constraint Inst_Fk foreign key (CourseId) references exs.Instructor(Inst_Id)
)

alter table exs.Exam 
add  [Ex_Year] int not null
END

-- Question bank table -------------------------------------
BEGIN
create table exs.QuestionBank(
    Q_Id int primary key not null identity(1,1),
	Question nvarchar(max) not null,
	Q_Type nvarchar(20) check (Q_Type='MultipleChoice' OR Q_Type='True&false'),
	Q_Degree int not null,
	Q_CorrectAnswer nvarchar(max) not null,
	CourseId int foreign key references exs.Course(Co_Id),
	InstId int foreign key references exs.Instructor(Inst_Id),
	Ex_Id int foreign key references exs.Exam(Ex_Id),
	--constraint QueCourse_Fk foreign key (CourseId) references exs.Course(Co_Id),
)
END



-- connection tables (many to many) -------------------------------------

-- table Instructor and courses ------------------
BEGIN
create table exs.Inst_Courses(
    InstId int  not null ,
	CourseId int  not null,
	constraint Inst_Courses_Pk primary key (InstId,CourseId),
	constraint Inst_FK1 foreign key (InstId) references exs.Instructor(Inst_Id),
	constraint Course_Fk1 foreign key (CourseId) references exs.Course(Co_Id)
)
END


-- table Courses and Students ------------------
BEGIN
create table exs.Course_Students(
    CourseId int  not null ,
	StuId int  not null,
	constraint Course_Stu_Pk primary key (CourseId,StuId),
	constraint Course_FK2 foreign key (CourseId) references exs.Course(Co_Id),
	constraint Student_Fk2 foreign key (StuId) references exs.Students(St_Id)
)
END


-- table Exam and Students ------------------
BEGIN
create table exs.Exam_Students(
    ExamId int  not null ,
	StuId int  not null,
	constraint Exam_Stu_Pk primary key (ExamId,StuId),
	constraint Exam_FK1 foreign key (ExamId) references exs.Exam(Ex_Id),
	constraint Student_Fk3 foreign key (StuId) references exs.Students(St_Id)
)
END


--============================================================================================
---------------------------------------- Programability --------------------------------------
--============================================================================================

-- Instructor add,update and delete his own question 



-- instructor add question
----------------------------------------------------------------------------------------

 create proc exs.addQuestionToTheBank2(@questionText nvarchar(max),@QuestionType nvarchar(20),@degree int,@CorrectAnswer nvarchar(max),@CourId int,@InstId int)
 as 
 begin
	insert into[exs].[QuestionBank]([Question],[Q_Type],[Q_Degree],[Q_CorrectAnswer],[CourseId],[InstId])
	values(@questionText , @QuestionType , @degree , @CorrectAnswer , @CourId , @InstId)

	return @@ERROR
 end

 exec exs.addQuestionToTheBank2 'java does not need semi colon ', 'True&false', 5 , 'false' , 1,1
 exec exs.addQuestionToTheBank2 'html need compiler ?', 'True&false', 5 , 'false' , 4,4
 exec exs.addQuestionToTheBank2 'C++ not case sensitive?', 'True&false', 5 , 'false' , 3,3
 exec exs.addQuestionToTheBank2 'css case sensitive ?', 'True&false', 5 , 'false' , 5,5
 exec exs.addQuestionToTheBank2 'html case sensitive', 'True&false', 5 , 'false' , 4,4



 -- instructor Update question 
 --(it's questions only and course questions)
------------------------------------------------------------------------------------------
 alter proc exs.UpdateQuestion(@quesId int,@questionText nvarchar(max),@degree int,@CorrectAnswer nvarchar(max),@CourId int,@InstId int)
 as 
 begin
		update [exs].[QuestionBank]
		set [Question]=@questionText,
			[Q_Degree]=@degree,
			[Q_CorrectAnswer]=@CorrectAnswer
			where [Q_Id]=@quesId  and [CourseId]=@CourId and [InstId]=@InstId 

		return @@ERROR
 end

 -- exec proc exs.UpdateQuestion
 exec exs.UpdateQuestion 6,'the updated question',5,'true',3,3    -- no rows affected 
 exec exs.UpdateQuestion 8,'the updated question',5,'true',1,1    -- 1 row affected 

 

 -- instructor delete it's question only
-------------------------------------------------------------------------------------------
alter proc exs.deleteQuestion(@quesId int,@CourId int,@InstId int)
as
begin
   delete [exs].[QuestionBank]
   where [Q_Id]=@quesId  and [CourseId]=@CourId and [InstId]=@InstId 
end

-- exec proc exs.deleteQuestion
exec exs.deleteQuestion 10 , 3 , 4    -- 0  rows affected
exec exs.deleteQuestion 10 , 1 , 1    -- 1  row affected



--============================================================================================
--============================================================================================
-- Instructor add exam for its course

 create proc exs.addExam(@examType nvarchar(20),@totalDegree int,@sTime time,@eTime time,@examDate date,@year int,@CourId int,@InstId int)
 as 
 begin
	insert into [exs].[Exam]([Ex_Type],[Ex_TotalDegree],[Ex_StartTime],[Ex_EndTime],[Ex_date],[Ex_Year],[CourseId],[InstId])
	values(@examType,@totalDegree,@sTime,@eTime,@examDate,@year,@CourId, @InstId)

	return @@ERROR
 end

 -- exec proc exs.addExam
 exec exs.addExam 'exam' ,       100 , '09:00:00' , '12:00:00' , '12/10/2021' , 2021 , 1 , 1
 exec exs.addExam 'corrective' , 100 , '01:00:00' , '03:00:00' , '12/8/2021'  , 2021 , 2 , 2
 exec exs.addExam 'corrective' , 100 , '03:00:00' , '05:00:00' , '01/10/2022' , 2022 , 3 , 3
 exec exs.addExam 'exam' ,       20 , '09:00:00' , '12:00:00' , '12/10/2021' , 2021 , 2 , 2

-----------------------------------------------------------------------------------------------------
-- Instructor add questions to the Exam that he did before .
-- Instructor add questions by the system 

alter proc exs.putQuestionsInExam(@InstId int,@examId int,@examDegree int)
as
begin
        -- variable to be iterator variable in the loop
		DECLARE @n int;
		SET @n = 0;
		-- variable to sum every degree of every question
		Declare @countDegrees int;
		set @countDegrees=0;
		-- @n < number of all questions
		WHILE (@n < (select count(*) FROM [exs].[QuestionBank]))      
		BEGIN 
		  -- if statment to hold instructor questions only
	  if((select [InstId] FROM [exs].[QuestionBank] where [Q_Id]=@n)= @InstId)

			  begin ------=====================

			   -- variable to hold the degree of the current question
			   declare @currentDegree int;  
			   set  @currentDegree=(select [Q_Degree] FROM [exs].[QuestionBank] WHERE [InstId]=@InstId and [Q_Id]=@n)

			   -- check if the sum of degrees will be bigger than the degree of the exam
			   if(@countDegrees + @currentDegree > @examDegree)
				 begin 
				   break;
				  end
			   else
				begin
						  set @countDegrees = @countDegrees + @currentDegree;
						  -- to update the EX_Id column in the question row
						  update [exs].[QuestionBank]
						  set [Ex_Id]=@examId
	            		  where [InstId]=@InstId and [Q_Id]=@n
				 end
				 set @n=@n+1;
			  end ---===========================
	  else
		   begin
		   set @n=@n+1;
		   continue;
		  end
			 
		END 
end	
GO

-- exec  proc exs.putQuestionsInExam
exec exs.putQuestionsInExam 1 , 5 ,25
exec exs.putQuestionsInExam 4 , 3 ,20

-----------------------------------------------------------------------------------------------------
-- Instructor add questions to the Exam that he did before .
-- Instructor add questions manually

alter proc exs.putQuestionsInExamManually(@quesId int,@InstId int,@examId int)
as
begin    
 -- if statment to check if he has questions
 if exists(select * FROM [exs].[QuestionBank] WHERE [InstId]=@InstId and [Q_Id]=@quesId )
	begin
	   -- to update the EX_Id column in the question row
	  update [exs].[QuestionBank]
      set [Ex_Id]=@examId
      where [InstId]=@InstId and [Q_Id]=@quesId

	end
 Else
	begin
		print 'the question Not Found';
	end

   return @@ERROR
end

-- exec  proc exs.putQuestionsInExamManually
exec  exs.putQuestionsInExamManually 5 , 2 , 6  -- the question not found
exec  exs.putQuestionsInExamManually 7 , 4 , 2  -- 1 row affected



--============================================================================================
--============================================================================================
-- students take exam


--------------------------------the start of the function------------------------------------------------
alter function studentInExam(@studentId int, @examId int) 
returns @StuDegrees table
		(
		 stuId int  default 1 ,
		 examId int ,
		 quesId int primary key identity(1,1),
		 stuAnswer nvarchar(20),
		 correctAnswer nvarchar(20),
		 quesDegree int,
		 stuQuesDegree int

		)
as
begin

        -- insert some columns from table [exs].[QuestionBank]
        insert into @StuDegrees(examId,quesDegree,correctAnswer)
		select [Ex_Id],[Q_Degree],[Q_CorrectAnswer]
		from [exs].[QuestionBank]
		where [Ex_Id]=@examId 

		declare @a int;         -- variable to itarate the loop
		declare @count int;     -- variable to count questions that belong to the specific exam

		set @count =  (select count(*)
		from [exs].[QuestionBank]
		where [Ex_Id]=@examId)

		set @a=1;
		while(@a<=@count)
		begin

		  -- declare var to hold student answer for sepesific question
		  declare @stuQuesAns nvarchar(20);
		  set   @stuQuesAns = ( select quesAnswer from studentAnswersFun() where quesId=@a)
       
		  -- declare var to hold the correct answer for sepesific question
		  declare @correctQuesAns nvarchar(20);
		  set   @correctQuesAns = ( select correctAnswer from @StuDegrees where quesId=@a)                   


		  update @StuDegrees
		  set stuId=@studentId,stuAnswer=@stuQuesAns 
		  where quesId=@a
		  
		  -- if statment to compare the student answer for every question
		  -- and update the student degree with question degree if it correct
		  if(@stuQuesAns = @correctQuesAns) 
			  begin
			  update @StuDegrees
			  set  stuQuesDegree=5 
			  where quesId=@a
			  end
		  else 
			  begin
			  update @StuDegrees
			  set  stuQuesDegree=0 
			  where quesId=@a
			  end
		  set @a=@a+1
		end
return
end
--------------------------------the end of function------------------------------------------------
-- call the function
select sum(stuQuesDegree) from studentInExam(1,5)
select * from studentInExam(1,5)

-------------------------------------------------------------------------
-- function to get table of student answers

 alter function studentAnswersFun()
 returns table 
 as 
   return  (select * from [dbo].[studentAnswers])
 
 -----------------------------------------------------
 -- to call the function
 select quesAnswer from studentAnswersFun()
 where quesId=1
  select * from studentAnswersFun()
--------------------------------------------------------------------
-- table of student answers

create table studentAnswers
	(
	  studentId int,
	  quesId int primary key identity(1,1),
	  quesAnswer nvarchar(20)
	)

----------------------------------------------------------------------
-- insert answers into the table of student answers

insert into studentAnswers(studentId,quesAnswer)
values (1,'true'),(1,'true'),(1,'false'),(1,'false'),(1,'true')









--============================================================================================
--============================================================================================
-- display student info after taking exam

--------------------------------the start of the function------------------------------------------------
alter function displayStudentInfo(@studentId int) 
returns @studentInfo table
		(
		 stuId int  default 1 ,
		 stuName nvarchar(max),
		 stuCourse nvarchar(20),
		 maxDegree int,
		 minDegree int,
		 stuDegree int,
		 studentCase nvarchar(20)
		)
as
begin
      
        insert into @studentInfo(stuId,stuName,stuCourse,maxDegree,minDegree)
		select [St_Id],([St_Fname]+' '+[St_Lname]),[Co_Name],[Co_MaxDegree],[Co_MinDegree]
		from [exs].[Course] cour inner join [exs].[Students] stu
		on  cour.Co_Id=stu.St_Id and stu.St_Id=@studentId

		-- define variable to hold exam id for the student
		declare @examid int;
		set @examid=(select [ExamId] from [exs].[Exam_Students] where [StuId] = @studentId);

		-- define variable to hold specific student degree on spesific course
		declare @total int;
		set @total=(select sum(stuQuesDegree) from studentInExam(@studentId,@examid));

		-- define variable to hold min degree for spesific course
		declare @min int;
		set @min=(select [Co_MinDegree] from [exs].[Course] where [Co_Id]=@studentId);

		-- if statment to check the total student degree with the min degree
		-- and update the student case with 'passed' or 'fail'
		if(@total>=@min)
		update @studentInfo
		set stuDegree=@total,studentCase='passed'
		where stuId=@studentId

		else
		update @studentInfo
		set stuDegree=@total,studentCase='fail'
		where stuId=@studentId

return
end

-- call the function
select * from displayStudentInfo(1)

--====================================================================================
-- display exam info 
create function displayExamInfo(@examId int)
returns table
as
return (select * from [exs].[Exam] where [Ex_Id]=@examId)

----------------------------------
-- call the function
select * from displayExamInfo(1);

--====================================================================================
-- display all courses

create view allCourses
as 
( select * from [exs].[Course]
)
select * from allCourses