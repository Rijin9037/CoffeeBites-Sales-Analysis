------Product Performance Analysis-----------
use CoffeeBites
---Exercise 2: Top 5 Best-Selling Products
select top(5)
    p.product_name,
    sum(ti.quantity) as Total_quantity,
    sum(ti.quantity*ti.unit_price) as Total_Revenue,
    sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale) AS Total_Gross_profit
from Transaction_Items_Clean as ti 
Inner join  Product as p
   on ti.product_id =p.product_id
Group by product_name
order by Total_Revenue desc;

----Product Profit Margin
select top(5)
    p.product_id,
    p.product_name,
    sum(ti.quantity*ti.unit_price) as Total_Revenue,
    sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale) AS Total_Gross_profit,
    (sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale))/nullif(sum(ti.quantity*ti.unit_price),0)*100.0  as Total_profit_margin_pct
from Transaction_Items_Clean as ti 
Inner join  Product as p
   on ti.product_id =p.product_id
Group by p.product_id,
         p.product_name
order by Total_Revenue desc;

---find the five lowest-margin products.
select top(5)
    p.product_id,
    p.product_name,
    sum(ti.quantity*ti.unit_price) as Total_Revenue,
    sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale) AS Total_Gross_profit,
    (sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale))/nullif(sum(ti.quantity*ti.unit_price),0)*100.0  as Total_profit_margin_pct
from Transaction_Items_Clean as ti 
Inner join  Product as p
   on ti.product_id =p.product_id
Group by p.product_id,
         p.product_name
order by Total_profit_margin_pct asc;

--Find the lowest-margin product overall
select
    p.product_id,
    p.product_name,
    sum(ti.quantity*ti.unit_price) as Total_Revenue,
    sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale) AS Total_Gross_profit,
    (sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale))/nullif(sum(ti.quantity*ti.unit_price),0)*100.0  as Total_profit_margin_pct
from Transaction_Items_Clean as ti 
Inner join  Product as p
   on ti.product_id =p.product_id
Group by p.product_id,
         p.product_name
order by Total_profit_margin_pct asc;

---Monthly Product Profitability
with as monthly_product_ analysis(
select
     FORMAT(tr.order_datetime,'yyyy-MM') AS Sales_month,
     p.product_name,
     SUM(ti.quantity) as Total_quantity_sold,
     sum(ti.quantity*ti.unit_price) as Monthly_Revenue,
     sum(ti.quantity*ti.unit_cost_at_sale) as Monthly_Product_Cost,
     sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale) AS Monthly_Gross_Profit,
     (sum(ti.quantity*ti.unit_price) - sum (ti.quantity*ti.unit_cost_at_sale))/
        nullif(sum(ti.quantity*ti.unit_price),0)*100.0
        as Monthly_Gross_Profit_Margin_pct
from Transaction_raw_Clean as tr 
inner join  Transaction_Items_Clean as ti
 on ti.transaction_id =tr.transaction_id
inner join Product as p
 on p.product_id =ti.product_id
group by FORMAT(tr.order_datetime,'yyyy-MM'),
    p.product_name
order by Sales_month,
    Monthly_Revenue desc;
) 
select*
from monthly_product_ analysis
    ---Which product had the biggest revenue decline from July to October?
    




select
   p.product_name,
   SUM(case 
         when month(tr.order_datetime) =7
         then ti.quantity*ti.unit_price
         else 0
       end) as July_Revenue,
   SUM(case 
         when month(tr.order_datetime) =10
         then ti.quantity*ti.unit_price
         else 0
       end) as Oct_Revenue , 
  SUM(case 
         when month(tr.order_datetime) =7
         then ti.quantity*ti.unit_price
         else 0
       end)
       -     
   SUM(case 
         when month(tr.order_datetime) =10
         then ti.quantity*ti.unit_price
         else 0
       end) as Revenue_differnce
from Transaction_raw_Clean as tr
inner join Transaction_Items_Clean as ti
 on ti.transaction_id= tr.transaction_id
 inner join  Product as p
  on p.product_id =ti.product_id
group by p.product_name
order by Revenue_differnce desc;





