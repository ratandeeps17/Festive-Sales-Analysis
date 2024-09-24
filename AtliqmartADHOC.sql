select * from fact_events;

select city, sum(base_price) from fact_events f
inner join dim_stores s
on s.store_id=f.store_id
GROUP BY city;

select campaign_name, sum(quantity_sold_before_promo) as Total_Quanities_Sold_before_promo, 
sum(quantity_sold_after_promo) as Total_Quanities_Sold_after_promo from fact_events f
inner join dim_campaigns C
on C.campaign_id = f.campaign_id
GROUP BY campaign_name;

select category, sum(quantity_sold_after_promo) as Total_Quanities_Sold_after_promo from fact_events f
inner join dim_products p
on p.product_code=f.product_code
group by category;

select * from dim_campaigns;
select * from dim_products;
select * from dim_stores;
select * from fact_events;


-- 1. List Products with base price greater than 500 and featured in 'BOGOF' promo type --
select distinct(product_name), base_price, promo_type from fact_events f
inner join dim_products p
on p.product_code = f.product_code
where base_price > 500 and promo_type = 'BOGOF';

-- 2. List Number of Stores in each City --
select city, count(store_id) as store_counts from dim_stores
group by city
order by store_counts DESC; 
      
select * from fact_events;

-- 3. List Campaigns with their Total Revenue generated before and after campaigns -- 
SELECT c.campaign_name as Campaign, concat(round(sum(f.total_revenue_before_promo)/1000000,0), 'M') as Total_Revenue_before_Promo, 
concat(round(sum(f.total_revenue_after_promo)/1000000,0), 'M') as Total_Revenue_after_Promo FROM Fact_events f
INNER JOIN dim_campaigns C
on c.campaign_id=f.campaign_id
group by campaign_name;

-- 4. List product categories with their rank based on their Incremental Sold Units(ISU%) during Diwali Campaign --
with cte as(select p.category,
	sum(quantity_sold_after_promo),
	sum(quantity_sold_before_promo) as bqty,
	sum(quantity_sold_after_promo)-sum(quantity_sold_before_promo)::numeric as isu 
	from fact_events f join dim_products p on f.product_code=p.product_code
	group by 1)

select category,
	rank() over(order by round(isu/bqty*100,2)::numeric desc),
	concat(round(isu/bqty*100,2)::numeric,'%') as isu_pct from cte



-- 5. List Top 5 products with their rank based on their Incremental Revenue Percentage across all campaigns --
with cte1 as(select p.product_name,
	sum(total_revenue_after_promo),
	sum(total_revenue_before_promo) as bqty,
	sum(total_revenue_after_promo)-sum(total_revenue_before_promo)::numeric as isu 
	from fact_events f join dim_products p on f.product_code=p.product_code
	group by 1)

select product_name,
	rank() over(order by round(isu/bqty*100,2)::numeric desc),
	concat(round(isu/bqty*100,2)::numeric,'%') as iru_pct from cte1 limit 5;



select * from dim_campaigns;
select * from dim_products;
select * from dim_stores;
select * from fact_events;


-- Research Questions -- 

-- 1. List Number of products available in each category
SELECT category, count(DISTINCT(product_name)) as Total_unique_products
from dim_products
group by Category;

-- 2. List Campaigns by Average revenue and Average quantity sold per Order
SELECT c.campaign_name, concat(round(AVG(total_revenue_after_promo) / 1000,0), 'K') AS Average_revenue_per_Order, 
round(AVG(total_quantities_sold_after_promo),0) AS Average_quantity_sold_per_order
FROM fact_events f
Inner Join dim_campaigns c
ON c.campaign_id=f.campaign_id
Group by c.campaign_name
ORDER BY Average_revenue_per_Order DESC;

-- 3. List Top 5 products by Average revenue and Average quantity sold per Order
SELECT p.product_name, round(avg(total_revenue_after_promo),0) AS Average_revenue_per_Order, 
round(AVG(total_quantities_sold_after_promo),0) AS Average_quantity_sold_per_order
FROM fact_events f
Inner Join dim_products p
ON p.product_code=f.product_code
Group by p.product_name
ORDER BY Average_revenue_per_Order DESC
LIMIT 5;

