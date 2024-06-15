CREATE PROCEDURE InsertOrderDetails
@OrderID INT,
@ProductID INT,
@UnitPrice DECIMAL(10, 2) = NULL,
@Quantity INT,
@Discount DECIMAL(4, 2) = 0
AS
BEGIN
DECLARE @ProductUnitPrice DECIMAL(10, 2)
DECLARE @UnitsInStock INT
DECLARE @ReorderLevel INT
-- Get UnitPrice from Products table if not provided
IF @UnitPrice IS NULL
BEGIN
SELECT @ProductUnitPrice = UnitPrice FROM Products WHERE ProductID = @ProductID
END
ELSE
BEGIN
SET @ProductUnitPrice = @UnitPrice
END
-- Get UnitsInStock and ReorderLevel from Products table
SELECT @UnitsInStock = UnitsInStock, @ReorderLevel = ReorderLevel FROM Products WHERE ProductID = @ProductID
-- Check if there is enough stock
IF @UnitsInStock < @Quantity
BEGIN
PRINT 'Insufficient stock to place the order.'
RETURN
END
-- Insert into Order Details
INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES (@OrderID, @ProductID, @ProductUnitPrice, @Quantity, @Discount)
-- Check if insertion was successful
IF @@ROWCOUNT = 0
BEGIN
PRINT 'Failed to place the order. Please try again.'
RETURN
END
-- Update the UnitsInStock in Products table
UPDATE Products
SET UnitsInStock = UnitsInStock - @Quantity
WHERE ProductID = @ProductID
-- Check if UnitsInStock drops below ReorderLevel
IF @UnitsInStock - @Quantity < @ReorderLevel
BEGIN
PRINPRINT 'Warning: The stock for this product has dropped below its reorder level.'
END
END
CREATE PROCEDURE UpdateOrderDetails
@OrderID INT,
@ProductID INT,
@UnitPrice DECIMAL(10, 2) = NULL,
@Quantity INT = NULL,
@Discount DECIMAL(4, 2) = NULL
AS
BEGIN
DECLARE @CurrentUnitPrice DECIMAL(10, 2)
DECLARE @CurrentQuantity INT
DECLARE @CurrentDiscount DECIMAL(4, 2)
DECLARE @UnitsInStock INT
-- Get current values
SELECT
@CurrentUnitPrice = UnitPrice,
@CurrentQuantity = Quantity,
@CurrentDiscount = Discount
FROM [Order Details]
WHERE OrderID = @OrderID AND ProductID = @ProductID
-- Set new values if provided, otherwise retain old values
SET @UnitPrice = ISNULL(@UnitPrice, @CurrentUnitPrice)
SET @Quantity = ISNULL(@Quantity, @CurrentQuantity)
SET @Discount = ISNULL(@Discount, @CurrentDiscount)
-- Adjust stock if quantity changes
IF @Quantity <> @CurrentQuantity
BEGIN
SELECT @UnitsInStock = UnitsInStock FROM Products WHERE ProductID = @ProductID
-- Check if there is enough stock
IF @UnitsInStock + @CurrentQuantity < @Quantity
BEGIN
PRINT 'Insufficient stock to update the order.'
RETURN
END
-- Update UnitsInStock
UPDATE Products
SET UnitsInStock = UnitsInStock + @CurrentQuantity - @Quantity
WHERE ProductID = @ProductID
END
-- Update Order Details
UPDATE [Order Details]
SET UnitPrice = @UnitPrice, Quantity = @Quantity, Discount = @Discount
WHERE OrderID = @OrderID AND ProductID = @ProductID
END
CREATE PROCEDURE GetOrderDetails
@OrderID INT
AS
BEGIN
IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID)
BEGIN
PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist'
RETURN 1
END
ELSE
BEGIN
SELECT * FROM [Order Details] WHERE OrderID = @OrderID
END
END
CREATE PROCEDURE DeleteOrderDetails
@OrderID INT,
@ProductID INT
AS
BEGIN
IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID AND ProductID = @ProductID)
BEGIN
PRINT 'Invalid parameters: The specified OrderID and ProductID do not exist'
RETURN -1
END
DELETE FROM [Order Details]
WHERE OrderID = @OrderID AND ProductID = @ProductID
END
CREATE FUNCTION dbo.FormatDate_MMDDYYYY (@Date DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
RETURN CONVERT(VARCHAR(10), @Date, 101)
END
CREATE FUNCTION dbo.FormatDate_YYYYMMDD (@Date DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
RETURN CONVERT(VARCHAR(8), @Date, 112)
END
CREATE VIEW vwCustomerOrders AS
SELECT
c.CompanyName,
o.OrderID,
o.OrderDate,
od.ProductID,
p.ProductName,
od.Quantity,
od.UnitPrice,
od.Quantity * od.UnitPrice AS TotalPrice
FROM
Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT
c.CompanyName,
o.OrderID,
o.OrderDate,
od.ProductID,
p.ProductName,
od.Quantity,
od.UnitPrice,
od.Quantity * od.UnitPrice AS TotalPrice
FROM
Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE
o.OrderDate = CAST(GETDATE() - 1 AS DATE)
CREATE VIEW MyProducts AS
SELECT
p.ProductID,
p.ProductName,
p.QuantityPerUnit,
p.UnitPrice,
s.CompanyName,
c.CategoryName
FROM
Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE
p.Discontinued = 0
CREATE TRIGGER trgInsteadOfDeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
DELETE od
FROM [Order Details] od
JOIN deleted d ON od.OrderID = d.OrderID
DELETE o
FROM Orders o
JOIN deleted d ON o.OrderID = d.OrderID
END
CREATE TRIGGER trgBeforeInsertOrderDetails
ON [Order Details]
INSTEAD OF INSERT
AS
BEGIN
DECLARE @ProductID INT
DECLARE @Quantity INT
DECLARE @UnitsInStock INT
SELECT @ProductID = i.ProductID, @Quantity = i.Quantity
FROM inserted i
SELECT @UnitsInStock = UnitsInStock
FROM Products
WHERE ProductID = @ProductID
IF @UnitsInStock < @Quantity
BEGIN
PRINT 'Insufficient stock to place the order.'
RETURN
END
INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
SELECT OrderID, ProductID, UnitPrice, Quantity, Discount
FROM inserted
UPDATE Products
SET UnitsInStock = UnitsInStock - @Quantity
WHERE ProductID = @ProductID
END