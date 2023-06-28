USE PrintingHouse
GO
-- 4. ������� ��������������� �������
-- ������� ������� � ����� ������, ��������� ������, ����������, ���������� �������
-- ���������, �������� ������� �������������� ���������
-- 4.1. ������� ����� ������� TestTable � ������� ������� �� ����� SQL SELECT � INTO�
SELECT O.OrderID, O.ProductName, C.FullName, C.Phone INTO TestTable
	FROM Orders O LEFT JOIN Customers C ON O.CustomerID = C.CustomerID;
--
SELECT * FROM TestTable
-- 4.2. �������� ��������� ��������� �������, ������� � ��� ����� �������
ALTER TABLE TestTable 
	ADD Manager nvarchar(50);
-- 4.3. ��������� ����� ���� � ������� ������� �� ���������� ������ �� ����� SQL
UPDATE TestTable 
	SET Manager = (SELECT FullName FROM Employees WHERE EmployeeID = 406);
-- 4.4. �������� �������� � ���� � ������� ������� � ������ ������������� �������
UPDATE TestTable 
	SET Manager = (SELECT FullName FROM Employees WHERE EmployeeID = 405)
		WHERE ProductName LIKE '�������';
-- 4.5. ������� ������ �� ����� SQL �� ���������� � ������� TestTable ����� �������
INSERT INTO TestTable
	VALUES (201, '������', '������ �����', '+375 29 526-48-96', NULL);
INSERT INTO TestTable (OrderID, ProductName, FullName, Phone)
	VALUES (209, '������', '������� ����', '+375 29 145-25-12');
INSERT INTO TestTable
	VALUES (211, '������', '���� �������', NULL, 
		(SELECT FullName FROM Employees WHERE EmployeeID = 402));
-- 
SELECT * FROM TestTable
	ORDER BY OrderID
-- 4.6. ��������� ������ �� �������� ������� �� ��������� �������
DELETE FROM TestTable
	WHERE OrderID < 205;
-- 
SELECT * FROM TestTable
	ORDER BY OrderID
-- 4.7. ������� ������� TestTable
DROP TABLE TestTable;
GO

-- 5. ������� �� ������� ������
-- 5.1. ������ �� ����� ������������, ������� ����������� ����� 2017 ����
SELECT * FROM Equipment
	WHERE RegistrationYear > 2017;
-- 5.2. ������ �� ����� ��� � ��������� �������, ������� �������� �� ������������
SELECT FullName, Position FROM Employees
	WHERE (Cabinet = 01 OR Cabinet = 02 OR Cabinet = 03) 
		   AND WorkingHours = '7-7, 2/2';
-- 5.3, 5.4. ������ �� ������� ���������� ����������� �������� ������ ���������� 
-- ������������ � ������� �� ���
SELECT OC.EmployeeID, E.FullName, COUNT(OC.Operation) AS NumOperations 
	FROM OperationalCard OC LEFT JOIN Employees E ON OC.EmployeeID = E.EmployeeID
		GROUP BY OC.EmployeeID, E.FullName;
-- 5.5. ������ �� ������ ��������� ����� ������ (������������� �� �/�2) �� ���� 2023
SELECT M.Thickness, SUM(MC.Consumption) AS Consump
	FROM Materials M 
	LEFT JOIN MaterialsConsumption MC ON M.MaterialID = MC.MaterialID
	LEFT JOIN Orders O ON MC.OrderID = O.OrderID
		WHERE M.Title LIKE '������' 
		AND O.EndDate BETWEEN '01.05.2023' AND '31.05.2023'
			GROUP BY M.Thickness
				ORDER BY M.Thickness DESC;
-- 5.6. ������ �� ����� ������� ������� � ��� ���������
SELECT O.OrderID, O.ProductName, O.Amount, O.Price, O.StartDate, O.EndDate, C.FullName 
	FROM Orders O LEFT JOIN Customers C ON O.CustomerID = C.CustomerID
		ORDER BY ProductName, Amount DESC; 
-- 5.7. ������ �� ����� ������� ������� � ��� ��������� � ����������� ����������� ���� �� ������������
SELECT O.OrderID, O.ProductName, O.Amount, O.Price, O.StartDate, O.EndDate, C.FullName,
	DATEDIFF (dd, O.StartDate, O.EndDate) AS NumDays 
	FROM Orders O LEFT JOIN Customers C ON O.CustomerID = C.CustomerID
		ORDER BY ProductName, Amount DESC;
-- 5.8. ������ �� ����� ���� ������������ ������ (���, ���������, �������), ��������� � ���� ������
SELECT FullName, Position, Phone FROM Employees
UNION
SELECT FullName, Position, Phone FROM Customers
-- 5.9. ������ �� ����� �����������, ������� ���������� � ������������, � ���������
SELECT [Provider] FROM Materials
INTERSECT
SELECT [Provider] FROM Equipment
-- 5.10, 5.11. ������ �� ����� ���������� ������, ������� ���� ���������� �� �������� ������ Xerox
SELECT MC.Consumption 
	FROM MaterialsConsumption MC RIGHT JOIN OperationalCard OC
	ON MC.OrderID = OC.OrderID AND MC.Operation = OC.Operation
		WHERE OC.EquipmentID = (SELECT EquipmentID FROM Equipment WHERE Brand LIKE '%Xerox%')
		AND MC.MaterialID IN (SELECT MaterialID FROM Materials WHERE Title LIKE '������')
			GROUP BY Consumption;
GO

-- 6. ������� ������, ��� ������������ ������ (����������� �������������)
CREATE OR ALTER VIEW LaminatedProducts
AS
SELECT O.OrderID, O.ProductName, O.Amount 
	FROM Orders O JOIN OperationalCard OC ON O.OrderID = OC.OrderID
		WHERE OC.Operation LIKE '%�����%';
GO
SELECT * FROM dbo.LaminatedProducts;
GO

--6. (5.5) ������� ������ ��������� ����� ������ (������������� �� �/�2) �� ���� 2023
CREATE OR ALTER VIEW PaperConsumption
AS
SELECT M.Thickness, SUM(MC.Consumption) AS Consump
	FROM Materials M 
	LEFT JOIN MaterialsConsumption MC ON M.MaterialID = MC.MaterialID
	LEFT JOIN Orders O ON MC.OrderID = O.OrderID
		WHERE M.Title LIKE '������' 
		AND O.EndDate BETWEEN '01.05.2023' AND '31.05.2023'
			GROUP BY M.Thickness;
GO
SELECT * FROM dbo.PaperConsumption;
GO

-- 7.1. ��������� ������ ���������� ������������� ��������� �� ������ �������
CREATE OR ALTER PROC pr_ProdusedONPeriod
@BeginPeriod date,
@EndPeriod date,
@ProductsAmount int OUTPUT
AS
SELECT @ProductsAmount = SUM(Amount)
	FROM Orders
		WHERE EndDate BETWEEN @BeginPeriod AND @EndPeriod;
GO
-- �������� ����� ��������� ���������� ������������� ��������� �� ����
DECLARE @ProdAmount int;
EXEC pr_ProdusedONPeriod '01.05.2023', '31.05.2023', @ProdAmount OUTPUT;
SELECT @ProdAmount;
GO

-- 7.2. ������� ��� ������ ��������� ���������� ��� ������ ������
CREATE OR ALTER FUNCTION fn_MaterialsCost
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
SELECT dbo.fn_MaterialsCost(205) AS MaterialsCost;
GO

-- 7.3. ������� ������� ��� �������� ��������� e-mail
CREATE OR ALTER TRIGGER CheckEmail
ON Customers
FOR INSERT
AS
BEGIN
DECLARE @Email nvarchar(50);
	SELECT @Email = Email FROM inserted;;
	IF (@Email NOT LIKE '%@%')
	BEGIN
			PRINT 'e-mail ������ ��������� @';
			ROLLBACK TRAN
	END
END
GO
-- �������� ��������
INSERT Customers (FullName, Position, Company, Phone, Email) VALUES ('abc', 'abc', 'abc', 'abc', 'abc');
SELECT * FROM Customers;
GO

-- 7.4. ������� ��� ������� Materials, ������������� ��� ����� ��������� 
-- ���� ��������� � �������������� � ������� MaterialsConsumption �������������
-- 1) ����� ������� ��� ������ ��������
ALTER TABLE MaterialsConsumption ADD MaterialCost MONEY
SELECT * FROM MaterialsConsumption;
GO
-- 2) �������
CREATE OR ALTER TRIGGER ChangeMaterialPrice
ON Materials
	FOR UPDATE AS 
IF UPDATE(Price)
BEGIN
DECLARE @MaterialCode INT, @Price MONEY;
SELECT @MaterialCode = inserted.MaterialID, @Price = inserted.Price
	FROM inserted;
UPDATE MaterialsConsumption SET MaterialCost = @Price * Consumption
	WHERE MaterialID = @MaterialCode;
END
GO
-- 3) �������� ��������
UPDATE Materials SET Price *= 1.05
	WHERE MaterialID = 509 -- ��� ����
SELECT * FROM MaterialsConsumption;
GO
-- 4) ���������� �������
ALTER TRIGGER ChangeMaterialPrice
ON Materials
	FOR UPDATE AS 
IF UPDATE(Price)
BEGIN
DECLARE @MaterialCode INT, @Price MONEY, @MaterialCost MONEY;

DECLARE PriceCursor CURSOR LOCAL STATIC FOR
	SELECT inserted.MaterialID, inserted.Price,
		   inserted.Price * MaterialsConsumption.Consumption
		FROM inserted INNER JOIN MaterialsConsumption
			ON inserted.MaterialID = MaterialsConsumption.MaterialID;
OPEN PriceCursor;
FETCH FIRST FROM PriceCursor INTO @MaterialCode, @Price, @MaterialCost;
WHILE @@FETCH_STATUS = 0
BEGIN
	UPDATE MaterialsConsumption
		SET MaterialCost = @Price * Consumption
			WHERE MaterialID = @MaterialCode;
	FETCH NEXT FROM PriceCursor INTO @MaterialCode, @Price, @MaterialCost;
END
CLOSE PriceCursor;
DEALLOCATE PriceCursor;
END
GO
-- 5) �������� �������� � ��������
UPDATE Materials SET Price *= 1.05
	WHERE MaterialID IN (505, 506); -- ��� ������
SELECT * FROM MaterialsConsumption;
-- 6) ������� ����������� ������� ������� ��� ��������
ALTER TABLE MaterialsConsumption DROP COLUMN MaterialCost;
SELECT * FROM MaterialsConsumption;