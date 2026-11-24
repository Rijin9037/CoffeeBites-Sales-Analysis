----------------Customer Analysis-----------------
use CoffeeBites
select
   customer_id,
   MIN(order_datetime) as First_order_date
from Transaction_raw_Clean 
group by customer_id

----Find customers who purchased for the first time
with firstpurchase AS(
select
   customer_id,
   MIN(order_datetime) as First_order_date
from Transaction_raw_Clean 
group by customer_id
)
select
   tr.customer_id,
   tr.order_datetime,
   f.First_order_date,
   case
       when tr.order_datetime = f.First_order_date
       then 'New customer'
       else 'Retruning customer'
  end as customer_status
from Transaction_raw_Clean as tr
inner join  firstpurchase as f
 on f.customer_id =tr.customer_id;
 

---No of new customer na d retruning customers
with firstpurchase AS(
select
   customer_id,
   MIN(order_datetime) as First_order_date
from Transaction_raw_Clean 
group by customer_id
), 
Customer_status as
(
select
   tr.customer_id,
   tr.order_datetime,
   f.First_order_date,
   case
       when tr.order_datetime = f.First_order_date
       then 'New customer'
       else 'Retruning customer'
  end as customer_status
from Transaction_raw_Clean as tr
inner join  firstpurchase as f
 on f.customer_id =tr.customer_id
 ) 
 select
   COUNT( DISTINCT 
       CASE
           WHEN Customer_status ='New customer'
           then customer_id
       END
       ) AS No_of_New_customer,
    COUNT( DISTINCT 
       CASE
           WHEN Customer_status ='Retruning customer'
           then customer_id
       END
       ) as No_of_Retruning_customer
 from Customer_status;

---Customer retention rate
with firstpurchase AS(
select
   customer_id,
   MIN(order_datetime) as First_order_date
from Transaction_raw_Clean 
group by customer_id
), 
Customer_status as
(
select
   tr.customer_id,
   tr.order_datetime,
   f.First_order_date,
   case
       when tr.order_datetime = f.First_order_date
       then 'New customer'
       else 'Retruning customer'
  end as customer_status
from Transaction_raw_Clean as tr
inner join  firstpurchase as f
 on f.customer_id =tr.customer_id
 ) 
 select
   COUNT( DISTINCT customer_id) AS No_of_total_customer,
    COUNT( DISTINCT 
       CASE
           WHEN Customer_status ='Retruning customer'
           then customer_id
       END
       ) as No_of_Retruning_customer,
     COUNT( DISTINCT 
       CASE
           WHEN Customer_status ='Retruning customer'
           then customer_id
       END
        )*100.0/nullif(COUNT( DISTINCT customer_id),0) as Customer_retention_rate
 from Customer_status;
  
  ----Monthly customer retention rate

 with firstpurchase AS(
select
   customer_id,
   MIN(order_datetime) as First_order_date
from Transaction_raw_Clean 
group by customer_id
), 
Customer_status as
(
select
   tr.customer_id,
   tr.order_datetime,
   f.First_order_date,
   case
       when tr.order_datetime = f.First_order_date
       then 'New customer'
       else 'Retruning customer'
  end as customer_status
from Transaction_raw_Clean as tr
inner join  firstpurchase as f
 on f.customer_id =tr.customer_id
 ) 
 select
   FORMAT(order_datetime,'yyyy-MM') as Month,
   COUNT( DISTINCT customer_id) AS No_of_total_customer,
    COUNT( DISTINCT 
       CASE
           WHEN Customer_status ='Retruning customer'
           then customer_id
       END
       ) as No_of_Retruning_customer,
     COUNT( DISTINCT 
       CASE
           WHEN Customer_status ='Retruning customer'
           then customer_id
       END
        )*100.0/nullif(COUNT( DISTINCT customer_id),0) as Customer_retention_rate
 from Customer_status
 group by  FORMAT(order_datetime,'yyyy-MM')
 order by Month

 ----Customer purchase frequency
 ---Total orders
 select
     c.customer_id,
     COUNT(distinct tr.transaction_id) as total_no_of_orders
 from Transaction_raw_Clean as tr
 inner join Customers as c
  on c.customer_id=tr.customer_id
group by c.customer_id
order by COUNT(distinct tr.transaction_id) asc;

---2nd step--Calculate average purchase frequency
with customerorder as
(
 select
     c.customer_id,
     COUNT(distinct tr.transaction_id) as total_no_of_orders
 from Transaction_raw_Clean as tr
 inner join Customers as c
  on c.customer_id=tr.customer_id
group by c.customer_id
)
select
     avg(cast(total_no_of_orders as decimal(10,2)))as Average_customer_frequnecy
from customerorder;


----Customer Segmentation
with customerorder as
(
 select
     c.customer_id,
     COUNT(distinct tr.transaction_id) as total_no_of_orders
 from Transaction_raw_Clean as tr
 inner join Customers as c
  on c.customer_id=tr.customer_id
group by c.customer_id
),customer_segment as(
select 
    customer_id,
    total_no_of_orders,
    case
        when total_no_of_orders =1 then 'One-time'
        when total_no_of_orders  between 2 and 4 then 'Occasional'
        when total_no_of_orders >=5 then 'Frequent'
     end as customer_segmention
from customerorder
)
select
    customer_segmention,
    COUNT(customer_id) as total_customers
from customer_segment
group by customer_segmention 
order by total_customers desc;


----Top 10 Customers by Revenue
 select top 10
      c.customer_id,
      COUNT(distinct tr.transaction_id) as total_orders,
      SUM(ti.quantity*unit_price) as Revenue
 from Transaction_raw_Clean as tr
 join Transaction_Items_Clean as ti  on tr.transaction_id =ti.transaction_id join  Customers as c on c.customer_id=tr.customer_id
 group by c.customer_id
 order by SUM(ti.quantity*unit_price) desc;

 -----Customer Lifetime Value – Deeper Analysis--
 select
      c.customer_id,
      COUNT(distinct tr.transaction_id) as Total_orders,
      sum(ti.quantity) as Total_quantity,
      SUM(ti.quantity*ti.unit_price) as Total_Revenue,
      SUM(ti.quantity*ti.unit_price)/nullif(COUNT(distinct tr.transaction_id),0) as AOV
 from Transaction_raw_Clean as tr
 inner join Transaction_Items_Clean as ti on ti.transaction_id=tr.transaction_id
 inner join Customers as c on c.customer_id=tr.customer_id
 group by c.customer_id
 order by SUM(ti.quantity*ti.unit_price) desc;

 ----Sales Performance by Order Channel---
 select
      tr.order_channel,
      COUNT(distinct tr.transaction_id) as Total_orders,
      sum( ti.quantity) as Total_quantity_sold,
      SUM(ti.quantity*ti.unit_price) as Total_revenue,
      SUM(ti.quantity*ti.unit_price)*100.0/
      nullif(
             (select SUM(quantity*unit_price) 
               from Transaction_Items_Clean),0) 
                   as Revenue_contribution
 from Transaction_raw_Clean as tr
 inner join Transaction_Items_Clean as ti on ti.transaction_id=tr.transaction_id
 group by tr.order_channel;

 ----Payment Method Analysis
  select
     tr.payment_method,
     COUNT(distinct tr.transaction_id) as Total_orders,
     sum(ti.quantity*ti.unit_price) as Total_Revenue,
     sum(ti.quantity*ti.unit_price)*100.0/nullif(
       (select 
            sum(ti.quantity*ti.unit_price) 
       from Transaction_Items_Clean AS ti)
           ,0) as Percentage_contribution_to_total_revenue
  from Transaction_raw_Clean as tr
  inner join Transaction_Items_Clean as ti on ti.transaction_id=tr.transaction_id
  group by tr.payment_method
  order by Total_Revenue asc;

----Morning Rush-Hour Analysis (7 AM–10 AM)----

-----Calculate orders and revenue for each hour between 7 AM and 10 AM
select
     DATEPART(HOUR,tr.order_datetime) as Order_hour,
     COUNT(distinct tr.transaction_id) as Total_orders,
     SUM(ti.quantity*ti.unit_price) as Total_Revenue
from Transaction_raw_Clean as tr
inner join Transaction_Items_Clean as ti on ti.transaction_id=tr.transaction_id
where  DATEPART(HOUR,tr.order_datetime) between 7 and 9
group by  DATEPART(HOUR,tr.order_datetime)
order by DATEPART(HOUR,tr.order_datetime);

----Weekday vs Weekend Sales Analysis
 ---WEEKDAYS ANALAYSIS
 select
     DATENAME(WEEKDAY,tr.order_datetime) as Weekday_order,
     COUNT(distinct tr.transaction_id) as Total_orders,
     SUM(ti.quantity*ti.unit_price) as Total_Revenue,
    CAST( SUM(ti.quantity*ti.unit_price)/NULLIF(COUNT(distinct tr.transaction_id),0) AS decimal(10,2) )AS Average_order_value
 from Transaction_raw_Clean as tr
 inner join Transaction_Items_Clean as ti on ti.transaction_id=tr.transaction_id
 group by DATENAME(WEEKDAY,tr.order_datetime)
 order by  MIN(CAST(tr.order_datetime AS DATE));

 ----Weekday vs Weekend Sales Comparison
  select
     CASE
         WHEN DATENAME(WEEKDAY,tr.order_datetime) IN ('Sunday','Saturday')
         THEN 'Weekend'
         ELSE 'Weekday'
     END AS Day_type ,
     COUNT(distinct tr.transaction_id) as Total_orders,
     SUM(ti.quantity*ti.unit_price) as Total_Revenue,
    CAST( SUM(ti.quantity*ti.unit_price)/NULLIF(COUNT(distinct tr.transaction_id),0) AS decimal(10,2) )AS Average_order_value
 from Transaction_raw_Clean as tr
 inner join Transaction_Items_Clean as ti on ti.transaction_id=tr.transaction_id
 group by CASE
         WHEN DATENAME(WEEKDAY,tr.order_datetime) IN ('Sunday','Saturday')
         THEN 'Weekend'
         ELSE 'Weekday'
     END
 order by  MIN(CAST(tr.order_datetime AS DATE));


 -----Customer Review Analysis---
 select
     format(tr.order_datetime,'yyyy-MM') as Month,
     AVG(cr.rating) as Average_rating
 from Customer_Reviews_Clean as cr
 INNER JOIN Transaction_raw_Clean as tr on tr.transaction_id=cr.transaction_id
 group by format(tr.order_datetime,'yyyy-MM');

 ---Positive vs Negative Reviews
 select
     COUNT(*) as Total_no_of_review,
     ( CASE 
           WHEN cr.rating between 4 and 5
           THEN 'Positive'
           WHEN cr.rating >=3
           THEN 'Neutral'
           ELSE 'Negative'
      END) AS Review_category
 from Customer_Reviews_Clean as cr
 group by ( CASE 
           WHEN cr.rating between 4 and 5
           THEN 'Positive'
           WHEN cr.rating >=3
           THEN 'Neutral'
           ELSE 'Negative'
      END) ;


  ---Common Customer Complaints
select
     review_comment,
     COUNT(*) as NO_of_reviews
from Customer_Reviews_Clean
where rating<=3
group by review_comment
order by NO_of_reviews desc;


SELECT
    review_comment,
    COUNT(*) AS Total_Reviews,
    AVG(CAST(rating AS DECIMAL(10,2))) AS Average_Rating
FROM Customer_Reviews_Clean
GROUP BY review_comment
ORDER BY Average_Rating ASC;
 select*from Transaction_raw_Clean

 select*from Transaction_Items_Clean;
 select*from Customer_Reviews_Clean
