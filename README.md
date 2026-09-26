# superstore-sql-data-warehouse
A SQL Server project that transforms raw retail sales data (Central Superstore) into a structured analytical data warehouse using a Star Schema, with SQL-based reports ready for executive analysis.

📌 Overview

This project takes raw sales data from an Excel file (2,323 sales transactions) and transforms it into a normalized relational database suitable for business reporting and KPI monitoring.

🛠️ Tools Used
SQL Server (SSMS)
T-SQL for querying and analysis
🗂️ Database Structure (Star Schema)

The database follows a Star Schema design: a central Fact table surrounded by Dimension tables.

Table	Type	Description
fact_sales	Fact Table	Every sales transaction, with measures (sales, profit, discount, quantity) and foreign keys to all dimensions
dim_customer	Dimension	Customer details (name, segment)
dim_product	Dimension	Product details (name, category, sub-category)
dim_location	Dimension	Location details (city, state, region)
dim_date	Dimension	Order and ship dates
dim_ship_mode	Dimension	Shipping modes

All dimension tables are linked to fact_sales via Foreign Keys, and each table has its own Primary Key.

📊 Analysis Included

The SQL file contains 20+ queries covering:

Top-selling products and most profitable customers
Sales distribution by state and shipping mode
Profitability classification of transactions (using CASE)
Sales trends over time (yearly sales trends)
Analysis using CTEs and Subqueries
⚙️ Advanced Features
View: top_products — a ready-made summary of top-selling products
Stored Procedure: sp_top_products — returns the top N products, with N passed as a parameter at runtime
Indexes: on key fact_sales columns to optimize query performance
📁 File Contents

Mini_project_222.sql includes, in order:

Star Schema table creation (Dimensions + Fact)
Data loading and linking between tables
Analytical queries
Views and Stored Procedures
Indexes
🚀 How to Run
Open SQL Server Management Studio (SSMS)
Import Central_Superstore.xlsx as a staging table
Run Mini_project_222.sql from top to bottom
