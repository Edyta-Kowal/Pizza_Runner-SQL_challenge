/* --------------------
     Data preparation 
   --------------------*/
   
select *
from pizza_runner.customer_orders;

create temp table cust_ord_temp as
select order_id
	, customer_id
	, pizza_id 
	, case 
		when exclusions is null or exclusions = 'null' then '' 
		else exclusions 
	  end as exclusions
	, case 
		when extras is null or extras = 'null' then '' 
		else extras 
	  end as extras
	,order_time
from pizza_runner.customer_orders;

select *
from cust_ord_temp;


select *
from pizza_runner.runner_orders;

create temp table runn_ord_temp AS
select order_id
	, runner_id
	, case
     	when pickup_time = 'null' then null
		else pickup_time
	  end as pickup_time
	, case
		when distance = 'null' then null
     	when distance like '%km' then trim('km' from distance)
     	else distance 
	  end as distance_km
	, case
		when duration = 'null' then null
		when duration like '%mins' then trim('mins' from duration)
     	when duration like '%minute' then trim('minute' from duration)
    	when duration like '%minutes' then trim('minutes' from duration)
      else duration
	  end as duration_min
	, case
		when cancellation = 'null' or cancellation is null then ''
     	else cancellation
	  end as cancellation
from pizza_runner.runner_orders;

select *
from runn_ord_temp


/* --------------------
   Case Study Questions
   --------------------*/


-- B. Runner and Customer Experience


-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select date_trunc('week', registration_date) as week_start_date
	, count(runner_id) as runner_count
from pizza_runner.runners
where registration_date >= '2021-01-01' 
group by 1
order by 1; 


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select ro.runner_id
    , avg((ro.pickup_time::timestamp - co.order_time)) as avg_time_diff
from runn_ord_temp as ro
	join cust_ord_temp as co on co.order_id = ro.order_id
where ro.pickup_time is not null
group by 1
order by 1;
			 

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

with abc as (
	select count(co.pizza_id) as pizza_count
		, co.order_id
		, (ro.pickup_time::timestamp - co.order_time) as prep_time
	from runn_ord_temp as ro
		join cust_ord_temp as co on co.order_id = ro.order_id
	where ro.pickup_time is not null
	group by 2,3
	)
select pizza_count
	, avg(prep_time) as avg_prep_time
from abc
group by 1;


-- 4. What was the average distance travelled for each customer?

select co.customer_id
	, round(avg(ro.distance_km::numeric), 2) avg_distance
from runn_ord_temp as ro
	join cust_ord_temp as co on co.order_id = ro.order_id
group by 1
order by 1;


-- 5. What was the difference between the longest and shortest delivery times for all orders?

select max(duration_min::numeric) - min(duration_min::numeric) as deliv_time_diff
from runn_ord_temp;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

select runner_id
	, order_id
	, round(avg(distance_km::numeric / duration_min::numeric), 2) as avg_speed
from runn_ord_temp
where pickup_time is not null
group by 1, 2
order by 1, 2;


-- 7. What is the successful delivery percentage for each runner?

select runner_id
	, round(sum(
		case 
			when pickup_time is not null then 1 else 0 
		end)::numeric / count(order_id), 2) as perc_success
from runn_ord_temp
group by 1
order by 1;
