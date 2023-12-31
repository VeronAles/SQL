﻿USE [master]
GO
-- Object:  Database [PrintingHouse]
CREATE DATABASE [PrintingHouse]
USE [PrintingHouse]
GO
-- Object:  Table [dbo].[Orders]
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
-- Object:  Table [dbo].[OperationalCard]
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
-- Object:  Table [dbo].[MaterialsConsumption]
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
-- Object:  Table [dbo].[Materials]
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
-- Object:  Table [dbo].[Customers]
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
-- Object:  Table [dbo].[Employees]
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
-- Object:  Table [dbo].[Equipment]
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
-- Object:  Index [IX_OperationalCard]
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
