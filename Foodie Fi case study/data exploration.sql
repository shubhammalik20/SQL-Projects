-- 1. How many customers has Foodie-Fi ever had?
  
  select count(distinct customer_id) as unique_customers
  from subscriptions;
  
-- 2. What is the monthly distribution of trial plan start_date values for our dataset? — 
--    Use the start of the month as the group by value.

select month(start_date) as month_date,monthname(start_date) as month,
       count(*) as total_customer
from subscriptions
where plan_id='0'
group by 1
order by 1 asc;

-- 3. What plan start_date values occur after the year 2020 for our dataset? 
--    Show the breakdown by count of events for each plan_name

select p.plan_name,count(s.customer_id) as total_events
from subscriptions s
join plans p
on s.plan_id=p.plan_id
where s.start_date >='2021-01-01'
group by 1;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

select count(*) as customer_count,
       round(count(*)*100/(select count(distinct customer_id) from subscriptions),1) as churned_customer_percent
from subscriptions
where plan_id = '4';

-- 5.How many customers have churned straight after their initial free trial
-- what percentage is this rounded to the nearest whole number?

with cte as
(select *,row_number() over(partition by customer_id order by plan_id) as plan_rank
from subscriptions)
select count(*) as churn_count,
round(count(*) * 100/(select count(distinct customer_id) from subscriptions),0) as churn_percentage
from cte 
where plan_id='4' and ranks=2;

-- 6. What is the number and percentage of customer plans after their initial free trial?

with cte as
(select *,lead(plan_id) over(partition by customer_id order by plan_id) as next_plan
from subscriptions)
select cte.next_plan,count(*) as customer_count,
round((count(*)*100/(select count(distinct customer_id) from subscriptions)),1) as customer_percentage
from cte
where next_plan is not null and plan_id='0'
group by 1
order by 1;
 
-- 7. How many customers have upgraded to an annual plan in 2020? 

select count(distinct customer_id) as customer_count
from subscriptions
where plan_id='3' and start_date <'2021-01-01';

-- 8. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

select avg(datediff(b.start_date,a.start_date))
from (select *
      from subscriptions
      where plan_id='0') a
join (select *
     from subscriptions
     where plan_id='3') b
on a.customer_id=b.customer_id;     

-- 9.How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

with cte as
(select *,lead(plan_id) over(partition by customer_id order by plan_id) as next_plan
from subscriptions)
select count(*) as downgrade
from cte
where plan_id='2' and next_plan='1' and start_date <'2021-01-01';