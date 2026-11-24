USE CoffeeBites;

SELECT COUNT(*) AS c FROM Customers;
SELECT COUNT(*) AS p FROM Product;
SELECT COUNT(*) AS tr FROM Transaction_raw_Clean;
SELECT COUNT(*) AS ti FROM Transaction_Items_Clean;
SELECT COUNT(*) AS r FROM Customer_Reviews_Clean;


USE CoffeeBites;
GO

-- Check duplicate Customer IDs
SELECT customer_id, COUNT(*) AS Duplicate_Count
FROM Customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check duplicate Product IDs
SELECT product_id, COUNT(*) AS Duplicate_Count
FROM Product
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Check duplicate Transaction IDs
SELECT transaction_id, COUNT(*) AS Duplicate_Count
FROM Transaction_raw_Clean
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Check duplicate Review IDs
SELECT review_id, COUNT(*) AS Duplicate_Count
FROM Customer_Reviews_Clean
GROUP BY review_id
HAVING COUNT(*) > 1;

--Checking missing ID
SELECT COUNT(*) AS Missing_Customers
FROM Customers
WHERE customer_id IS NULL;

SELECT COUNT(*) AS Missing_Products
FROM Product
WHERE product_id IS NULL;

SELECT COUNT(*) AS Missing_Transactions
FROM Transaction_raw_Clean
WHERE transaction_id IS NULL;

SELECT COUNT(*) AS Missing_Reviews
FROM Customer_Reviews_Clean
WHERE review_id IS NULL;


--
SELECT ti.transaction_id
FROM Transaction_Items_Clean AS ti
LEFT JOIN Transaction_raw_Clean AS t
    ON ti.transaction_id = t.transaction_id
WHERE t.transaction_id IS NULL;

SELECT ti.product_id
FROM Transaction_Items_Clean AS ti
LEFT JOIN Product AS p
    ON ti.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT DISTINCT t.customer_id
FROM Transaction_raw_Clean AS t
LEFT JOIN Customers AS c
    ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

ALTER TABLE Transaction_raw_Clean
ALTER COLUMN customer_id NVARCHAR(50) NULL;

ALTER TABLE Customer_Reviews_Clean
ALTER COLUMN customer_id NVARCHAR(50) NULL;

UPDATE Transaction_raw_Clean
SET customer_id = NULL
WHERE LTRIM(RTRIM(customer_id)) = 'Unknown';

UPDATE Customer_Reviews_Clean
SET customer_id = NULL
WHERE LTRIM(RTRIM(customer_id)) = 'Unknown';

SELECT COUNT(*) AS Unknown_Transactions
FROM Transaction_raw_Clean
WHERE customer_id = 'Unknown';

SELECT COUNT(*) AS Unknown_Reviews
FROM Customer_Reviews_Clean
WHERE customer_id = 'Unknown';
---foriegn key creation
USE CoffeeBites;
GO

-- 1. Transactions → Customers
ALTER TABLE Transaction_raw_Clean
ADD CONSTRAINT FK_Transactions_Customers
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id);
GO

-- 2. Transaction Items → Transactions
ALTER TABLE Transaction_Items_Clean
ADD CONSTRAINT FK_Items_Transactions
FOREIGN KEY (transaction_id)
REFERENCES Transaction_raw_Clean(transaction_id);
GO

-- 3. Transaction Items → Products
ALTER TABLE Transaction_Items_Clean
ADD CONSTRAINT FK_Items_Products
FOREIGN KEY (product_id)
REFERENCES Product(product_id);
GO

-- 4. Reviews → Transactions
ALTER TABLE Customer_Reviews_Clean
ADD CONSTRAINT FK_Reviews_Transactions
FOREIGN KEY (transaction_id)
REFERENCES Transaction_raw_Clean(transaction_id);
GO

-- 5. Reviews → Customers
ALTER TABLE Customer_Reviews_Clean
ADD CONSTRAINT FK_Reviews_Customers
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id);
GO

---Verify foreign key
SELECT
    name AS Foreign_Key_Name,
    OBJECT_NAME(parent_object_id) AS Child_Table,
    OBJECT_NAME(referenced_object_id) AS Parent_Table
FROM sys.foreign_keys;

----Joining Tables--------------------------------------------------------
---SQL JOINs and Revenue Analysis---
--How much revenue did CoffeeBites generate from each product?
select
*from Product;

select*from Transaction_Items_Clean;

SELECT
   p.product_id,
   p.product_name,
   ti.transaction_id,
   ti.unit_price,
   ti.quantity,
   ti.quantity* ti.unit_price as Revenue

FROM Product as p
Inner join Transaction_Items_Clean as ti
   on p.product_id =ti.product_id;

--Calculate total revenue by product-----
SELECT
   p.product_id,
   p.product_name,
   sum(ti.quantity) as Total_quantity_sold,
   SUM(ti.quantity*ti.unit_price) as Total_Revenue
FROM Product AS p
INNER JOIN Transaction_Items_Clean AS ti
  ON p.product_id =ti.product_id
GROUP BY 
  p.product_id,
  p.product_name
ORDER BY 
 Total_Revenue desc;

 ---Exercise 1: Find total revenue for all products combined.
 SELECT
   p.product_id,
   p.product_name,
   SUM(ti.quantity*ti.unit_price) AS Total_Revenue 
 FROM Product as p
 INNER JOIN Transaction_Items_Clean as ti 
  ON p.product_id = ti.product_id
GROUP BY 
  P.product_id,
  P.product_name
ORDER BY Total_Revenue DESC;

---Exercise 2: Find the total quantity sold for each product.
SELECT
   p.product_name,
   SUM(ti.quantity) AS Total_quantity_sold
FROM Product as p
INNER JOIN Transaction_Items_Clean AS ti ON p.product_id =ti.product_id
GROUP BY
   p.product_name
ORDER BY 
   Total_quantity_sold DESC;

---Exercise 3: Display the top 5 products by revenue.
 SELECT TOP (5)
   p.product_name,
   SUM(ti.quantity) AS Total_quantity_sold,
   SUM(ti.quantity*ti.unit_price) AS Total_Revenue 
 FROM Product as p
 INNER JOIN Transaction_Items_Clean as ti 
  ON p.product_id = ti.product_id
GROUP BY 
  P.product_name
ORDER BY Total_Revenue  ASC;





--Product
select*
from Product;


select
  p.product_id,
  ti.transaction_id,
  ti.quantity
from Product as p
left join Transaction_Items_Clean as ti 
on p.product_id = ti.product_id




