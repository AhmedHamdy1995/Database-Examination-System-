-- Examination System
---------------------------------------------------------------------------
-- create database and create files and file groups 
BEGIN

create database Examination_System
on 
  (
   Name=ExamSys_main,
   FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys_main.mdf',
   SIZE=5,
   MAXSIZE=20,
   FILEGROWTH=2
  ),
  (
  Name=ExamSys2,
  FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys2.ndf',
  SIZE=5,
  MAXSIZE=20,
  FILEGROWTH=2
  ),
  FILEGROUP SecondryExamSys 
  (
      Name=ExamSys3,
	  FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys3.ndf',
	  SIZE=5,
	  MAXSIZE=20,
	  FILEGROWTH=2
  ),
  (
      Name=ExamSys4,
	  FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys4.ndf',
	  SIZE=5,
	  MAXSIZE=20,
	  FILEGROWTH=2
  )
  log on
    (
      Name=ExamSys_log,
	  FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys_log.ldf',
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

-- Question bank table -------------------------------------
BEGIN
create table exs.QuestionBank(
    Q_Id int primary key not null identity(1,1),
	Q_Type bit,
	Q_Degree int,
	Q_CorrectAnswer nvarchar(max),
	CourseId int foreign key references exs.Course(Co_Id)
	--constraint QueCourse_Fk foreign key (CourseId) references exs.Course(Co_Id),
)
END

-- Exam table -------------------------------------
BEGIN
create table exs.Exam(
    Ex_Id int primary key not null identity(1,1),
	Ex_Type bit,
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
-- table Instructor and Students ------------------
BEGIN
create table exs.Inst_Students(
    InstId int  not null ,
	StuId int  not null,
	constraint Inst_Stu_Pk primary key (InstId,StuId),
	constraint Inst_FK2 foreign key (InstId) references exs.Instructor(Inst_Id),
	constraint Student_Fk1 foreign key (StuId) references exs.Students(St_Id)
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

-- table Exam and Questions ------------------
BEGIN
create table exs.Exam_Question(
    ExamId int  not null ,
	QuesId int  not null,
	constraint Exam_Ques_Pk primary key (ExamId,QuesId),
	constraint Exam_FK2 foreign key (ExamId) references exs.Exam(Ex_Id),
	constraint Ques_Fk1 foreign key (QuesId) references exs.QuestionBank(Q_Id)
)
END


----------------------------------------------------------------------------
----------------------------------------------------------------------------



