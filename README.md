# SQLProject-MavenFuzzyFactory

<strong>Situation</strong> 
I have been hired as an eCommerce Database Analyst for Maven Fuzzy Factory, an online retailer which has just launched their first product. 

<strong>Objectives</strong>
My role is to help steer the business where I will analyze and optimize marketing channels, measure and test website conversion performance, and use data to understand the impact of new product launches. 


<strong>Traffic Source Analysis</strong>
Traffic source analysis is about understanding where your customers are coming from and which channels are driving the highest quality traffic. 

We will be looking at the traffic sources (email, social media, search, direct) and the conversion rates. 

Common Use Cases 
 Analyzing search data and shifting budget towards the engines, campaign or keywords driving the strongest conversion rates. 
 Comparing user behavior patterns across traffic sources to inform creative and messaging strategy. 
 Identifying opportunities to eliminate wasted spend or scale high converting traffic. 

Key Tables - 
 website_sessions
 website_pageviews
 orders

Note - UTM tracking parameters are used to campaign our paid marketting activities, and stands for urchin tracking module. 

UTM 
 Paid traffic is commonly tagged with UTM parameters, which are appended to URLs and allow us to tie website activity back to specific traffic sources and   campaigns. 
 
SELECT <br/>
     website_sessions.utm_content,<br/>
     COUNT(DISTINCT website_sessions.website_session_id) AS sessions,<br/>
     COUNT(DISTINCT orders.order_id) AS orders,<br/>
     COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) as session_to_order_conv_rate<br/>
 FROM<br/>
     website_sessions<br/>
     left join orders on orders.website_session_id = website_sessions.website_session_id<br/>
 WHERE<br/>
     website_sessions.website_session_id BETWEEN 1000 AND 2000<br/>
 GROUP BY utm_content<br/>
 ORDER BY sessions DESC;<br/>

<strong>Business Concept - Bid Optimization</strong>

Analyzing for bid optimization is about understanding the value of various segment of paid traffic, so that you can optimize your marketing budget. 

Common Use Cases
Using conversion rate and revenue per click analyses to figure out how much you should spend per click to acquire customers. 
Understanding how your website and products performs for various subsegments of traffic  (mobile vs desktop) to otpimize within channels.
Analyzing the impact that bid changes have on your ranking in the auctions, and the volume of customers driven to your site. 



