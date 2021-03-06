USE [master]
GO
/****** Object:  Database [Examination_System2]    Script Date: 10/3/2021 12:17:42 AM ******/
CREATE DATABASE [Examination_System2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ExamSys_mainA', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys_mainA.mdf' , SIZE = 8192KB , MAXSIZE = 20480KB , FILEGROWTH = 2048KB ),
( NAME = N'ExamSys2A', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys2A.ndf' , SIZE = 5120KB , MAXSIZE = 20480KB , FILEGROWTH = 2048KB ), 
 FILEGROUP [SecondryExamSys] 
( NAME = N'ExamSys3A', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys3A.ndf' , SIZE = 5120KB , MAXSIZE = 20480KB , FILEGROWTH = 2048KB ),
( NAME = N'ExamSys4A', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys4A.ndf' , SIZE = 5120KB , MAXSIZE = 20480KB , FILEGROWTH = 2048KB )
 LOG ON 
( NAME = N'ExamSys_logA', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\ExamSys_logA.ldf' , SIZE = 5120KB , MAXSIZE = 20480KB , FILEGROWTH = 2048KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [Examination_System2] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Examination_System2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Examination_System2] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Examination_System2] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Examination_System2] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Examination_System2] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Examination_System2] SET ARITHABORT OFF 
GO
ALTER DATABASE [Examination_System2] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Examination_System2] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Examination_System2] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Examination_System2] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Examination_System2] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Examination_System2] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Examination_System2] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Examination_System2] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Examination_System2] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Examination_System2] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Examination_System2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Examination_System2] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Examination_System2] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Examination_System2] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Examination_System2] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Examination_System2] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Examination_System2] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Examination_System2] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Examination_System2] SET  MULTI_USER 
GO
ALTER DATABASE [Examination_System2] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Examination_System2] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Examination_System2] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Examination_System2] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Examination_System2] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Examination_System2] SET QUERY_STORE = OFF
GO
USE [Examination_System2]
GO
/****** Object:  Schema [exs]    Script Date: 10/3/2021 12:17:42 AM ******/
CREATE SCHEMA [exs]
GO
/****** Object:  UserDefinedTableType [dbo].[stuAnswersType]    Script Date: 10/3/2021 12:17:42 AM ******/
CREATE TYPE [dbo].[stuAnswersType] AS TABLE(
	[stuId] [int] NULL,
	[stuquesId] [int] IDENTITY(1,1) NOT NULL,
	[answer] [nvarchar](50) NULL,
	PRIMARY KEY CLUSTERED 
(
	[stuquesId] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedFunction [dbo].[displayStudentInfo]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------the start of the function------------------------------------------------
CREATE function [dbo].[displayStudentInfo](@studentId int) 
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

		if(@total>@min)
		update @studentInfo
		set stuDegree=@total,studentCase='passed'
		where stuId=@studentId

		else
		update @studentInfo
		set stuDegree=@total,studentCase='fail'
		where stuId=@studentId

return
end
GO
/****** Object:  UserDefinedFunction [dbo].[studentInExam]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--------------------------------the start of the function------------------------------------------------
CREATE function [dbo].[studentInExam](@studentId int, @examId int) 
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

       
        insert into @StuDegrees(examId,quesDegree,correctAnswer)
		select [Ex_Id],[Q_Degree],[Q_CorrectAnswer]
		from [exs].[QuestionBank]
		where [Ex_Id]=@examId 

		declare @a int;
		declare @count int;

		set @count =  (select count(*)
		from [exs].[QuestionBank]
		where [Ex_Id]=@examId)

		set @a=1;
		while(@a<=@count)
		begin

		  declare @stuQuesAns nvarchar(20);
		  set   @stuQuesAns = ( select quesAnswer from studentAnswersFun() where quesId=@a)
          declare @correctQuesAns nvarchar(20);
		  set   @correctQuesAns = ( select correctAnswer from @StuDegrees where quesId=@a)                   

		  update @StuDegrees
		  set stuId=@studentId,stuAnswer=@stuQuesAns 
		  where quesId=@a
		  
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
GO
/****** Object:  Table [dbo].[studentAnswers]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[studentAnswers](
	[studentId] [int] NULL,
	[quesId] [int] IDENTITY(1,1) NOT NULL,
	[quesAnswer] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[quesId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[studentAnswersFun]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE function [dbo].[studentAnswersFun]()
 returns table 
 as 
   return  (select * from [dbo].[studentAnswers])
GO
/****** Object:  Table [exs].[Exam]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [exs].[Exam](
	[Ex_Id] [int] IDENTITY(1,1) NOT NULL,
	[Ex_Type] [nvarchar](20) NULL,
	[Ex_TotalDegree] [int] NULL,
	[Ex_StartTime] [time](7) NULL,
	[Ex_EndTime] [time](7) NULL,
	[Ex_date] [date] NULL,
	[CourseId] [int] NULL,
	[InstId] [int] NULL,
	[Ex_Year] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Ex_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[displayExamInfo]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[displayExamInfo](@examId int)
returns table
as
return (select * from [exs].[Exam] where [Ex_Id]=@examId)
GO
/****** Object:  Table [exs].[Course]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [exs].[Course](
	[Co_Id] [int] IDENTITY(1,1) NOT NULL,
	[Co_Name] [nvarchar](50) NULL,
	[Co_MinDegree] [int] NULL,
	[Co_MaxDegree] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Co_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[allCourses]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[allCourses]
as 
( select * from [exs].[Course]
)
GO
/****** Object:  Table [exs].[Course_Students]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [exs].[Course_Students](
	[CourseId] [int] NOT NULL,
	[StuId] [int] NOT NULL,
 CONSTRAINT [Course_Stu_Pk] PRIMARY KEY CLUSTERED 
(
	[CourseId] ASC,
	[StuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [exs].[Exam_Students]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [exs].[Exam_Students](
	[ExamId] [int] NOT NULL,
	[StuId] [int] NOT NULL,
 CONSTRAINT [Exam_Stu_Pk] PRIMARY KEY CLUSTERED 
(
	[ExamId] ASC,
	[StuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [exs].[Inst_Courses]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [exs].[Inst_Courses](
	[InstId] [int] NOT NULL,
	[CourseId] [int] NOT NULL,
 CONSTRAINT [Inst_Courses_Pk] PRIMARY KEY CLUSTERED 
(
	[InstId] ASC,
	[CourseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [exs].[Instructor]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [exs].[Instructor](
	[Inst_Id] [int] IDENTITY(1,1) NOT NULL,
	[Inst_Fname] [nvarchar](20) NULL,
	[Inst_Lname] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[Inst_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [exs].[QuestionBank]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [exs].[QuestionBank](
	[Q_Id] [int] IDENTITY(1,1) NOT NULL,
	[Question] [nvarchar](max) NOT NULL,
	[Q_Type] [nvarchar](20) NULL,
	[Q_Degree] [int] NOT NULL,
	[Q_CorrectAnswer] [nvarchar](max) NOT NULL,
	[CourseId] [int] NULL,
	[InstId] [int] NULL,
	[Ex_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Q_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [exs].[Students]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [exs].[Students](
	[St_Id] [int] IDENTITY(1,1) NOT NULL,
	[St_Fname] [nvarchar](20) NULL,
	[St_Lname] [nvarchar](20) NULL,
	[St_Address] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[St_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [exs].[Course_Students]  WITH CHECK ADD  CONSTRAINT [Course_FK2] FOREIGN KEY([CourseId])
REFERENCES [exs].[Course] ([Co_Id])
GO
ALTER TABLE [exs].[Course_Students] CHECK CONSTRAINT [Course_FK2]
GO
ALTER TABLE [exs].[Course_Students]  WITH CHECK ADD  CONSTRAINT [Student_Fk2] FOREIGN KEY([StuId])
REFERENCES [exs].[Students] ([St_Id])
GO
ALTER TABLE [exs].[Course_Students] CHECK CONSTRAINT [Student_Fk2]
GO
ALTER TABLE [exs].[Exam]  WITH CHECK ADD FOREIGN KEY([CourseId])
REFERENCES [exs].[Course] ([Co_Id])
GO
ALTER TABLE [exs].[Exam]  WITH CHECK ADD FOREIGN KEY([InstId])
REFERENCES [exs].[Instructor] ([Inst_Id])
GO
ALTER TABLE [exs].[Exam_Students]  WITH CHECK ADD  CONSTRAINT [Exam_FK1] FOREIGN KEY([ExamId])
REFERENCES [exs].[Exam] ([Ex_Id])
GO
ALTER TABLE [exs].[Exam_Students] CHECK CONSTRAINT [Exam_FK1]
GO
ALTER TABLE [exs].[Exam_Students]  WITH CHECK ADD  CONSTRAINT [Student_Fk3] FOREIGN KEY([StuId])
REFERENCES [exs].[Students] ([St_Id])
GO
ALTER TABLE [exs].[Exam_Students] CHECK CONSTRAINT [Student_Fk3]
GO
ALTER TABLE [exs].[Inst_Courses]  WITH CHECK ADD  CONSTRAINT [Course_Fk1] FOREIGN KEY([CourseId])
REFERENCES [exs].[Course] ([Co_Id])
GO
ALTER TABLE [exs].[Inst_Courses] CHECK CONSTRAINT [Course_Fk1]
GO
ALTER TABLE [exs].[Inst_Courses]  WITH CHECK ADD  CONSTRAINT [Inst_FK1] FOREIGN KEY([InstId])
REFERENCES [exs].[Instructor] ([Inst_Id])
GO
ALTER TABLE [exs].[Inst_Courses] CHECK CONSTRAINT [Inst_FK1]
GO
ALTER TABLE [exs].[QuestionBank]  WITH CHECK ADD FOREIGN KEY([CourseId])
REFERENCES [exs].[Course] ([Co_Id])
GO
ALTER TABLE [exs].[QuestionBank]  WITH CHECK ADD FOREIGN KEY([Ex_Id])
REFERENCES [exs].[Exam] ([Ex_Id])
GO
ALTER TABLE [exs].[QuestionBank]  WITH CHECK ADD FOREIGN KEY([InstId])
REFERENCES [exs].[Instructor] ([Inst_Id])
GO
ALTER TABLE [exs].[Exam]  WITH CHECK ADD CHECK  (([Ex_Type]='exam' OR [Ex_Type]='corrective'))
GO
ALTER TABLE [exs].[QuestionBank]  WITH CHECK ADD CHECK  (([Q_Type]='MultipleChoice' OR [Q_Type]='True&false'))
GO
/****** Object:  StoredProcedure [exs].[addExam]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 create proc [exs].[addExam](@examType nvarchar(20),@totalDegree int,@sTime time,@eTime time,@examDate date,@year int,@CourId int,@InstId int)
 as 
 begin
	insert into [exs].[Exam]([Ex_Type],[Ex_TotalDegree],[Ex_StartTime],[Ex_EndTime],[Ex_date],[Ex_Year],[CourseId],[InstId])
	values(@examType,@totalDegree,@sTime,@eTime,@examDate,@year,@CourId, @InstId)

	return @@ERROR
 end
GO
/****** Object:  StoredProcedure [exs].[addQuestionToTheBank2]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  create proc [exs].[addQuestionToTheBank2](@questionText nvarchar(max),@QuestionType nvarchar(20),@degree int,@CorrectAnswer nvarchar(max),@CourId int,@InstId int)
 as 
 begin
	insert into[exs].[QuestionBank]([Question],[Q_Type],[Q_Degree],[Q_CorrectAnswer],[CourseId],[InstId])
	values(@questionText , @QuestionType , @degree , @CorrectAnswer , @CourId , @InstId)

	return @@ERROR
 end
GO
/****** Object:  StoredProcedure [exs].[deleteQuestion]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [exs].[deleteQuestion](@quesId int,@CourId int,@InstId int)
as
begin
   delete [exs].[QuestionBank]
   where [Q_Id]=@quesId  and [CourseId]=@CourId and [InstId]=@InstId 
end
GO
/****** Object:  StoredProcedure [exs].[putQuestionsInExam]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [exs].[putQuestionsInExam](@InstId int,@examId int,@examDegree int)
as
begin
		DECLARE @n int;
		SET @n = 0;
		Declare @countDegrees int;
		set @countDegrees=0;
		WHILE (@n < (select count(*) FROM [exs].[QuestionBank]))      
		BEGIN 
		  if((select [InstId] FROM [exs].[QuestionBank] where [Q_Id]=@n)= @InstId)
		  begin 
		         declare @currentDegree int;
		   set  @currentDegree=(select [Q_Degree] FROM [exs].[QuestionBank] WHERE [InstId]=@InstId and [Q_Id]=@n)
		   if(@countDegrees + @currentDegree > @examDegree)
		     begin 
			   break;
			  end
           else
			begin
				  set @countDegrees = @countDegrees + @currentDegree;
				      update [exs].[QuestionBank]
		              set [Ex_Id]=@examId
	            	  where [InstId]=@InstId and [Q_Id]=@n
			end
			set @n=@n+1;
		  end
		  else
		  begin
		   set @n=@n+1;
		   continue;
		  end
			
			 
		END 
end	
GO
/****** Object:  StoredProcedure [exs].[putQuestionsInExamManually]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [exs].[putQuestionsInExamManually](@quesId int,@InstId int,@examId int)
as
begin    
 if exists(select * FROM [exs].[QuestionBank] WHERE [InstId]=@InstId and [Q_Id]=@quesId )
	begin
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
GO
/****** Object:  StoredProcedure [exs].[UpdateQuestion]    Script Date: 10/3/2021 12:17:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE proc [exs].[UpdateQuestion](@quesId int,@questionText nvarchar(max),@degree int,@CorrectAnswer nvarchar(max),@CourId int,@InstId int)
 as 
 begin
		update [exs].[QuestionBank]
		set [Question]=@questionText,
			[Q_Degree]=@degree,
			[Q_CorrectAnswer]=@CorrectAnswer
			where [Q_Id]=@quesId  and [CourseId]=@CourId and [InstId]=@InstId 

		return @@ERROR
 end
GO
USE [master]
GO
ALTER DATABASE [Examination_System2] SET  READ_WRITE 
GO
