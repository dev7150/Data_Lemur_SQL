-- Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.
SELECT candidate_id FROM candidates
where skill in ( 'Python','Tableau','PostgreSQL')
group by 1
having COUNT(*) > 2

-- Assume you are given the tables below about Facebook pages and page likes. Write a query to return the page IDs of all the Facebook pages that don't have any likes. The output should be in ascending order.
SELECT p.page_id FROM pages p
left join page_likes pl
on p.page_id = pl.page_id
where pl.page_id is NULL
order by 1;

-- Tesla is investigating bottlenecks in their production, and they need your help to extract the relevant data. Write a SQL query that determines which parts have begun the assembly process but are not yet finished.
SELECT part FROM parts_assembly
where finish_date is NULL
group by part;

-- Laptop vs. Mobile Viewership
SELECT sum(case when device_type='laptop' then 1 else 0 end) as laptop_views,
sum(case when device_type in ('tablet','phone') then 1 else 0 end) as mobile_views
FROM viewership

-- Cities With Completed Trades
SELECT u.city as city,count(t.order_id) as total_orders FROM trades t
join users u 
on t.user_id = u.user_id
where status = 'Completed'
group by 1
order by 2 DESC
limit 3

-- Duplicate Job Listings
Select COUNT(*) as co_w_duplicate_jobs
from (SELECT COUNT(*) 
FROM job_listings jl
GROUP BY company_id,title,description
having count(*)>1) z

-- Histogram of Tweets
with base as(
SELECT 
  user_id, 
  COUNT(tweet_id) AS tweets_num 
FROM tweets 
WHERE tweet_date BETWEEN '2022-01-01' AND '2022-12-31' 
GROUP BY user_id
)

Select tweets_num as tweet_bucket,
count(user_id) as users_num
from base
group by 1

