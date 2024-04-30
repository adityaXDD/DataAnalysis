create DATABASE sqlportfolio
use sqlportfolio 

select top 1 * from pizzas
select top 1 * from pizza_types
select top 1 * from orders
select top 1 * from order_details

-- Basic:
/* QUES1. Retrieve the total number of orders placed. */

SELECT count(*) number_of_orders from orders

/* QUES2. Calculate the total revenue generated from pizza sales. */

SELECT round(sum(o.quantity*p.price),2) total_revnue from  pizzas as p 
join order_details as o
on p.pizza_id = o.pizza_id

/* QUES3. Identify the highest-priced pizza. */

select top 1 * from pizzas
order by price DESC

/* QUES4. Identify the most common pizza size ordered . */
SELECT  top 1 p.[size], count(quantity) quantity  from order_details as o
join pizzas as p 
on o.pizza_id = p.pizza_id
group by size 
order by quantity DESC

/* QUES5. List the top 5 most ordered pizza types along with their quantities. */
select top 5 p.pizza_type_id ,sum(quantity) quantity_orders FROM order_details as o 
join pizzas as p 
on p.pizza_id = o.pizza_id
GROUP by p.pizza_type_id
ORDER by quantity_orders desc

--Intermediate :
/* QUES1. Join the necessary tables to find the total quantity of each pizza category ordered. */
SELECT  p.pizza_type_id,COUNT(quantity) order_count from order_details o
JOIN pizzas p
on p.pizza_id = o.pizza_id
group by p.pizza_type_id
ORDER by order_count DESC 

/* QUES2. Determine the distribution of orders by hour of the day. */
SELECT DATEPART(HOUR,a.time) as hours ,count(a.order_id) from orders a
join order_details b
on a.order_id = b.order_id
group by DATEPART(HOUR,a.time)
order by [hours] 



/* QUES3. Join relevant tables to find the category-wise distribution of pizzas. */

SELECT  d.category,sum(quantity) quantity from  order_details a
JOIN pizzas p 
on p.pizza_id = a.pizza_id
JOIN pizza_types d 
on p.pizza_type_id = d.pizza_type_id
group by d.category
order by quantity DESC 

/* QUES4. Group the orders by date and calculate the average number of pizzas ordered per day */
SELECT AVG(orders) from (
SELECT a.[date] , sum(quantity) orders from  orders a 
JOIN order_details b 
on a.order_id =b.order_id 
GROUP by a.[date]
) as X 

/* QUES5. Determine the top 3 most ordered pizza types based on revenue.*/
SELECT top 3 b.pizza_type_id , round(sum(b.price*a.quantity),2) as revenue  from  order_details a
join pizzas b 
on a.pizza_id = b.pizza_id
GROUP by b.pizza_type_id
order by revenue DESC

--Advanced:
/* Calculate the percentage contribution of each pizza type to total revenue. */

SELECT b.category,round(sum(a.price*c.quantity),1) tot_revenue ,
round((sum(a.price*c.quantity)/(select sum(x.quantity*y.price) from pizzas y join order_details x on y.pizza_id = x.pizza_id ))*100,2) as perc_revenue
from pizzas as a 
join pizza_types as b 
on a.pizza_type_id = b.pizza_type_id
join order_details as c 
on c.pizza_id = a.pizza_id
GROUP by b.category



/* Analyze the cumulative revenue generated over time.*/
SELECT [date], round(SUM(rev)OVER(order by date),2) cumulative_revenue
from (
SELECT [date], SUM(b.quantity*a.price) rev
from pizzas a
join order_details b
on a.pizza_id =b.pizza_id
JOIN orders c 
on b.order_id = c.order_id
GROUP by [date]
) as data 


/* Determine the top 3 most ordered pizza types based on revenue for each pizza category. */
with cte_2 as (
SELECT * , row_number()OVER(PARTITION BY category order by tot_rev desc) ranks
from (
SELECT c.category ,name , sum(a.price*b.quantity) tot_rev
from pizzas a 
join order_details b 
on a.pizza_id = b.pizza_id 
join pizza_types c 
on a.pizza_type_id = c.pizza_type_id 
group by c.category,name
) as data1
) 
select * from cte_2
where ranks <= 3