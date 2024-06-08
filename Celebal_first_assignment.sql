CREATE DATABASE Customers;
USE Customers;
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PostalCode VARCHAR(10),
    Country VARCHAR(255),
    Phone VARCHAR(20),
    Fax VARCHAR(20)
);
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(255),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(255),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BOOLEAN
);
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    LastName VARCHAR(255),
    FirstName VARCHAR(255),
    Title VARCHAR(255),
    TitleOfCourtesy VARCHAR(255),
    BirthDate DATE,
    HireDate DATE,
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PostalCode VARCHAR(10),
    Country VARCHAR(255),
    HomePhone VARCHAR(20),
    Extension VARCHAR(10),
    Notes TEXT,
    ReportsTo INT,
    FOREIGN KEY (ReportsTo) REFERENCES Employees(EmployeeID)
);
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    RequiredDate DATE,
    ShippedDate DATE,
    ShipVia INT,
    Freight DECIMAL(10, 2),
    ShipName VARCHAR(255),
    ShipAddress VARCHAR(255),
    ShipCity VARCHAR(255),
    ShipRegion VARCHAR(255),
    ShipPostalCode VARCHAR(10),
    ShipCountry VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
CREATE TABLE OrderDetails (
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(3, 2),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
SELECT * FROM Customers;
SELECT * FROM Customers WHERE CompanyName LIKE '%N';
SELECT * FROM Customers WHERE City IN ('Berlin', 'London');
SELECT * FROM Customers WHERE Country IN ('UK', 'USA');
SELECT * FROM Products ORDER BY ProductName;
SELECT * FROM Products WHERE ProductName LIKE 'A%';
SELECT DISTINCT Customers.* FROM Customers 
JOIN Orders ON Customers.CustomerID = Orders.CustomerID;
SELECT DISTINCT Customers.* FROM Customers 
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN Products ON OrderDetails.ProductID = Products.ProductID
WHERE Customers.City = 'London' AND Products.ProductName = 'Chai';
SELECT * FROM Customers WHERE CustomerID NOT IN 
(SELECT CustomerID FROM Orders);
SELECT DISTINCT Customers.* FROM Customers 
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN Products ON OrderDetails.ProductID = Products.ProductID
WHERE Products.ProductName = 'Tofu';
SELECT * FROM Orders ORDER BY OrderDate ASC LIMIT 1;
SELECT Orders.* FROM Orders
JOIN (SELECT OrderID, SUM(UnitPrice * Quantity * (1 - Discount)) AS Total
      FROM OrderDetails
      GROUP BY OrderID
      ORDER BY Total DESC
      LIMIT 1) AS ExpensiveOrder
ON Orders.OrderID = ExpensiveOrder.OrderID;
SELECT OrderID, AVG(Quantity) AS AverageQuantity FROM OrderDetails
GROUP BY OrderID;
SELECT OrderID, MIN(Quantity) AS MinQuantity, MAX(Quantity) AS MaxQuantity FROM OrderDetails
GROUP BY OrderID;
SELECT e1.EmployeeID, e1.FirstName, e1.LastName, COUNT(e2.EmployeeID) AS ReportCount
FROM Employees e1
LEFT JOIN Employees e2 ON e1.EmployeeID = e2.ReportsTo
GROUP BY e1.EmployeeID, e1.FirstName, e1.LastName;
SELECT OrderID, SUM(Quantity) AS TotalQuantity FROM OrderDetails
GROUP BY OrderID
HAVING SUM(Quantity) > 300;
SELECT * FROM Orders WHERE OrderDate >= '1996-12-31';
SELECT * FROM Orders WHERE ShipCountry = 'Canada';
SELECT Orders.OrderID, SUM(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)) AS OrderTotal
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
GROUP BY Orders.OrderID
HAVING OrderTotal > 200;
SELECT ShipCountry, SUM(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)) AS TotalSales
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
GROUP BY ShipCountry;
SELECT Customers.ContactName, COUNT(Orders.OrderID) AS OrderCount
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.ContactName;
SELECT Customers.ContactName FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.ContactName
HAVING COUNT(Orders.OrderID) > 3;
SELECT DISTINCT Products.* FROM Products
JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
JOIN Orders ON OrderDetails.OrderID = Orders.OrderID
WHERE Products.Discontinued = TRUE
AND Orders.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';
SELECT e1.FirstName AS EmployeeFirstName, e1.LastName AS EmployeeLastName,
       e2.FirstName AS SupervisorFirstName, e2.LastName AS SupervisorLastName
FROM Employees e1
LEFT JOIN Employees e2 ON e1.ReportsTo = e2.EmployeeID;
SELECT Employees.EmployeeID, SUM(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)) AS TotalSales
FROM Employees
JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
GROUP BY Employees.EmployeeID;
SELECT * FROM Employees WHERE FirstName LIKE '%a%';
SELECT e1.EmployeeID, e1.FirstName, e1.LastName
FROM Employees e1
JOIN Employees e2 ON e1.EmployeeID = e2.ReportsTo
GROUP BY e1.EmployeeID, e1.FirstName, e1.LastName
HAVING COUNT(e2.EmployeeID) > 4;
SELECT Orders.OrderID, Products.ProductName
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN Products ON OrderDetails.ProductID = Products.ProductID;
SELECT Orders.* FROM Orders
JOIN (SELECT CustomerID, COUNT(OrderID) AS OrderCount
      FROM Orders
      GROUP BY CustomerID
      ORDER BY OrderCount DESC
      LIMIT 1) AS BestCustomer
ON Orders.CustomerID = BestCustomer.CustomerID;
SELECT Orders.* FROM Orders
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
WHERE Customers.Fax IS NULL;
SELECT DISTINCT Orders.ShipPostalCode
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN Products ON OrderDetails.ProductID = Products.ProductID
WHERE Products.ProductName = 'Tofu';
SELECT DISTINCT Products.ProductName
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
JOIN Products ON OrderDetails.ProductID = Products.ProductID
WHERE Orders.ShipCountry = 'France';
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    CompanyName VARCHAR(255),
    ContactName VARCHAR(255),
    ContactTitle VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    Region VARCHAR(255),
    PostalCode VARCHAR(10),
    Country VARCHAR(255),
    Phone VARCHAR(20),
    Fax VARCHAR(20),
    HomePage TEXT
);
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(255),
    Description TEXT
);
SELECT Products.ProductName, Categories.CategoryName
FROM Products
JOIN Categories ON Products.CategoryID = Categories.CategoryID
JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID
WHERE Suppliers.CompanyName = 'Specialty Biscuits, Ltd.';
SELECT * FROM Products
WHERE ProductID NOT IN (SELECT ProductID FROM OrderDetails);
SELECT * FROM Products
WHERE UnitsInStock < 10 AND UnitsOnOrder = 0;
SELECT ShipCountry, SUM(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)) AS TotalSales
FROM Orders
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
GROUP BY ShipCountry
ORDER BY TotalSales DESC
LIMIT 10;
SELECT Employees.EmployeeID, COUNT(Orders.OrderID) AS OrderCount
FROM Employees
JOIN Orders ON Employees.EmployeeID = Orders.EmployeeID
JOIN Customers ON Orders.CustomerID = Customers.CustomerID
WHERE Customers.CustomerID BETWEEN 'A' AND 'AO'
GROUP BY Employees.EmployeeID;
SELECT Orders.OrderDate FROM Orders
JOIN (SELECT OrderID, SUM(UnitPrice * Quantity * (1 - Discount)) AS Total
      FROM OrderDetails
      GROUP BY OrderID
      ORDER BY Total DESC
      LIMIT 1) AS ExpensiveOrder
ON Orders.OrderID = ExpensiveOrder.OrderID;
SELECT Products.ProductName, SUM(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)) AS TotalRevenue
FROM Products
JOIN OrderDetails ON Products.ProductID = OrderDetails.ProductID
GROUP BY Products.ProductName;
SELECT SupplierID, COUNT(ProductID) AS ProductCount
FROM Products
GROUP BY SupplierID;
SELECT Customers.*, SUM(OrderDetails.UnitPrice * OrderDetails.Quantity * (1 - OrderDetails.Discount)) AS TotalSales
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
GROUP BY Customers.CustomerID
ORDER BY TotalSales DESC
LIMIT 10;
SELECT SUM(UnitPrice * Quantity * (1 - Discount)) AS TotalRevenue
FROM OrderDetails;
