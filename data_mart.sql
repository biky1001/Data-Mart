#-------------------------------------------Data Mart-------------------------------------------#
create database casestudy;


use casestudy;


select * from weekly_sales limit 10;


#-----Data Cleaning------#
create table clean_weekly_sales as
select week_date, week(week_date) as 'week_number',
month(week_date) as 'month_number',
year(week_date) as 'calendar_year',
region, platform, 
case
	when segment = null then 'unknown'
    else segment
end as 'segment',
case
	when right(segment,1) = '1' then 'Young Adults'
    when right(segment,1) = '2' then 'Middle Aged'
    when right(segment,1) in ('3','4') then 'retirees'
    else 'unknown'
end as 'age_band',
case 
	when left(segment,1) = 'C' then 'Couples'
    when left(segment,1) = 'F' then 'Families'
    else 'Unknown'
end as 'demographic',
customer_type, transactions, sales,
round(sales/transactions, 2) as 'avg_transaction'
from weekly_sales;

select *
from clean_weekly_sales
limit 10;






#-----Data Exploration----#
## 1. Which week numbers are missing from the dataset? ##
create table seq100
(x int not null auto_increment primary key);


insert into seq100 values (),(),(),(),(),(),(),(),(),();      # inserting 10 number in x
insert into seq100 values (),(),(),(),(),(),(),(),(),();      # inserting 10 number in x
insert into seq100 values (),(),(),(),(),(),(),(),(),();       # inserting 10 number in x
insert into seq100 values (),(),(),(),(),(),(),(),(),();        # inserting 10 number in x
insert into seq100 values (),(),(),(),(),(),(),(),(),();      # inserting 10 number in x

select * from seq100;

insert into seq100
select x+50 from seq100;            # inserting the more 50 values to x in seq100

create table seq52 as (select x from seq100 limit 52);

select distinct x as week_day 
from seq52 
where x not in(select distinct week_number from clean_weekly_sales); 




## 2. How many total transactions were there for each year in the dataset?  ##
select calendar_year, sum(transactions) as 'total_transactions'
from clean_weekly_sales
group by calendar_year;



## 3. What are the total sales for each region for each month?  ##
select region, month_number, sum(sales) as 'total_sales'
from clean_weekly_sales
group by  month_number, region
order by month_number;



## 4. What is the total count of transactions for each platform ?  ##
select platform, count(transactions) as 'cnt of transactions'
from clean_weekly_sales
group by platform;



## 5. What is the percentage of sales for Retail vs Shopify for each month?  ##
WITH cte_monthly_platform_sales AS 
(
SELECT month_number, calendar_year, platform, SUM(sales) AS monthly_sales
FROM clean_weekly_sales
GROUP BY month_number,calendar_year, platform
)
SELECT month_number, calendar_year,
ROUND(100 * MAX(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) / SUM(monthly_sales),2) AS retail_percentage,
ROUND(100 * MAX(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) /SUM(monthly_sales),2) AS shopify_percentage
FROM cte_monthly_platform_sales
GROUP BY month_number,calendar_year
ORDER BY month_number,calendar_year;



## 6. What is the percentage of sales by demographic for each year in the dataset? ##
select calendar_year, demographic, sum(sales) as 'yearly_sales',
round(100*sum(sales)/ sum(sum(sales)) over(partition by demographic),2) as 'percentage'     # over() function performs row wise aggregation
from clean_weekly_sales
group by calendar_year, demographic
order by yearly_sales;



## 7. Which age_band and demographic values contribute the most to Retail Sales? ##
select age_band, demographic, sum(sales) as 'total_sales'
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by total_sales desc;