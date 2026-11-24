use CoffeeBites
select*
from Transaction_Items_Clean;

--Total Revenue calculation
select
   SUM(quantity * unit_price) as Total_Revenue
from Transaction_Items_Clean;

---Total orders 
select
  COUNT(DISTINCT transaction_id) as Total_Orders
from Transaction_Items_Clean;

--Average Order Value (AOV)
select
    SUM(quantity * unit_price)/NULLIF(COUNT(DISTINCT transaction_id*1.0),0) as AOV
from Transaction_Items_Clean

---Gross Profit
select
    SUM(quantity * unit_price)-SUM(quantity*unit_cost_at_sale) AS Gross_profit
from Transaction_Items_Clean;

---Gross Profit Margin %
select
    nullif((SUM(quantity * unit_price)-SUM(quantity*unit_cost_at_sale))/SUM(quantity*unit_price),0)*100.0 as Gross_Profit_Margin_pct
from Transaction_Items_Clean

---Monthly Revenue Analysis
select
    FORMAT(order_datetime,'yyyy-MM') AS sales_month,
    SUM(ti.quantity*ti.unit_price) as Monthly_Revenue
from Transaction_raw_Clean as tr
inner join Transaction_Items_Clean as ti  on ti.transaction_id=tr.transaction_id
group by FORMAT(tr.order_datetime,'yyyy-MM')
order by sales_month

---Monthly  Cost & Profit-----------
--Exercise 1 — Monthly Profitability Analysis
-
select
    FORMAT(order_datetime,'yyyy-MM') AS sales_month,
    SUM(ti.quantity*ti.unit_price) as Monthly_Revenue,
    SUM(ti.quantity*ti.unit_cost_at_sale) as Monthly_Product_Cost,
    SUM(quantity * unit_price)-SUM(quantity*unit_cost_at_sale) as Monthly_profit,
    SUM(quantity * unit_price)-SUM(quantity*unit_cost_at_sale)/ nullif(SUM(quantity*unit_price),0)*100.0 as Monthly_profit_margin
from Transaction_raw_Clean as tr
inner join Transaction_Items_Clean as ti  on ti.transaction_id=tr.transaction_id
group by FORMAT(tr.order_datetime,'yyyy-MM')
order by sales_month