  -- 1 What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(m.price) as total_amount_spent
from sales s
join menu m
on s.product_id=m.product_id
group by s.customer_id;

-- 2 How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date)
from sales 
group by customer_id;

-- 3 What was the first item from the menu purchased by each customer?
select sub.customer_id,sub.product_name
from (select s.customer_id,m.product_name,
	   dense_rank() over(partition by s.customer_id order by s.order_date asc) as order_purchase
       from sales s
       join menu m
	   on s.product_id=m.product_id ) sub
where sub.order_purchase=1
group by sub.customer_id,sub.product_name;

-- 4 What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name,count(m.product_name) as total_purchased
from sales s
join menu m
on s.product_id=m.product_id
group by m.product_name
order by total_purchased desc
limit 1;

-- 5 Which item was the most popular for each customer?
with cte as 
(select s.customer_id,m.product_name,count(s.product_id) as order_count,
       dense_rank() over(partition by s.customer_id order by count(s.product_id) desc) as popular
from sales s
join menu m
on s.product_id=m.product_id
group by s.customer_id,m.product_name)
select customer_id,product_name,order_count
from cte
where popular=1;

-- 6 Which item was purchased first by the customer after they became a member?

-- Method 1
with cte as
(select s.customer_id,m.product_name,s.order_date,b.join_date,
	   row_number() over(partition by s.customer_id order by s.order_date asc) as ranked_items
from sales s
join menu m
on s.product_id=m.product_id
join members b
on s.customer_id=b.customer_id
where s.order_date>=b.join_date)
select customer_id,product_name,order_date,join_date
from cte
where ranked_items=1;

-- Method 2

WITH cte AS 
(SELECT s.customer_id, m.join_date, s.order_date,s.product_id,
 DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS ranked
 FROM sales AS s
 JOIN members AS m
 ON s.customer_id = m.customer_id
 WHERE s.order_date >= m.join_date)
SELECT cte.customer_id, cte.order_date, u.product_name 
FROM cte 
JOIN menu u
 ON cte.product_id = u.product_id
Where cte.ranked = 1;

-- 7 Which item was purchased just before the customer became a member?

-- Method 1
with cte as
(select s.customer_id,m.product_name,s.order_date,b.join_date,
	   dense_rank() over(partition by s.customer_id order by s.order_date desc) as ranked_items
from sales s
join menu m
on s.product_id=m.product_id
join members b
on s.customer_id=b.customer_id
where s.order_date<b.join_date)
select customer_id,product_name,order_date,join_date
from cte
where ranked_items=1;

-- Method 2

SELECT cte.customer_id, cte.order_date, u.product_name  
from (SELECT s.customer_id, m.join_date, s.order_date,s.product_id,
 DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date desc) AS ranked
 FROM sales AS s
 JOIN members AS m
 ON s.customer_id = m.customer_id
 WHERE s.order_date < m.join_date) cte
JOIN menu u
 ON cte.product_id = u.product_id
Where cte.ranked = 1
order by cte.customer_id;

-- 8 What is the total items and amount spent for each member before they became a member?
select s.customer_id,count(distinct s.product_id) as total_items,sum(m.price) as amount_spent
from sales s
join menu m
on s.product_id=m.product_id
join members b
on s.customer_id=b.customer_id
where s.order_date<b.join_date
group by s.customer_id;

-- 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
-- then how many points would each customer have?

-- Method 1
select sub.customer_id,sum(sub.points) as total_points
from (select s.customer_id,m.product_name,
       case when s.product_id=1 then price*20
       else price*10 end as points
from sales s
join menu m
on s.product_id=m.product_id) sub
group by sub.customer_id
order by sub.customer_id;

-- Method 2

WITH price_points AS
 (SELECT *, 
 CASE WHEN product_id = 1 THEN price * 20 ELSE price * 10 END AS points
 FROM  menu) 
 SELECT 
s.customer_id, SUM(p.points) AS total_points
FROM price_points AS p
JOIN sales AS s
ON p.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id; 

-- 10 
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--  not just sushi then how many points do customer A and B have at the end of January?
select sub.customer_id,sum(sub.points)
from (with cte as 
(select s.customer_id,s.product_id,u.product_name,u.price,s.order_date,m.join_date
  ,adddate(join_date,interval 6 day) as new_date
from sales s
join members m
on s.customer_id=m.customer_id
join menu u
on s.product_id=u.product_id)
select *,case when cte.order_date between cte.join_date and cte.new_date then cte.price*20
       else cte.price*10 end as points
from cte
where cte.order_date<='2021-01-31') sub
group by sub.customer_id
order by sub.customer_id;


-- Bonus Questions
-- 1) The following questions are related creating basic data tables that Danny and
--  his team can use to quickly derive insights without needing to join the underlying tables using SQL.
select s.customer_id,u.product_name,u.price,s.order_date,
       case when s.customer_id not in(select customer_id from members) then "N" 
	   when s.order_date in (select sales.order_date from sales join members on sales.customer_id=members.customer_id
                              where sales.order_date>=members.join_date)  then "Y"
       else 'N' end as members                       
from sales s
join menu u
on s.product_id=u.product_id
order by s.customer_id;

--  2) Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking 
-- for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
with cte as
(select sub.*,
        case when sub.members="N" then "Null"
		when sub.members="Y" then  dense_rank() over(partition by sub.customer_id order by sub.order_date asc) end as old_ranking
from (select s.customer_id,u.product_name,u.price,s.order_date,
       case when s.customer_id not in(select customer_id from members) then "N" 
	   when s.order_date in (select sales.order_date from sales join members on sales.customer_id=members.customer_id
                              where sales.order_date>=members.join_date)  then "Y"
       else 'N' end as members                       
from sales s
join menu u
on s.product_id=u.product_id
order by s.customer_id) sub)

select customer_id,product_name,price,order_date,members,old_ranking,
(case when old_ranking is not null then dense_rank() over(partition by customer_id order by order_date asc )
else Null end) as ranking
from cte;
