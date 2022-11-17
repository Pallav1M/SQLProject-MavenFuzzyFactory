
-- Analyzing top traffic sources
-- =================================
SELECT 
    website_sessions.utm_content,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) as session_to_order_conv_rate
FROM
    website_sessions
    left join orders on orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY utm_content
ORDER BY sessions DESC;

-- Finding top traffic sources
-- ===========================
-- (Assignment 1)
-- Our CEO, Cindy wants to see the top traffic sources
Select 
utm_source, 
utm_campaign, 
http_referer,
COUNT(DISTINCT website_session_id) AS sessions 
from website_sessions 
where created_at < '2012-04-12'
group by utm_source, utm_campaign, http_referer
order by sessions desc;

-- So, next step is to drill deeper into gsearch nonbrand campaign traffic to explore potential optimization opportunities.
-- We wil ask Tom (gsearch campaign owner) to get his thoughts on next steps. 

-- Traffic Source Conversion Rates
-- ===============================
-- (Assignment 2)
-- Tom said that gsearch is our major traffic source, but we need to understand if those sessions are drving all our sales. He asked me to calculate the conversion rates. We need to have at least 4% to make the numbers work. 
-- If it is much lower, we will need to reduce bids. If it is higher, we can increase bids to drive more volume. 

SELECT 
	website_sessions.utm_source, 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) as session_to_order_conv_rate
FROM
    website_sessions
    left join orders on orders.website_session_id = website_sessions.website_session_id
WHERE
	website_sessions.created_at < '2012-04-14'
	and website_sessions.utm_source = 'gsearch'
	and website_sessions.utm_campaign = 'nonbrand'
ORDER BY sessions DESC;

-- So, after giving this analysis to Tom, he said that we will dial down our search bids. 
-- Next step is to monitor the impact of bid reduction, and analyze performnace trending by device type in order to refine bidding strategy. 

-- Bid Optimization and Trend Analysis 
-- ======================================
-- Trended analysis of sessions by week by year 

Select 
	Year(created_at),
	week(created_at),
	min(date(created_at)) as week_start, 
	count(distinct website_session_id) as sessions
from website_sessions
where website_session_id between 100000 and 115000
group by 1,2;

-- count of products by primary product id
-- =======================================

SELECT 
    primary_product_id,
    COUNT(CASE
        WHEN items_purchased = 1 THEN order_id
        ELSE NULL
    END) AS order_with_1_item,
    COUNT(CASE
        WHEN items_purchased = 2 THEN order_id
        ELSE NULL
    END) AS orders_with_2_items,
    COUNT(order_id) AS total_orders
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
GROUP BY 1; 

SELECT 
    primary_product_id,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 1 THEN order_id
            ELSE NULL
        END) AS order_with_1_item,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 2 THEN order_id
            ELSE NULL
        END) AS orders_with_2_items
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
GROUP BY 1;

-- Traffic Source Trending
-- ==========================
-- Assignment 3

-- Tom suggested that we bid down gsearch nonbrand on 2012-04-15. He asked me if I can pull gsearch nonbrand
--  trended sessions volume, by week to see if the bid changes have caused volume to drop at all? 

SELECT 
    MIN(DATE(created_at)) AS week_started_as,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-05-10'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);

-- Assignment 4
-- So, Tom tried to use the site on his mobie device and the experince wasnt that great. He asked me if I could pull the conversion rates from session or order
-- by device type? If desktop performance is better, we will bid up for desktop. 

SELECT 
    website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-05-11'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_sessions.device_type;

-- So, Tom's experience was right. We will be bidding more on desktop campaign. 

-- Assignment 5
-- Tom asked me to pull weekly trends for both desktop and mobile so we can see impact on volume

SELECT 
    MIN(DATE(created_at)) AS week_started_as,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS session_with_desktop,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS session_with_mobile
FROM
    website_sessions
WHERE
created_at between '2012-04-15' and '2012-06-09'  
 -- created_at < '2012-06-09'
--  and created_at > '2012-04-15'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'  
GROUP BY week(created_at);

-- Analyzing Website Performance
-- ================================
create temporary table first_pageviews
select website_session_id,
min(website_pageview_id) as min_pv_id
from website_pageviews 
where website_pageview_id < 1000
group by website_session_id;

select * from first_pageviews;

select website_pageviews.pageview_url as landing_page,
count(distinct first_pageviews.website_session_id) as sessions_hitting_the_lander
from first_pageviews
left join  website_pageviews on website_pageviews.website_pageview_id = first_pageviews.min_pv_id
where website_pageview_id < 1000
group by website_pageviews.pageview_url ;

-- Assignment 1
-- I am working with Morgan, the Website Manager. She has asked me to pull the most viewed website pages, ranked by session volume. 

select pageview_url, 
count(distinct website_pageview_id) as sessions
from website_pageviews 
where 
created_at < '2012-06-09'
group by pageview_url
order by sessions desc;

-- After sending her the analysis, she said that she wants to look at the entry pages. She wants to confirm where all the users are landing on the website.

-- First step is to create a temporary table. 
-- Find the first page view for each session 
-- find the url the customer saw on that first pageview

create temporary table first_pageviews_per_session
select website_session_id,
min(website_pageview_id) as min_pv_id
from website_pageviews 
where created_at < '2012-06-12'
group by website_session_id;

select * from first_pageviews_per_session;

select website_pageviews.pageview_url as landing_page,
count(distinct first_pageviews_per_session.website_session_id) as sessions_hitting_the_lander
from first_pageviews_per_session
left join  website_pageviews on website_pageviews.website_pageview_id = first_pageviews_per_session.min_pv_id
group by website_pageviews.pageview_url ;

-- So,upon sending her the analysis, Morgan said that we should be focussed on making improvements on the home page obviously. Next step is to 
-- analyze landing page performance, for the homepage specifcally. And, to think about whether the homepage is the best initial experience for all customers. 

-- Business Context - We want to see the landing page performance for a certain period of time

-- Step 1- Find the first website_pageview_id for relevant sessions
-- Step 2- Identify the landing page of each session
-- Step 3- Counting pageviews for each session, to identify bounces
-- Step 4- Summarizing total sessions and bounced session, by LP.

-- finding the minimum website pageview id associated with each session we care about 

select website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id
from website_pageviews 
inner join website_sessions on website_sessions.website_session_id = website_pageviews.website_session_id
and website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by website_pageviews.website_session_id;

-- create a temporary table to insert the same table

create temporary table first_pageviews_demo
select website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id
from website_pageviews 
inner join website_sessions on website_sessions.website_session_id = website_pageviews.website_session_id
and website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by website_pageviews.website_session_id;

-- Next, we will bring in the landing page to each data session

create temporary table landing_page_demo
select website_pageviews.pageview_url as landing_page,
first_pageviews_demo.website_session_id
from first_pageviews_demo
left join  website_pageviews 
on website_pageviews.website_pageview_id = first_pageviews_demo.min_pv_id;

select * from landing_page_demo;

-- Next, we make a table to include a count of pageviews per session 
-- First, we will see all sessions and then limit it to bounced session and create a temp table

create temporary table bounced_sessions_only
select 
landing_page_demo.website_session_id,
landing_page_demo.landing_page,
count(website_pageviews.website_pageview_id) as count_of_pages_viewed
from landing_page_demo 
left join website_pageviews
on website_pageviews.website_session_id = landing_page_demo.website_session_id
group by 
landing_page_demo.website_session_id,
landing_page_demo.landing_page
having count(website_pageviews.website_pageview_id) =1;

select * from bounced_sessions_only;

select 
landing_page_demo.landing_page,
count(distinct landing_page_demo.website_session_id) as sessions	,
count(distinct bounced_sessions_only.website_session_id) as bounced_session_only,
count(distinct bounced_sessions_only.website_session_id)/count(distinct landing_page_demo.website_session_id) as bounce_rate
from landing_page_demo 
left join bounced_sessions_only on landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
group by landing_page_demo.landing_page;

-- Assignment 2
-- ===============
-- Morgan asked me if I pull in traffic landing on the homepage? She wants to see three numbers - number of Sessions, number of Bounced Session, % of sessions which are bounced until June 14th. 

-- Steps
-- Step 1 - Finding the first website pageview id for relevant sessions
-- Step 2 - Identifying the landing page for each session 
-- Step 3 - Counting pageviews for each session to identify bounces
-- Step 4 - Summarizing by counting total sessions and bounce rates 

Create temporary table first_pageviews
select website_session_id, 
min(website_pageview_id) as min_pageview_id
from website_pageviews
where created_at < '2012-06-14'
group by 
website_session_id;

select * from first_pageviews;

-- Next, we will bring in the landing page, but restrict to home only 

create temporary table sessions_w_home_landing_page
select first_pageviews.website_session_id, 
website_pageviews.pageview_url as landing_page
from first_pageviews
left join website_pageviews
on first_pageviews.min_pageview_id = website_pageviews.website_pageview_id
where website_pageviews.pageview_url = '/home';

select * from sessions_w_home_landing_page;

-- then a table to have count of pageviews per session 
-- the limit it to just bounced session i.e one page only 

create temporary table bounced_sessions
select 
sessions_w_home_landing_page.website_session_id,
sessions_w_home_landing_page.landing_page,
count(website_pageviews.website_pageview_id) as count_of_pages_viwed
from 
sessions_w_home_landing_page 
left join 
website_pageviews on 
sessions_w_home_landing_page.website_session_id = website_pageviews.website_session_id
group by sessions_w_home_landing_page.website_session_id,
sessions_w_home_landing_page.landing_page
having count(website_pageviews.website_pageview_id) = 1;

select * from bounced_sessions;

select 
count(distinct sessions_w_home_landing_page.website_session_id) as sessions,
count(distinct bounced_sessions.website_session_id) as bounced_sessions,
count(distinct bounced_sessions.website_session_id)/count(distinct sessions_w_home_landing_page.website_session_id) as bounce_rate
from 
sessions_w_home_landing_page -- we want to show all sessions from the ones with home landing page
left join bounced_sessions
on sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;

-- Hmm, upon seeing the data, Morgan was concerend, and she said thats he will put together a custom landing page for search, 
-- and set up an experiment to see if the new page does better. 

-- Next step is to analyze the result of an A/B testing against the homepage

-- Analyzing Landing Page Test 
-- ==============================
-- So, Morgan's team ran a new custom landing page in a 50/50 test against the homepage. She asked me to find out the bounce rate for the two groups so she can evaluate the performance of the new page. 

-- First, find the first instance of /lander 1 to set analysis frame
-- Next, final analysis output

-- Steps 
-- Step 0 - Find out when the new page/lander launched
-- Step 1 - Finding out the first website pageview_id for relevant sessions
-- Step 2 - Identifying the landing page of each session 
-- Step 3 - Counting page views for each session to identify boounces
-- Step 4 - Summarizing total sessions and bounced sessions, by LP

Select 
min(created_at) as first_created_at, 
min(website_pageview_id) as first_pageview_id 
from website_pageviews
where pageview_url = '/lander-1'
and created_at is not null;

-- # first_created_at, first_pageview_id
-- '2012-06-19 00:35:54', '23504'

create temporary table first_test_pageviews
select 
website_pageviews.website_session_id, 
min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
inner join website_sessions 
on website_pageviews.website_session_id = website_sessions.website_session_id
and website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
and website_pageviews.website_pageview_id > 23504
and website_sessions.utm_source = 'gsearch' 
and website_sessions.utm_campaign = 'nonbrand'
group by website_pageviews.website_session_id;

select * from first_test_pageviews;

-- Next, we will bring in the landing page to each session, like last time but restricting to home or lander-1 this time. 

create temporary table nonbrand_test_sessions_w_landing_page
select 
first_test_pageviews.website_session_id,
website_pageviews.pageview_url as landing_page
from first_test_pageviews 
left join website_pageviews 
on website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
where website_pageviews.pageview_url in ('/home', '/lander-1');

select * from nonbrand_test_sessions_w_landing_page;

-- then a table to have count of pageviews per session 
-- then limit to just bounced sessions 

create temporary table nonbrand_test_bounced_sessions
select 
nonbrand_test_sessions_w_landing_page.website_session_id,
nonbrand_test_sessions_w_landing_page.landing_page,
count(website_pageviews.website_pageview_id) as count_of_pages_viewed
from nonbrand_test_sessions_w_landing_page 
left join website_pageviews
on website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
group by 
nonbrand_test_sessions_w_landing_page.website_session_id,
nonbrand_test_sessions_w_landing_page.landing_page
having count(website_pageviews.website_pageview_id) =1; 

select * from nonbrand_test_bounced_sessions;

select 
nonbrand_test_sessions_w_landing_page.website_session_id ,
nonbrand_test_sessions_w_landing_page.landing_page, 
nonbrand_test_bounced_sessions.website_session_id 
from 
 nonbrand_test_sessions_w_landing_page
 -- we want to show all sessions from the ones with home landing page
left join nonbrand_test_bounced_sessions
on nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
order by nonbrand_test_sessions_w_landing_page.website_session_id;

select 
count(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as sessions,
nonbrand_test_sessions_w_landing_page.landing_page, 
count(distinct nonbrand_test_bounced_sessions.website_session_id) as bounced_sessions,
count(distinct nonbrand_test_bounced_sessions.website_session_id)/count(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as bounce_rate
from 
nonbrand_test_sessions_w_landing_page
 -- we want to show all sessions from the ones with home landing page
left join nonbrand_test_bounced_sessions
on nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
group by nonbrand_test_sessions_w_landing_page.landing_page;

-- So, we see that after the new landing page, we have a sloghly lower bounce rate. 

-- So, Morgan said that she will work with Tom to make sure that all the nonbrand paid traffic is going to the new page
-- Next Steps - 
-- Help Morgan confirm that traffic is all running to the new custom lander after the campaign update
-- Keep an eye on bounce rates and help the team look for other areas to test and optimize. 

-- Landing Page Trend Analysis 
-- ==============================
-- Morgan wanted me to pull the volume of paid search nonbrand traffic landing on /home and /lander-1, trended weekly starting June 1st. 
-- She also asked me to pull our overall paid search bounce rate trended weekly. She wants to make sure that the new landing page made a difference. 

-- Solution is a multi step query 

-- Step 1 - Finding the first website pageview id for relevant sessions 
-- Step 2 - Identifying the landing page of each session 
-- Step 3 - Counting pageviews for each session, to identify bounces
-- Step 4 - Summarizing by weeb (bounce rate, sessions to each lander) 

create temporary table sessions_w_min_pv_and_view_count
select 
website_sessions.website_session_id, 
min(website_pageviews.website_pageview_id) as first_pageview_id,
count(website_pageviews.website_pageview_id) as count_pageviews
from 
website_sessions 
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where 
website_sessions.created_at > '2012-06-01' -- asked by requester 
and website_sessions.created_at < '2012-08-31' 
and website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
group by 
website_sessions.website_session_id;

select * from sessions_w_min_pv_and_view_count;

-- The query below gives result that displays that there is split in between, but towards the end (around July 29th), it is all lander page. 

create temporary table sessions_w_counter_lander_and_created_at
select 
sessions_w_min_pv_and_view_count.website_session_id,
sessions_w_min_pv_and_view_count.first_pageview_id,
sessions_w_min_pv_and_view_count.count_pageviews,
website_pageviews.created_at,
website_pageviews.pageview_url
from 
sessions_w_min_pv_and_view_count
left join website_pageviews
on sessions_w_min_pv_and_view_count.first_pageview_id = website_pageviews.website_pageview_id;

select yearweek(created_at) as year_weak,
min(date(created_at)) as week_start_date,
count(distinct website_session_id) as total_sessions,
count(distinct case when count_pageviews = 1 then website_session_id else null end) bounced_sessions, 
count(distinct case when count_pageviews = 1 then website_session_id else null end) * 1.0/count(distinct website_session_id) as bounce_rate,
count(distinct case when pageview_url = '/home' then website_session_id else null end) as home_sessions, 
count(distinct case when pageview_url = '/lander-1' then website_session_id else null end) as lander_sessions
from sessions_w_counter_lander_and_created_at
group by yearweek(created_at);

-- Morgan was happy with the analysis and we observed that once all the traffic were directed to the new home page, there was signifcant improvement in the bounce rate(i.e it decreased)

-- Analyzing and testing conversion funnels
-- ===========================================
-- Morgan (website manager) wants to understand where we loose customers along the way between lander-1 page and placing an order. She asked me to build a full conversion funnel, analyze how many customers make it to each step. 
-- I should start with lander-1 page and build the funnel all the way to the thank you page, and use the date since August 5th. 

-- Step 1: Select all pageviews for relevant sessions 
-- Step 2: Identify each pageview as the specific funnel step 
-- Step 3: Create the session level conversion funnel view
-- Step 4: Aggregate the data to assess funnel performance


use mavenfuzzyfactory;

select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pageview_created_at,
case when pageview_url = '/products' then 1 else 0 end as products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end as cart_page,
case when pageview_url = '/shipping' then 1 else 0 end as cart_page,
case when pageview_url = '/billing' then 1 else 0 end as billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
and website_pageviews.created_at > '2012-08-05'
and website_pageviews.created_at < '2012-09-05'
order by website_sessions.website_session_id,
website_pageviews.created_at;

select website_session_id,
max(products_page) as product_made_it, 
max(mrfuzzy_page) as mrfuzzy_made_it, 
max(cart_page) as cart_made_it, 
max(shipping_page) as shipping_made_it, 
max(billing_page) as billing_made_it, 
max(thankyou_page) as thankyou_made_it
from 
(
select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pageview_created_at,
case when pageview_url = '/products' then 1 else 0 end as products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end as cart_page,
case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
case when pageview_url = '/billing' then 1 else 0 end as billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
and website_pageviews.created_at > '2012-08-05'
and website_pageviews.created_at < '2012-09-05'
order by website_sessions.website_session_id,
website_pageviews.created_at
) 
as pageview_level
group by 
website_session_id;

-- Next, we will turn it into a temporary table

drop table session_level_made_it_flags;
create temporary table session_level_made_it_flags
select website_session_id,
max(products_page) as product_made_it, 
max(mrfuzzy_page) as mrfuzzy_made_it, 
max(cart_page) as cart_made_it, 
max(shipping_page) as shipping_made_it, 
max(billing_page) as billing_made_it, 
max(thankyou_page) as thankyou_made_it
from 
(
select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at as pageview_created_at,
case when pageview_url = '/products' then 1 else 0 end as products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end as cart_page,
case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
case when pageview_url = '/billing' then 1 else 0 end as billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
and website_pageviews.created_at > '2012-08-05'
and website_pageviews.created_at < '2012-09-05'
order by website_sessions.website_session_id,
website_pageviews.created_at
) 
as pageview_level
group by 
website_session_id;

select * from session_level_made_it_flags;

-- Then, this would produce the final output

select 
count(distinct website_session_id) as sessions, 
count(distinct case when product_made_it = 1 then website_session_id else null end) as to_products,
count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
count(distinct case when cart_made_it = 1 then website_session_id else null end) as to_cart,
count(distinct case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
count(distinct case when billing_made_it = 1 then website_session_id else null end) as to_billing,
count(distinct case when thankyou_made_it = 1 then website_session_id else null end) as to_thankyou
from 
session_level_made_it_flags;

-- then, we look into click rates

select 
count(distinct case when product_made_it = 1 then website_session_id else null end)/count(distinct website_session_id) as lander_click_rt,
count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)/ count(distinct case when product_made_it = 1 then website_session_id else null end)as products_click_rt,
count(distinct case when cart_made_it = 1 then website_session_id else null end)/ count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as mrfuzzy_click_rt,
count(distinct case when shipping_made_it = 1 then website_session_id else null end)/count(distinct case when cart_made_it = 1 then website_session_id else null end) as cart_click_rt,
count(distinct case when billing_made_it = 1 then website_session_id else null end)/count(distinct case when shipping_made_it = 1 then website_session_id else null end) as shipping_click_rt,
count(distinct case when thankyou_made_it = 1 then website_session_id else null end)/count(distinct case when billing_made_it = 1 then website_session_id else null end) as billing_click_rt
from session_level_made_it_flags;

-- So, after showing this to Morgan, she suggested that we should focus on the lander, Mr. Fuzzy page, and the billing page, which have the lowest click rates. 
-- She is planning to work on the billing page so that the customers will feel more comfortable enetring their credit cards. 

-- So, she got back with the updated billing page. She wants to see if /billing2 is doing any better than the original page. 
-- She wants to know what % of sessions on those pages end up placing an order. 

-- Find the first time /billing2 was seen
-- then, final test analysis output

-- First, find the start point to frame the analysis 

select min(website_pageviews.website_pageview_id) as first_pv_id 
from website_pageviews
where pageview_url = '/billing-2';
-- '53550'

-- First, we will look at this without orders, then we will add in orders

select 
website_pageviews.website_session_id, 
website_pageviews.pageview_url as billing_version_seen
,orders.order_id 
from website_pageviews
left join orders 
on orders.website_session_id = website_pageviews.website_session_id
where website_pageviews.website_pageview_id > 53550 -- first session where the new billing page was live
and website_pageviews.created_at < '2012-11-10' -- time of assignment
and website_pageviews.pageview_url in ('/billing','/billing-2');

select 
billing_version_seen,
count(distinct website_session_id) as sessions, 
count(distinct order_id) as orders,
count(distinct order_id)/count(distinct website_session_id) as billing_to_order_rt
from 
(select 
website_pageviews.website_session_id, 
website_pageviews.pageview_url as billing_version_seen
,orders.order_id 
from website_pageviews
left join orders 
on orders.website_session_id = website_pageviews.website_session_id
where website_pageviews.website_pageview_id > 53550 -- first session where the new billing page was live
and website_pageviews.created_at < '2012-11-10' -- time of assignment
and website_pageviews.pageview_url in ('/billing','/billing-2')
) as billing_sessions_w_orders
group by 
billing_version_seen;

-- This was great! Morgan said that she will get the engineering team to roll this out to all the customers right away. 

-- Next steps - 
-- To confirm if this has been rolled out 100% correctly
-- monitor overall sales performance to see the impact this change produces

