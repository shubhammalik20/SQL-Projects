-- 1.How many users are there?

select count(distinct user_id) as users_count
from clique_bait.users;

-- 2.How many cookies does each user have on average?

select round(avg(sub.cookie_count),2) as avg_cookie
from (select user_id,count(cookie_id) as cookie_count
         from clique_bait.users
         group by 1) sub;

-- 3. What is the unique number of visits by all users per month?

select month(e.event_time) as month,
          count(distinct u.user_id) as unique_user_count
from clique_bait.users u 
join clique_bait.events e
on u.cookie_id=e.cookie_id
group by 1;

-- 4. What is the number of events for each event type?

select e.event_type,n.event_name,count(*) as event_count
from clique_bait.events e
join clique_bait.event_identifier n
on e.event_type=n.event_type
group by 1,2;

-- 5. What is the percentage of visits which have a purchase event?

select count(*)*100/(select count(*) from clique_bait.events) as purchase_percentage
from clique_bait.events
where event_type='3';

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

select count(*)*100/(select count(*) from clique_bait.events) as checkout_count_percentage
from clique_bait.events
where event_type='2';

-- 7. What are the top 3 pages by number of views?

select p.page_id,count(*) as view_count
from clique_bait.events e
join clique_bait.page_hierarchy p
on e.page_id=p.page_id
group by 1
order by 2 desc
limit 3;

-- 8. What is the number of views and cart adds for each product category?

select a.product_category,a.views_count,b.cart_adds_count
from (select p.product_category,count(*) as views_count
          from clique_bait.events e
          join clique_bait.page_hierarchy p
          on e.page_id=p.page_id
          where e.event_type = '1'
          group by 1) a
join (select p.product_category,count(*) as cart_adds_count
       from clique_bait.events e
       join clique_bait.page_hierarchy p
       on e.page_id=p.page_id
       where e.event_type = '2'
       group by 1) b
on a.product_category=b.product_category;

-- 9. How many times was each product viewed?

select p.product_id,p.page_name,count(*) as products_viewed
from clique_bait.events e
join clique_bait.page_hierarchy p
on e.page_id=p.page_id
where e.event_type='1'
group by 1;

-- 10. How many times was each product added to cart?

select p.product_id,p.page_name,count(*) as products_added
from clique_bait.events e
join clique_bait.page_hierarchy p
on e.page_id=p.page_id
where e.event_type='2'
group by 1,2;

-- 11. How many times was each product added to a cart but not purchased (abandoned)?

select sub.product_id,sub.page_name,count(*) as cart_count
 from (select p.product_id,p.page_name,e.event_type,
      lead(e.event_type) over (partition by p.product_id order by 
      e.event_type) as    
      next_event
      from clique_bait.events e
      join clique_bait.page_hierarchy p
      on e.page_id=p.page_id) sub
where sub.next_event<>'3' and 
     sub.event_type = '2'
group by 1,2;

-- 12. How many times was each product purchased?

with cte1 as
(select e.visit_id,p.page_id,p.page_name,e.event_type
from clique_bait.events e
join clique_bait.page_hierarchy p
on e.page_id=p.page_id
where e.event_type=2),
cte2 as
(select e.visit_id,p.page_id,p.page_name,e.event_type
from clique_bait.events e
join clique_bait.page_hierarchy p
on e.page_id=p.page_id
where e.event_type=3)
select cte1.page_name as Product, count(*) as product_purchase
from cte1
join cte2
on cte1.visit_id=cte2.visit_id
group by 1
order by 2 desc