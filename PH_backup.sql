USE [master]
GO
/****** Object:  Database [PrintingHouse]    Script Date: 28.06.2023 23:17:34 ******/
CREATE DATABASE [PrintingHouse]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PrintingHouse', FILENAME = N'D:\Programming\Data bases\SQLserver\MSSQL16.MSSQLSERVER\MSSQL\DATA\PrintingHouse.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PrintingHouse_log', FILENAME = N'D:\Programming\Data bases\SQLserver\MSSQL16.MSSQLSERVER\MSSQL\DATA\PrintingHouse_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [PrintingHouse] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PrintingHouse].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PrintingHouse] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PrintingHouse] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PrintingHouse] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PrintingHouse] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PrintingHouse] SET ARITHABORT OFF 
GO
ALTER DATABASE [PrintingHouse] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PrintingHouse] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PrintingHouse] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PrintingHouse] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PrintingHouse] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PrintingHouse] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PrintingHouse] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PrintingHouse] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PrintingHouse] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PrintingHouse] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PrintingHouse] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PrintingHouse] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PrintingHouse] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PrintingHouse] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PrintingHouse] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PrintingHouse] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PrintingHouse] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PrintingHouse] SET RECOVERY FULL 
GO
ALTER DATABASE [PrintingHouse] SET  MULTI_USER 
GO
ALTER DATABASE [PrintingHouse] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PrintingHouse] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PrintingHouse] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PrintingHouse] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PrintingHouse] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PrintingHouse] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'PrintingHouse', N'ON'
GO
ALTER DATABASE [PrintingHouse] SET QUERY_STORE = ON
GO
ALTER DATABASE [PrintingHouse] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [PrintingHouse]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_MaterialsCost]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_MaterialsCost]
(@OrderID int)
RETURNS money
AS
BEGIN
DECLARE @Cost money
SELECT @Cost = SUM(MC.Consumption * (M.Price / M.Amount))
	FROM Materials M 
	LEFT JOIN MaterialsConsumption MC ON M.MaterialID = MC.MaterialID
	LEFT JOIN OperationalCard OC ON MC.OrderID = OC.OrderID AND MC.Operation = OC.Operation
		WHERE OC.OrderID = @OrderID 
RETURN @Cost;
END;
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(200,1) NOT NULL,
	[ProductName] [nvarchar](max) NOT NULL,
	[Amount] [int] NOT NULL,
	[Price] [money] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NOT NULL,
	[CustomerID] [int] NOT NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OperationalCard]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OperationalCard](
	[OrderID] [int] NOT NULL,
	[Operation] [nvarchar](50) NOT NULL,
	[EmployeeID] [int] NULL,
	[EquipmentID] [int] NULL,
 CONSTRAINT [PK_OperationalCard] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[Operation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[LaminatedProducts]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LaminatedProducts]
AS
SELECT O.OrderID, O.ProductName, O.Amount 
	FROM Orders O JOIN OperationalCard OC ON O.OrderID = OC.OrderID
		WHERE OC.Operation LIKE '%Ламин%';
GO
/****** Object:  Table [dbo].[MaterialsConsumption]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MaterialsConsumption](
	[OrderID] [int] NOT NULL,
	[Operation] [nvarchar](50) NOT NULL,
	[MaterialID] [int] NOT NULL,
	[Consumption] [float] NOT NULL,
 CONSTRAINT [PK_MaterialsConsumption] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[Operation] ASC,
	[MaterialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Materials]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Materials](
	[MaterialID] [int] IDENTITY(500,1) NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Brand] [nvarchar](50) NOT NULL,
	[Provider] [nvarchar](50) NOT NULL,
	[DeliverryDate] [date] NULL,
	[ForOperation] [nvarchar](50) NULL,
	[Units] [nvarchar](50) NOT NULL,
	[Price] [money] NOT NULL,
	[Thickness] [int] NULL,
	[Amount] [int] NOT NULL,
 CONSTRAINT [PK_Materials] PRIMARY KEY CLUSTERED 
(
	[MaterialID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[PaperConsumption]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[PaperConsumption]
AS
SELECT M.Thickness, SUM(MC.Consumption) AS Consump
	FROM Materials M 
	LEFT JOIN MaterialsConsumption MC ON M.MaterialID = MC.MaterialID
	LEFT JOIN Orders O ON MC.OrderID = O.OrderID
		WHERE M.Title LIKE 'Бумага' 
		AND O.EndDate BETWEEN '01.05.2023' AND '31.05.2023'
			GROUP BY M.Thickness;
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(100,1) NOT NULL,
	[FullName] [nvarchar](50) NOT NULL,
	[Position] [nvarchar](50) NULL,
	[Company] [nvarchar](50) NULL,
	[Phone] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](50) NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] IDENTITY(400,1) NOT NULL,
	[Position] [nvarchar](50) NULL,
	[FullName] [nvarchar](50) NOT NULL,
	[WorkingHours] [varchar](20) NOT NULL,
	[WorkPhone] [nvarchar](50) NOT NULL,
	[Cabinet] [nvarchar](50) NULL,
	[Phone] [varchar](50) NULL,
	[BeginContract] [date] NOT NULL,
	[EndContract] [date] NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Equipment]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Equipment](
	[EquipmentID] [int] IDENTITY(300,1) NOT NULL,
	[Brand] [nvarchar](50) NULL,
	[Provider] [nvarchar](50) NOT NULL,
	[RegistrationYear] [smallint] NULL,
	[NetworkAdress] [varchar](20) NULL,
 CONSTRAINT [PK_Equipment] PRIMARY KEY CLUSTERED 
(
	[EquipmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_OperationalCard]    Script Date: 28.06.2023 23:17:34 ******/
CREATE NONCLUSTERED INDEX [IX_OperationalCard] ON [dbo].[OperationalCard]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaterialsConsumption]  WITH CHECK ADD  CONSTRAINT [FK_MaterialsConsumption_OperationalCard] FOREIGN KEY([MaterialID])
REFERENCES [dbo].[Materials] ([MaterialID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[MaterialsConsumption] CHECK CONSTRAINT [FK_MaterialsConsumption_OperationalCard]
GO
ALTER TABLE [dbo].[MaterialsConsumption]  WITH CHECK ADD  CONSTRAINT [FK_MaterialsConsumption_OperationalCard1] FOREIGN KEY([OrderID], [Operation])
REFERENCES [dbo].[OperationalCard] ([OrderID], [Operation])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[MaterialsConsumption] CHECK CONSTRAINT [FK_MaterialsConsumption_OperationalCard1]
GO
ALTER TABLE [dbo].[OperationalCard]  WITH CHECK ADD  CONSTRAINT [FK_OperationalCard_Employees] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[OperationalCard] CHECK CONSTRAINT [FK_OperationalCard_Employees]
GO
ALTER TABLE [dbo].[OperationalCard]  WITH CHECK ADD  CONSTRAINT [FK_OperationalCard_Equipment] FOREIGN KEY([EquipmentID])
REFERENCES [dbo].[Equipment] ([EquipmentID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[OperationalCard] CHECK CONSTRAINT [FK_OperationalCard_Equipment]
GO
ALTER TABLE [dbo].[OperationalCard]  WITH CHECK ADD  CONSTRAINT [FK_OperationalCard_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[OperationalCard] CHECK CONSTRAINT [FK_OperationalCard_Orders]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Customers]
GO
/****** Object:  StoredProcedure [dbo].[pr_ProdusedONPeriod]    Script Date: 28.06.2023 23:17:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[pr_ProdusedONPeriod]
@BeginPeriod date,
@EndPeriod date,
@ProductsAmount int OUTPUT
AS
SELECT @ProductsAmount = SUM(Amount)
	FROM Orders
		WHERE EndDate BETWEEN @BeginPeriod AND @EndPeriod;
GO
USE [master]
GO
ALTER DATABASE [PrintingHouse] SET  READ_WRITE 
GO
