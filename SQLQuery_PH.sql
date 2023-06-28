USE PrintingHouse
GO
-- 4. Запросы манипулирования данными
-- Вывести таблицу с кодом заказа, названием заказа, заказчиком, контактным номером
-- заказчика, добавить столбец ответственного менеджера
-- 4.1. Создать новую таблицу TestTable с помощью запроса на языке SQL SELECT … INTO…
SELECT O.OrderID, O.ProductName, C.FullName, C.Phone INTO TestTable
	FROM Orders O LEFT JOIN Customers C ON O.CustomerID = C.CustomerID;
--
SELECT * FROM TestTable
-- 4.2. Изменить структуру созданной таблицы, добавив в нее новый столбец
ALTER TABLE TestTable 
	ADD Manager nvarchar(50);
-- 4.3. Заполнить новое поле с помощью запроса на обновление данных на языке SQL
UPDATE TestTable 
	SET Manager = (SELECT FullName FROM Employees WHERE EmployeeID = 406);
-- 4.4. Обновить значения в поле с помощью запроса с учетом определенного условия
UPDATE TestTable 
	SET Manager = (SELECT FullName FROM Employees WHERE EmployeeID = 405)
		WHERE ProductName LIKE 'Визитки';
-- 4.5. Создать запрос на языке SQL на добавление в таблицу TestTable новых записей
INSERT INTO TestTable
	VALUES (201, 'Журнал', 'Лесной Игорь', '+375 29 526-48-96', NULL);
INSERT INTO TestTable (OrderID, ProductName, FullName, Phone)
	VALUES (209, 'Плакат', 'Оленина Лена', '+375 29 145-25-12');
INSERT INTO TestTable
	VALUES (211, 'Пакеты', 'Лось Виталий', NULL, 
		(SELECT FullName FROM Employees WHERE EmployeeID = 402));
-- 
SELECT * FROM TestTable
	ORDER BY OrderID
-- 4.6. Составить запрос на удаление записей из созданной таблицы
DELETE FROM TestTable
	WHERE OrderID < 205;
-- 
SELECT * FROM TestTable
	ORDER BY OrderID
-- 4.7. Удалить таблицу TestTable
DROP TABLE TestTable;
GO

-- 5. Запросы на выборку данных
-- 5.1. Запрос на вывод оборудование, которое установлено после 2017 года
SELECT * FROM Equipment
	WHERE RegistrationYear > 2017;
-- 5.2. Запрос на вывод ФИО и должности рабочих, которые работают на производстве
SELECT FullName, Position FROM Employees
	WHERE (Cabinet = 01 OR Cabinet = 02 OR Cabinet = 03) 
		   AND WorkingHours = '7-7, 2/2';
-- 5.3, 5.4. Запрос на подсчет количества выполненных операций каждым работником 
-- производства с выводом их ФИО
SELECT OC.EmployeeID, E.FullName, COUNT(OC.Operation) AS NumOperations 
	FROM OperationalCard OC LEFT JOIN Employees E ON OC.EmployeeID = E.EmployeeID
		GROUP BY OC.EmployeeID, E.FullName;
-- 5.5. Запрос на расход имеющихся видов бумаги (сгруппировать по г/м2) за март 2023
SELECT M.Thickness, SUM(MC.Consumption) AS Consump
	FROM Materials M 
	LEFT JOIN MaterialsConsumption MC ON M.MaterialID = MC.MaterialID
	LEFT JOIN Orders O ON MC.OrderID = O.OrderID
		WHERE M.Title LIKE 'Бумага' 
		AND O.EndDate BETWEEN '01.05.2023' AND '31.05.2023'
			GROUP BY M.Thickness
				ORDER BY M.Thickness DESC;
-- 5.6. Запрос на вывод таблицы заказов с ФИО заказчика
SELECT O.OrderID, O.ProductName, O.Amount, O.Price, O.StartDate, O.EndDate, C.FullName 
	FROM Orders O LEFT JOIN Customers C ON O.CustomerID = C.CustomerID
		ORDER BY ProductName, Amount DESC; 
-- 5.7. Запрос на вывод таблицы заказов с ФИО заказчика и вычисляемым количеством дней на изготовление
SELECT O.OrderID, O.ProductName, O.Amount, O.Price, O.StartDate, O.EndDate, C.FullName,
	DATEDIFF (dd, O.StartDate, O.EndDate) AS NumDays 
	FROM Orders O LEFT JOIN Customers C ON O.CustomerID = C.CustomerID
		ORDER BY ProductName, Amount DESC;
-- 5.8. Запрос на вывод всех персональных данных (ФИО, должность, телефон), имеющихся в базе данных
SELECT FullName, Position, Phone FROM Employees
UNION
SELECT FullName, Position, Phone FROM Customers
-- 5.9. Запрос на вывод поставщиков, которые поставляют и оборудование, и материалы
SELECT [Provider] FROM Materials
INTERSECT
SELECT [Provider] FROM Equipment
-- 5.10, 5.11. Запрос на вывод количества листов, которое было напечатано на печатной машине Xerox
SELECT MC.Consumption 
	FROM MaterialsConsumption MC RIGHT JOIN OperationalCard OC
	ON MC.OrderID = OC.OrderID AND MC.Operation = OC.Operation
		WHERE OC.EquipmentID = (SELECT EquipmentID FROM Equipment WHERE Brand LIKE '%Xerox%')
		AND MC.MaterialID IN (SELECT MaterialID FROM Materials WHERE Title LIKE 'Бумага')
			GROUP BY Consumption;
GO

-- 6. Вывести заказы, где использована пленка (выполнялось ламинирование)
CREATE OR ALTER VIEW LaminatedProducts
AS
SELECT O.OrderID, O.ProductName, O.Amount 
	FROM Orders O JOIN OperationalCard OC ON O.OrderID = OC.OrderID
		WHERE OC.Operation LIKE '%Ламин%';
GO
SELECT * FROM dbo.LaminatedProducts;
GO

--6. (5.5) Вывести расход имеющихся видов бумаги (сгруппировать по г/м2) за март 2023
CREATE OR ALTER VIEW PaperConsumption
AS
SELECT M.Thickness, SUM(MC.Consumption) AS Consump
	FROM Materials M 
	LEFT JOIN MaterialsConsumption MC ON M.MaterialID = MC.MaterialID
	LEFT JOIN Orders O ON MC.OrderID = O.OrderID
		WHERE M.Title LIKE 'Бумага' 
		AND O.EndDate BETWEEN '01.05.2023' AND '31.05.2023'
			GROUP BY M.Thickness;
GO
SELECT * FROM dbo.PaperConsumption;
GO

-- 7.1. Процедура вывода количества произведенной продукции за период времени
CREATE OR ALTER PROC pr_ProdusedONPeriod
@BeginPeriod date,
@EndPeriod date,
@ProductsAmount int OUTPUT
AS
SELECT @ProductsAmount = SUM(Amount)
	FROM Orders
		WHERE EndDate BETWEEN @BeginPeriod AND @EndPeriod;
GO
-- Просмотр через процедуру количества произведенной продукции за март
DECLARE @ProdAmount int;
EXEC pr_ProdusedONPeriod '01.05.2023', '31.05.2023', @ProdAmount OUTPUT;
SELECT @ProdAmount;
GO

-- 7.2. Функция для вывода стоимости материалов для одного заказа
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

-- 7.3. Создать триггер для проверки вводимого e-mail
CREATE OR ALTER TRIGGER CheckEmail
ON Customers
FOR INSERT
AS
BEGIN
DECLARE @Email nvarchar(50);
	SELECT @Email = Email FROM inserted;;
	IF (@Email NOT LIKE '%@%')
	BEGIN
			PRINT 'e-mail должен содержать @';
			ROLLBACK TRAN
	END
END
GO
-- Проверка триггера
INSERT Customers (FullName, Position, Company, Phone, Email) VALUES ('abc', 'abc', 'abc', 'abc', 'abc');
SELECT * FROM Customers;
GO

-- 7.4. Триггер для таблицы Materials, срабатывающий при любом изменении 
-- цены материала и корректирующий в таблице MaterialsConsumption себестоимость
-- 1) новый столбец для работы триггера
ALTER TABLE MaterialsConsumption ADD MaterialCost MONEY
SELECT * FROM MaterialsConsumption;
GO
-- 2) триггер
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
-- 3) проверка триггера
UPDATE Materials SET Price *= 1.05
	WHERE MaterialID = 509 -- для скоб
SELECT * FROM MaterialsConsumption;
GO
-- 4) добавление курсора
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
-- 5) проверка триггера с курсором
UPDATE Materials SET Price *= 1.05
	WHERE MaterialID IN (505, 506); -- для тонера
SELECT * FROM MaterialsConsumption;
-- 6) удалить добавленный вначале столбец для триггера
ALTER TABLE MaterialsConsumption DROP COLUMN MaterialCost;
SELECT * FROM MaterialsConsumption;