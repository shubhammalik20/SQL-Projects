
-- What day of the week is used for each week_date value?

select date,dayname(date) as day,week_number
from clean_weekly_sales;

-- What range of week numbers are missing from the dataset?

select distinct week_number as week_number_range
from clean_weekly_sales
order by 1;

-- How many total transactions were there for each year in the dataset?

select year,count(transactions) as total_count
from clean_weekly_sales 
group by 1
order by 2;

-- What is the total sales for each region for each month?

select region,month_number,sum(sales) as total_sales
from clean_weekly_sales
group by 1,2
order by 1,2;

-- What is the total count of transactions for each platform

select platform,count(transactions) as total_count
from clean_weekly_sales 
group by 1
order by 2;

-- What is the percentage of sales for Retail vs Shopify for each month?

select platform,sum(sales) * 100/ (select sum(sales) from clean_weekly_sales) as percentage_sales
from clean_weekly_sales
group by 1;

-- What is the percentage of sales by demographic for each year in the dataset?

select demographic,year,sum(sales) * 100/ (select sum(sales) from clean_weekly_sales) as percentage_sales
from clean_weekly_sales
group by 1,2
order by 1,2;

-- Which age_band and demographic values contribute the most to Retail sales?

select demographic,age_band,sum(sales) as total_sales
from clean_weekly_sales
group by 1,2
order by 3 desc;

select demographic,age_band,sum(sales) as total_sales
from clean_weekly_sales
where demographic <> 'Unknown' and age_band <> 'Unknown'   -- if have to remove unknown
group by 1,2
order by 3 desc;

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify?
--   If not - how would you calculate it instead?

select year,platform,sum(sales)/count(transactions) as average_transaction_size
from clean_weekly_sales
group by 1,2
order by 1,2;
