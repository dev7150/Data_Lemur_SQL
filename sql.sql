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

-- User's Third Transaction
with base as 
(SELECT *, RANK() OVER(PARTITION BY user_id order by transaction_date) as rank
FROM transactions
)

Select user_id, spend, transaction_date
from base
where rank = 3


-- Sending vs. Opening Snaps
with base AS
(SELECT  user_id,
sum(case when activity_type = 'open' then time_spent else 0 end) as time_opening,
SUM(case when activity_type = 'send' then time_spent else 0 end) as time_sending
FROM activities
group by user_id
)

SELECT ab.age_bucket, 
round((time_sending / (time_sending + time_opening))*100.0,2) as send_perc,
round((time_opening / (time_sending + time_opening))*100.0,2) as open_perc
from age_breakdown ab
join base 
on base.user_id = ab.user_id
order by 1

-- Average Review Ratings
SELECT EXTRACT(MONTH FROM submit_date) as month,
product_id,
round(AVG(stars),2)
FROM reviews
GROUP BY 1,2
order by 1,2

-- Cards Issued Difference
SELECT card_name
,MAX(issued_amount) - MIN(issued_amount) as difference
FROM monthly_cards_issued
group by 1
order by 2 desc


-- Pharmacy Analytics (Part 1)
SELECT drug
,SUM(total_sales - cogs) as total_profit
FROM pharmacy_sales
group by 1
order by 2 DESC
limit 3

-- Pharmacy Analytics (Part 2)
SELECT manufacturer,
COUNT(drug)
,abs(SUM(total_sales - cogs)) as total_profit
FROM pharmacy_sales
where (total_sales - cogs) < 0
group by 1
order by 3 DESC

-- Pharmacy Analytics (Part 3)
Select manufacturer
,'$'|| round(sum(total_sales)/10^6::numeric,0) || ' ' || 'million'
FROM pharmacy_sales
group by 1
order by sum(total_sales) desc

-- Patient Support Analysis (Part 1)
with base AS
(SELECT COUNT(case_id) as c
FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id) > 2
)
SELECT count(c) as member_count from base

-- Tweets' Rolling Averages
with base as 
(
  SELECT user_id,
  tweet_date,
  COUNT(tweet_id) as c
  from tweets
  group by 1 ,2
)

SELECT user_id
, tweet_date
, round(AVG(c) over (PARTITION BY user_id order by tweet_date
              rows BETWEEN 2 preceding and current row),2)
FROM base


-- Highest-Grossing Items
with base as 
(SELECT category
, product
, sum(spend) as s
, RANK() over (PARTITION BY category order by SUM(spend) desc) as r
FROM product_spend
where EXTRACT(year from transaction_date) = 2022
GROUP BY 1,2
)
SELECT category
, product
, s as total_spend
from base
where r < 3

-- Top 5 Artists
with base as 
(SELECT a.artist_name
, dense_rank() over (order by COUNT(g.song_id) desc) as artist_rank 
FROM artists a
join songs s
on a.artist_id = s.artist_id
join global_song_rank g
on s.song_id = g.song_id
where g.rank < 11
group by 1
)

Select * from base 
where artist_rank < 6

-- Signup Activation Rate
with rate AS
(
SELECT emails.user_id, texts.signup_action
,   CASE WHEN texts.email_id IS NOT NULL THEN 1
    ELSE 0 END AS activation_count
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND texts.signup_action = 'Confirmed'
)
SELECT 
  ROUND(
    SUM(activation_count)::DECIMAL 
      / COUNT(user_id), 2) AS activation_rate
FROM rate;

-- Fill Missing Client Data
with base AS
(SELECT product_id
,  category
, name
, count(category) over (order by product_id) as cnt
FROM products
)
SELECT product_id
, FIRST_VALUE(category) over (PARTITION BY cnt order by product_id) as category
, name
from base

-- Spotify Streaming History
WITH history AS (
SELECT user_id, song_id, song_plays
FROM songs_history
UNION ALL
SELECT user_id, song_id, COUNT(song_id) AS song_plays
FROM songs_weekly
WHERE listen_time <= '08/04/2022 23:59:59'
GROUP BY user_id, song_id
)

SELECT user_id, song_id, SUM(song_plays) AS song_count
FROM history
GROUP BY user_id, song_id
ORDER BY song_count DESC;


-- Mean, Median, Mode
with base AS
(
Select email_count as mode, count(email_count) 
from inbox_stats
group by 1 
ORDER BY 2 DESC
limit 1
)
SELECT round(SUM(i.email_count)/count(i.user_id),0) as mean
, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY i.email_count) as median
, mode
FROM inbox_stats i, base b
group by 3;

SELECT 
  ROUND(AVG(email_count)) as mean,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY email_count) AS median,
  MODE() WITHIN GROUP (ORDER BY email_count) AS mode
 FROM inbox_stats;

-- Pharmacy Analytics (Part 4)
 with base as 
(SELECT manufacturer,drug,
row_number() OVER(partition by manufacturer order by units_sold desc) as r FROM pharmacy_sales)

SELECT manufacturer
, drug as top_drugs
from base where r < 3
order by 1