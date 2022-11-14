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
limit 3;

-- Duplicate Job Listings
Select COUNT(*) as co_w_duplicate_jobs
from (SELECT COUNT(*) 
FROM job_listings jl
GROUP BY company_id,title,description
having count(*)>1) z;

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

-- LinkedIn Power Creators (Part 1)
SELECT profile_id FROM personal_profiles pp
join company_pages cp on
pp.employer_id = cp.company_id
and cp.followers < pp.followers
order by 1;


-- Spare Server Capacity
WITH total_demand AS (
  SELECT 
    datacenter_id,
    sum(monthly_demand) as total_demand
  FROM
    forecasted_demand
  GROUP BY
    datacenter_id
)

SELECT
  td.datacenter_id,
  d.monthly_capacity - td.total_demand AS spare_capacity
FROM 
  total_demand AS td
JOIN 
  datacenters AS d
ON d.datacenter_id=td.datacenter_id  
 ORDER BY 
   datacenter_id;

-- Average Post Hiatus (Part 1)
SELECT user_id,
DATE_PART('DAY',MAX(post_date)- MIN(post_date)) as days_between
FROM posts
 where DATE_PART('YEAR', post_date) = '2021'
group by 1
having count(post_id)>1

-- Teams Power Users
SELECT sender_id, count(message_id) as message_count FROM messages
where DATE_PART('month',sent_date) = 08
and DATE_PART('YEAR',sent_date) = 2022
group by 1
order by 2 desc
limit 2

-- Top Rated Businesses
SELECT 
  COUNT(business_id) AS business_count,
  ROUND(100.0 * COUNT(business_id)/
    (SELECT COUNT (business_id) FROM reviews),0) AS top_rated_pct
FROM reviews
WHERE review_stars IN (4, 5);

-- Ad Campaign ROAS
SELECT advertiser_id, 
round((sum(revenue)/sum(spend))::numeric,2) as ROAS FROM ad_campaigns
group by advertiser_id
order by 1

-- ApplePay Volume
SELECT merchant_id,
sum(case when lower(payment_method) = 'apple pay' 
    then transaction_amount else 0 end) AS total_transaction
FROM transactions
group by 1
order by 2 desc

-- App Click-through Rate (CTR)
SELECT app_id,
ROUND(100.0*(sum(CASE when event_type = 'click' then 1.0 else 0 end)/
sum(CASE when event_type = 'impression' then 1.0 else 0 end)),2) as ctr
FROM events
where EXTRACT(year from timestamp) = 2022
group by app_id

-- Second Day Confirmation
SELECT user_id
FROM emails e 
join texts t
on t.email_id = e.email_id
and e.signup_date + INTERVAL '1 day' = t.action_date ;

-- Compressed Mean
SELECT 
round(sum(item_count*order_occurrences)*1.0/
SUM(order_occurrences),1) as mean
FROM items_per_order;

