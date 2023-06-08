-- High Level Sales Analysis

-- 1.  What was the total quantity sold for all products?

-- Per Product

 select p.product_name,count(*) as Quantity_sold
from balanced_tree.sales s
join balanced_tree.product_details p
on s.prod_id=p.product_id
group by 1;

select count(*) as total_quantity_sold
from balanced_tree.sales;

-- 2.  What is the total generated revenue for all products before discounts?

 select sum(qty*price) as total_revenue
 from balanced_tree.sales;

-- Per Product

select p.product_name,sum(s.qty*s.price) as total_revenue
from balanced_tree.sales s
join balanced_tree.product_details p
on s.prod_id=p.product_id
group by 1;

-- 3.  What was the total discount amount for all products?

select sum(qty*price*discount/100) as total_discount
from balanced_tree.sales;

-- Per Product

select p.product_name,sum(s.qty*s.price*s.discount/100) as total_discount
from balanced_tree.sales s
join balanced_tree.product_details p
on s.prod_id=p.product_id
group by 1;


-- Transaction Analysis

-- 1. How many unique transactions were there?

select count(distinct txn_id) as unique_transactions
from balanced_tree.sales;

-- 2. What is the average unique products purchased in each transaction?

select round(avg(sub.products_purchased),3) as avg_products_purchased
from (select txn_id,count(distinct prod_id) as products_purchased
      from balanced_tree.sales 
      group by 1) sub;     

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

with cte as
(select txn_id,(qty*price*1-(discount/100)) as total_revenue
from balanced_tree.sales)

select txn_id,total_revenue,
       NTILE(4) over(partition by txn_id order by total_revenue) as percentile
from cte
group by txn_id,total_revenue;

-- 4. What is the average discount value per transaction?

select txn_id,round(avg(qty*price*discount),3) as average_discount_price
from balanced_tree.sales
group by 1;

-- 5. What is the percentage split of all transactions for members vs non-members?

select 
count(case when member = 't' then 1 end) * 100/(select count(*) from balanced_tree.sales) as "members",
count(case when member = 'f' then 1 end) * 100/(select count(*) from balanced_tree.sales) as "non-members"
from balanced_tree.sales;

-- 6. What is the average revenue for member transactions and non-member transactions?

with cte as
(select case
       when member='t' then (qty*price*1-(discount/100)) end as member_revenue,
       case
       when member='f' then (qty*price*1-(discount/100)) end as "non_member_revenue"
from balanced_tree.sales)

select avg(member_revenue) as avg_member_revenue,avg(non_member_revenue) as avg_non_member_revenue
from cte;

-- Product Analysis

-- 1. What are the top 3 products by total revenue before discount?

select p.product_name,sum(s.qty*s.price) as total_revenue
from balanced_tree.product_details p
join balanced_tree.sales s
on p.product_id=s.prod_id
group by 1
order by 2 desc
limit 3;

-- 2. What is the total quantity, revenue and discount for each segment?

select p.segment_name,
       sum(s.qty) as total_quantity,
       sum(s.qty*s.price*(1-s.discount/100)) as revenue,
       sum(s.qty*s.price*s.discount/100) as discount
from balanced_tree.product_details p
join balanced_tree.sales s
on p.product_id=s.prod_id
group by 1;

-- 3. What is the top selling product for each segment?

with cte as
(select p.segment_name,p.product_name,sum(s.qty) as total_product_sold,
            rank() over(partition by p.segment_name order by sum(s.qty) desc) as product_rank
from balanced_tree.product_details p
join balanced_tree.sales s
on p.product_id=s.prod_id
group by 1,2)

select segment_name,product_name as "top selling product",total_product_sold
from cte
where product_rank=1;

-- 4. What is the total quantity, revenue and discount for each category?

select p.category_name,
       sum(s.qty) as total_quantity,
       sum(s.qty*s.price*(1-s.discount/100)) as revenue,
       sum(s.qty*s.price*s.discount/100) as discount
from balanced_tree.product_details p
join balanced_tree.sales s
on p.product_id=s.prod_id
group by 1;

-- 5. What is the top selling product for each category?

select sub.category_name,sub.product_name as "top selling    
       product",sub.total_product_sold
from (select p.category_name,p.product_name,sum(s.qty) as     
         total_product_sold,
         rank() over(partition by p.category_name order by sum(s.qty) desc) as product_rank
         from balanced_tree.product_details p
         join balanced_tree.sales s
         on p.product_id=s.prod_id
        group by 1,2) sub
where sub.product_rank=1;

-- 6. What is the percentage split of revenue by product for each segment?

select p.segment_name,p.product_name,
sum(s.qty*s.price*1-s.discount/100)*100/(select sum(qty*price*1-discount/100) from balanced_tree.sales) as percentage_split
from balanced_tree.product_details p
join balanced_tree.sales s
on p.product_id=s.prod_id
group by 1,2
order by 1;

-- 7. What is the percentage split of revenue by segment for each category?

select p.category_name,p.segment_name,
sum(s.qty*s.price*1-s.discount/100)*100/(select sum(qty*price*1-discount/100) from balanced_tree.sales) as percentage_split
from balanced_tree.product_details p
join balanced_tree.sales s
on p.product_id=s.prod_id
group by 1,2
order by 1;

-- 8. What is the percentage split of total revenue by category?

select p.category_name,
sum(s.qty*s.price*1-s.discount/100)*100/(select sum(qty*price*1-discount/100) from balanced_tree.sales) as percentage_split
from balanced_tree.product_details p
join balanced_tree.sales s
on p.product_id=s.prod_id
group by 1;