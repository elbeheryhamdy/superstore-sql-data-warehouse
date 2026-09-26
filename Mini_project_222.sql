use SuperstoreDW

select * from [Central_Superstore(Central_Region)]


-- جدول العملاء
create table dim_customer (
Customer_ID nvarchar(50)  primary key,
Customer_Name nvarchar(100),
Segment NVARCHAR(50) );

INSERT INTO dim_customer (customer_id, customer_name, segment)
SELECT DISTINCT Customer_ID, Customer_Name, Segment
FROM [Central_Superstore(Central_Region)]

select * from dim_customer


-- جدول المنتجات
CREATE TABLE dim_product (
 product_id NVARCHAR(50) PRIMARY KEY,
 product_name NVARCHAR(200),
 category NVARCHAR(50),
 sub_category NVARCHAR(50));

INSERT INTO dim_product (product_id, product_name, category, sub_category)
SELECT Product_ID,
MIN(Product_Name) AS product_name,
    MIN(Category) AS category,
    MIN(Sub_Category) AS sub_category
FROM [Central_Superstore(Central_Region)]
GROUP BY Product_ID;

select * from dim_product


-- جدول الموقع الجغرافي
CREATE TABLE dim_location (
location_id INT IDENTITY(1,1) PRIMARY KEY,
country nvarchar(50) ,
city nvarchar(50) , state nvarchar(50) , postal_code int,
region nvarchar(50) ) ;

INSERT INTO dim_location (country, city, state, postal_code, region)
SELECT DISTINCT Country, City, State, Postal_Code, Region
FROM [Central_Superstore(Central_Region)]

select * from dim_location


-- جدول التواريخ
CREATE TABLE dim_date (
date_key INT IDENTITY(1,1) PRIMARY KEY,
order_date DATE,
ship_date DATE);

INSERT INTO dim_date (order_date, ship_date)
SELECT DISTINCT Order_Date, Ship_Date
FROM [Central_Superstore(Central_Region)]

Select * from dim_date


-- جدول أنواع الشحن
CREATE TABLE dim_ship_mode (
ship_mode_id INT IDENTITY(1,1) PRIMARY KEY,
ship_mode NVARCHAR(50));

INSERT INTO dim_ship_mode (ship_mode)
SELECT DISTINCT Ship_Mode
FROM [Central_Superstore(Central_Region)]

SELECT * FROM dim_ship_mode


-- الجدول الرئيسي (Fact Table)
CREATE TABLE fact_sales (
row_id SMALLINT PRIMARY KEY,
order_id NVARCHAR(50),
customer_id NVARCHAR(50) FOREIGN KEY REFERENCES dim_customer(customer_id),
product_id NVARCHAR(50) FOREIGN KEY REFERENCES dim_product(product_id),
location_id INT FOREIGN KEY REFERENCES dim_location(location_id),
ship_mode_id INT FOREIGN KEY REFERENCES dim_ship_mode(ship_mode_id),
date_key INT FOREIGN KEY REFERENCES dim_date(date_key),
sales FLOAT,
quantity INT,
discount FLOAT,
profit FLOAT);

INSERT INTO fact_sales (row_id, order_id, customer_id, product_id, sales, quantity, discount, profit)
SELECT Row_ID, Order_ID, Customer_ID, Product_ID, Sales, Quantity, Discount, Profit
FROM [Central_Superstore(Central_Region)]

SELECT * FROM fact_sales


-- ربط location_id
UPDATE f
SET f.location_id = loc.location_id
FROM fact_sales f
JOIN [Central_Superstore(Central_Region)] s ON f.row_id = s.Row_ID
JOIN dim_location loc 
ON s.City = loc.city 
AND s.State = loc.state 
AND s.Postal_Code = loc.postal_code 
AND s.Region = loc.region;

select * from fact_sales where location_id is null


-- ربط ship_mode_id
UPDATE f
SET f.ship_mode_id = sm.ship_mode_id
FROM fact_sales f
JOIN [Central_Superstore(Central_Region)] s ON f.row_id = s.Row_ID
JOIN dim_ship_mode sm ON s.Ship_Mode = sm.ship_mode;

select * from fact_sales where ship_mode_id is null


-- ربط date_key
UPDATE f
SET f.date_key = d.date_key
FROM fact_sales f
JOIN [Central_Superstore(Central_Region)] s ON f.row_id = s.Row_ID
JOIN dim_date d ON s.Order_Date = d.order_date AND s.Ship_Date = d.ship_date;

SELECT * FROM fact_sales WHERE date_key is null


-- أعلى 5 منتجات مبيعًا
select TOP 5
P.product_name ,
SUM (F.sales) AS total_sales
from fact_sales F
JOIN dim_product P 
ON F.product_id = P.product_id
group by P.product_name
order by total_sales desc


-- أعلى 5 عملاء ربحًا
select TOP 5
C.customer_name,
SUM(F.profit) AS total_profit
from fact_sales F
JOIN dim_customer C
ON F.customer_id = C.customer_id
group by C.customer_name
order by total_profit desc


-- المبيعات حسب الولاية
select
L.state,
SUM(F.sales) AS total_sales
from fact_sales F
JOIN dim_location L
ON F.location_id = L.location_id
group by L.state
order by total_sales desc


-- الأرباح حسب الفئة
select
P.category,
SUM(F.profit) AS total_profit
from fact_sales F
JOIN dim_product P
ON F.product_id = P.product_id
group by P.category
order by total_profit desc


-- تصنيف كل عملية بيع حسب الربحية
select F.row_id,  F.sales,  F.profit,
CASE 
    WHEN F.profit > 100 THEN 'High Profit'
    WHEN F.profit BETWEEN 0 AND 100 THEN 'Low Profit'
    ELSE 'Loss'
END AS profit_category
from fact_sales F


-- عدد العمليات في كل تصنيف
select
CASE 
    WHEN F.profit > 100 THEN 'High Profit'
    WHEN F.profit BETWEEN 0 AND 100 THEN 'Low Profit'
    ELSE 'Loss'
END AS profit_category,
COUNT(*) AS number_of_sales
from fact_sales F
group by
CASE 
    WHEN F.profit > 100 THEN 'High Profit'
    WHEN F.profit BETWEEN 0 AND 100 THEN 'Low Profit'
    ELSE 'Loss'
END


-- CTE: عملاء مبيعاتهم أكتر من 1000
;WITH customer_totals AS (
SELECT 
C.customer_name,
SUM(F.sales) AS total_sales
FROM fact_sales F
JOIN dim_customer C ON F.customer_id = C.customer_id
GROUP BY C.customer_name)

SELECT * FROM customer_totals
WHERE total_sales > 1000
ORDER BY total_sales DESC


-- CTE: متوسط الربح لكل فئة
WITH category_avg_profit AS (
SELECT 
P.category,
AVG(F.profit) AS avg_profit
FROM fact_sales F
JOIN dim_product P ON F.product_id = P.product_id
GROUP BY P.category)

SELECT * FROM category_avg_profit
ORDER BY avg_profit DESC


-- View لأعلى المنتجات
CREATE VIEW top_products AS
SELECT 
P.product_name,
SUM(F.sales) AS total_sales
FROM fact_sales F
JOIN dim_product P ON F.product_id = P.product_id
GROUP BY P.product_name

select top 5 * from top_products
order by total_sales desc


-- Stored Procedure لأعلى N منتج
CREATE PROCEDURE sp_top_products
@top_n INT
AS
BEGIN
select TOP (@top_n)
P.product_name,
SUM(F.sales) AS total_sales
from fact_sales F
JOIN dim_product P
ON F.product_id = P.product_id
group by P.product_name
order by total_sales desc
END

EXEC sp_top_products @top_n = 5
EXEC sp_top_products @top_n = 10
EXEC sp_top_products @top_n = 15
EXEC sp_top_products @top_n = 20




-- المنتجات اللي اتباعت بقيمة أكتر من 500 في عملية واحدة (Subquery)
select product_name, sales
from dim_product P
join fact_sales F on P.product_id = F.product_id
where F.product_id IN (
    select product_id
    from fact_sales
    where sales > 500)


-- أكبر عملية بيع فردية
select TOP 1 *
from fact_sales
order by sales desc

-- متوسط الربح
select AVG(profit) AS avg_profit
from fact_sales

-- عدد العملاء
select COUNT(*) AS total_customers
from dim_customer

-- عدد المنتجات في كل فئة
select category, COUNT(*) AS number_of_products
from dim_product
group by category

-- المبيعات حسب نوع الشحن
select SUM(F.sales) as total_sales , M.ship_mode
from dim_ship_mode M
join fact_sales F
on F.ship_mode_id = M.ship_mode_id
group by M.ship_mode
order by total_sales desc



-- المبيعات حسب السنة
select 
YEAR(D.order_date) AS sales_year,
SUM(F.sales) AS total_sales
from fact_sales F
JOIN dim_date D
ON F.date_key = D.date_key
group by YEAR(D.order_date)
order by sales_year
