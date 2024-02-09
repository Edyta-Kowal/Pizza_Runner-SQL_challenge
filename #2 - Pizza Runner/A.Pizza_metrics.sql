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
from runn_ord_temp;


/* --------------------
   Case Study Questions
   --------------------*/


-- A. PIZZA METRICS


-- 1. How many pizzas were ordered?

select count(pizza_id) as pizza_ordered
from cust_ord_temp;


-- 2. How many unique customer orders were made?

select count (distinct order_id) as order_made
from cust_ord_temp; 


-- 3. How many successful orders were delivered by each runner?

select runner_id
	, count(order_id) as order_delivered
from runn_ord_temp
where pickup_time is not null
group by 1;


-- 4. How many of each type of pizza was delivered?

select pn.pizza_name
	, count(ro.order_id) as pizza_delivered
from pizza_runner.pizza_names as pn
	join cust_ord_temp as co on pn.pizza_id = co.pizza_id
	join runn_ord_temp as ro on co.order_id = ro.order_id
where ro.pickup_time is not null
group by 1;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select co.customer_id
	, pn.pizza_name
	, count(co.pizza_id) as pizza_ordered
from cust_ord_temp as co
	join pizza_runner.pizza_names as pn on co.pizza_id = pn.pizza_id
group by 1, 2
order by 1, 2;


-- 6. What was the maximum number of pizzas delivered in a single order?

select co.order_id
	, count(co.pizza_id) as pizza_max
from cust_ord_temp as co
	join runn_ord_temp as ro on co.order_id = ro.order_id
where ro.pickup_time is not null
group by 1
order by count(pizza_id) desc
limit 1;


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select co.customer_id
    , sum(case 
            when co.exclusions != '' or co.extras != '' then 1
            else 0
		  end) as count_changed
    , sum(case 
            when co.exclusions = '' and co.extras = '' then 1
            else 0
          end) as count_unchanged
from cust_ord_temp as co
	join runn_ord_temp as ro on co.order_id = ro.order_id
where ro.pickup_time is not null
group by 1
order by 1;


-- 8. How many pizzas were delivered that had both exclusions and extras?

select count(co.pizza_id) as pizza_excl_ext
from cust_ord_temp as co
	join runn_ord_temp as ro on co.order_id = ro.order_id
where ro.pickup_time is not null and co.exclusions != '' and co.extras != '';


-- 9. What was the total volume of pizzas ordered for each hour of the day?

select extract(hour from order_time) as order_hour
	, count(pizza_id) as pizza_count
from cust_ord_temp
group by 1
order by 1;


-- 10. What was the volume of orders for each day of the week?

select to_char(order_time, 'day') as order_day
	, count(pizza_id) as pizza_count
from cust_ord_temp
group by 1
order by 1;
