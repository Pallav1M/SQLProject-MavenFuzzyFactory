-- The company has been live for the last 8 months and CEO wants me to present a company performance metrics.  
-- ===========================================================================================================
-- Questions -  Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth here?

use mavenfuzzyfactory;

Select 
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as mn,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/ count(distinct website_sessions.website_session_id) as conv_rate
from website_sessions
left join orders 
on  website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27' 
and website_sessions.utm_source = 'gsearch'
group by 1,2;

-- Question -  Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. If so, that is a good story to tell. 

Select 
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as mn,
count(distinct case when utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as nonbrand_sessions,
count(distinct case when utm_campaign = 'nonbrand' then orders.order_id else null end) as nonbrand_orders,
count(distinct case when utm_campaign = 'brand' then website_sessions.website_session_id else null end) as brand_sessions,
count(distinct case when utm_campaign = 'brand' then orders.order_id else null end) as brand_orders
-- count(distinct orders.order_id) as orders,
-- count(distinct orders.order_id)/ count(distinct website_sessions.website_session_id) as conv_rate
from website_sessions
left join orders 
on  website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27' 
and website_sessions.utm_source = 'gsearch'
group by 1,2;

-- Question - While we are on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? I want to flex our analytical muscle a little bit and show the board we really know our traffic sources. 

Select 
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as mn,
count(distinct case when website_sessions.device_type = 'desktop' then website_sessions.website_session_id else null end) as desktop_sessions,
count(distinct case when website_sessions.device_type = 'desktop' then orders.order_id else null end) as desktop_orders,
count(distinct case when website_sessions.device_type = 'mobile' then website_sessions.website_session_id else null end) as mobile_sessions,
count(distinct case when website_sessions.device_type = 'mobile' then orders.order_id else null end) as mobile_orders
-- count(distinct orders.order_id) as orders,
-- count(distinct orders.order_id)/ count(distinct website_sessions.website_session_id) as conv_rate
from website_sessions
left join orders 
on  website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27' 
and website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
group by 1,2;

-- Question - I am worried that one of our more pessimistic board members may be concerned about the large percentage of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?

-- First, finding the various utm sources and referers to see the traffic we are getting 

select distinct 
utm_source,
utm_campaign, 
http_referer
from website_sessions 
where 
created_at <  '2012-11-27' ;

-- When all three are null, it is a direct type in traffic. 
-- When the paid parameters are null, but referer has a value, then it is an organic traffic. 

Select 
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as mn,
count(distinct case when website_sessions.utm_source = 'gsearch' then website_sessions.website_session_id else null end) as gsearch_paid_session,
count(distinct case when website_sessions.utm_source = 'bsearch' then website_sessions.website_session_id else null end) as bsearch_paid_session,
count(distinct case when website_sessions.utm_source is null and website_sessions.http_referer is not null then website_sessions.website_session_id else null end) as organic_sessions,
count(distinct case when website_sessions.utm_source is null and website_sessions.http_referer is null then website_sessions.website_session_id else null end) as direct_type_in_sessions
-- count(distinct orders.order_id) as orders,
-- count(distinct orders.order_id)/ count(distinct website_sessions.website_session_id) as conv_rate
from website_sessions
left join orders 
on  website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27' 
group by 1,2;

-- Question - I would like to tell the story of our website performance improvements over the course of the first 8 months. Can you pull session to order conversion rates, by month? 

Select 
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as mn,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/ count(distinct website_sessions.website_session_id) as conv_rate
from website_sessions
left join orders 
on  website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-11-27' 
group by 1,2;

-- Question - For the gsearch lander test, please estimate the revenue that test earned us. (Hint - Look at the increase in CVR from the test (Jun 19 - Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value). 

-- For this, we will start with finding the first pageview id

select min(website_pageview_id) as first_test_pv
from website_pageviews
where pageview_url = '/lander-1';

-- We see that '23504' is the first test pageview id 

-- Next, create a temporary table - first_test_pageviews

create temporary table first_test_pageviews
select
	website_pageviews.website_session_id, 
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
from website_pageviews 
	INNER JOIN website_sessions 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
		AND website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
		AND website_pageviews.website_pageview_id >= 23504 -- first page_view
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id;

select * from first_test_pageviews;

-- next, we'll bring in the landing page to each session, like last time, but restricting to home or lander-1 this time
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT 
	first_test_pageviews.website_session_id, 
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1'); 

SELECT * FROM nonbrand_test_sessions_w_landing_pages;

-- then we make a table to bring in orders

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
	nonbrand_test_sessions_w_landing_pages.website_session_id, 
    nonbrand_test_sessions_w_landing_pages.landing_page, 
    orders.order_id AS order_id
FROM nonbrand_test_sessions_w_landing_pages
LEFT JOIN orders 
	ON orders.website_session_id = nonbrand_test_sessions_w_landing_pages.website_session_id;

SELECT * FROM nonbrand_test_sessions_w_orders;

-- to find the difference between conversion rates 
SELECT
	landing_page, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conv_rate
FROM nonbrand_test_sessions_w_orders
GROUP BY 1; 

-- .0318 for /home, vs .0406 for /lander-1 
-- .0087 additional orders per session

-- finding the most reent pageview for gsearch nonbrand where the traffic was sent to /home

SELECT 
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview 
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND website_sessions.created_at < '2012-11-27';

-- max website_session_id = 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145 -- last /home session
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand';
    
-- 22,972 website sessions since the test

-- X .0087 incremental conversion = 202 incremental orders since 7/29
	-- roughly 4 months, so roughly 50 extra orders per month. Not bad!

-- Question - For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each of the two pages to order. You can use the same period you analyzed last time (Jun 19 - Jul 28)

SELECT
	website_sessions.website_session_id, 
    website_pageviews.pageview_url, 
    -- website_pageviews.created_at AS pageview_created_at, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 
    AND website_sessions.created_at < '2012-07-28'
		AND website_sessions.created_at > '2012-06-19'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at;

CREATE TEMPORARY TABLE session_level_made_it_flagged
SELECT
	website_session_id, 
    MAX(homepage) AS saw_homepage, 
    MAX(custom_lander) AS saw_custom_lander,
    MAX(products_page) AS product_made_it, 
    MAX(mrfuzzy_page) AS mrfuzzy_made_it, 
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	website_sessions.website_session_id, 
    website_pageviews.pageview_url, 
    -- website_pageviews.created_at AS pageview_created_at, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 
    AND website_sessions.created_at < '2012-07-28'
		AND website_sessions.created_at > '2012-06-19'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY 
	website_session_id;

select * from session_level_made_it_flagged;

-- then this would produce the final output, part 1
SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment, 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flagged 
GROUP BY 1;

-- then this as final output part 2 - click rates

SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment, 
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_level_made_it_flagged
GROUP BY 1;

-- I would love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test (Sep 10 - Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month to understand monthly impact. 

SELECT
	billing_version_seen, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
 FROM( 
SELECT 
	website_pageviews.website_session_id, 
    website_pageviews.pageview_url AS billing_version_seen, 
    orders.order_id, 
    orders.price_usd
FROM website_pageviews 
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment
	AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS billing_pageviews_and_order_data
GROUP BY 1;

-- $22.83 revenue per billing page seen for the old version
-- $31.34 for the new version
-- LIFT: $8.51 per billing page view

SELECT 
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews 
WHERE website_pageviews.pageview_url IN ('/billing','/billing-2') 
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past month

-- 1,193 billing sessions past month
-- LIFT: $8.51 per billing session
-- VALUE OF BILLING TEST: $10,160 over the past month
