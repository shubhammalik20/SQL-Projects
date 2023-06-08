-- 1. Who is the senior most employee based on job title?
select title,first_name,last_name
from employee
order by levels desc
limit 1;

-- Q2: Which countries have the most Invoices?

select billing_country,count(*) as total_invoice
from invoice
group by 1
order by 2 desc
limit 1;

-- 3. What are top 3 values of total invoice?

select total
from invoice
order by total desc 
limit 3;

-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city,
--    we made the most money. Write a query that returns one city that 
--    has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--    totals

select billing_city,sum(total) as invoice_total
from invoice
group by 1
order by  2 desc
limit 1;

-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money

select c.customer_id,c.first_name,c.last_name,sum(i.total) as money_spent
from customer c
join invoice i
on c.customer_id=i.customer_id
group by 1
order by 4 desc;

-- 6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A

-- Method 1
select distinct c.email,c.first_name,c.last_name
from customer c
join invoice i
on c.customer_id=i.customer_id
join invoice_line l
on i.invoice_id=l.invoice_id 
where l.track_id in (select track_id
                     from track 
                     join genre
                     on track.genre_id=genre.genre_id
                     where genre.name='Rock')
order by 1 asc;

-- Method 2

select distinct c.email,c.first_name,c.last_name
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line l on i.invoice_id=l.invoice_id 
join track t on l.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
where g.name='Rock'
order by 1 asc;

-- 7. Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

select a.name,count(t.track_id) as track_count
from artist a
join album b on a.artist_id=b.artist_id
join track t on b.album_id=t.album_id
group by 1
order by 2 desc
limit 10;

-- 8. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select name,milliseconds as length
from track
where milliseconds > (select avg(milliseconds)
				      from track)
order by 2 desc;

-- 9. Find how much amount spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent    

select c.first_name,c.last_name , a.name as artist_name,
       sum(l.unit_price*l.quantity) as amount_spent
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line l on i.invoice_id=l.invoice_id
join track t on l.track_id=t.track_id
join album b on t.album_id=b.album_id
join artist a on b.artist_id=a.artist_id
group by 1,2
order by 4 desc;

-- 10. Find how much amount spent by each customer on most earned artists? 
-- Write a query to return customer name, artist name and total spent  

with cte as
(select a.artist_id,a.name as artist_name,sum(l.unit_price*l.quantity) as max_earned
from invoice_line l 
join track t on l.track_id=t.track_id
join album b on t.album_id=b.album_id
join artist a on b.artist_id=a.artist_id
group by 1,2
order by 3 desc
limit 1)

select c.first_name,c.last_name,cte.artist_name,
       sum(l.unit_price*l.quantity) as amount_spent
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line l on i.invoice_id=l.invoice_id
join track t on l.track_id=t.track_id 
join album b on t.album_id=b.album_id
join cte on b.artist_id=cte.artist_id
group by 1,2,3
order by 4 desc;

-- 11. We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres.

select sub.country,sub.name,sub.popular_purchase
from (select c.country,g.name,sum(l.quantity) as popular_purchase,
			rank() over (partition by c.country order by sum(l.quantity) desc) as purchase_rank
	  from customer c
      join invoice i on c.customer_id=i.customer_id
      join invoice_line l on i.invoice_id=l.invoice_id
      join track t on l.track_id=t.track_id
      join genre g on t.genre_id=g.genre_id
      group by 1,2) sub
where sub.purchase_rank=1;

-- 12. Write a query that determines the customer that has spent the most on music for each country.
--     Write a query that returns the country along with the top customer and how much they spent.
--     For countries where the top amount spent is shared, provide all customers who spent this amount.

select sub.country,sub.first_name,sub.last_name,sub.amount_spent
from (select c.country,c.first_name,c.last_name,sum(i.total) as amount_spent,
             rank() over (partition by c.country order by sum(i.total) desc) spent_rank 
      from customer c
      join invoice i on c.customer_id=i.customer_id
	  group by 1,2,3) sub
where sub.spent_rank=1;      
