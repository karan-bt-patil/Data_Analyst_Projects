-- Pizza Sales project Questions
/* Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantities.


Intermediate:
Join the necessary tables to find the total quantity of each pizza category ordered.
Determine the distribution of orders by hour of the day.
Join relevant tables to find the category-wise distribution of pizzas.
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue.

Advanced:
Calculate the percentage contribution of each pizza type to total revenue.
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/


use pizza;

-- Retrieve the total number of orders placed.

select count(order_id) as Total_Orders from orders; 



-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(quantity * price), 2) AS Total_Sales
FROM
    orders_details
        INNER JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;
    
    
    
-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;




-- Identify the most common pizza size ordered.
 
SELECT 
    pizzas.size, COUNT(orders_details.order_details_id)
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(orders_details.order_details_id) DESC;




-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas
        JOIN
    orders_details ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        AND pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(orders_details.quantity) DESC
LIMIT 5;




-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas
        JOIN
    orders_details ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        AND pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category;




-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);




-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS No_of_pizzas
FROM
    pizza_types
GROUP BY category;




-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as Avg_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS daily_orders;	
    
    
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas
        JOIN
    orders_details ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        AND pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(orders_details.quantity * pizzas.price) DESC
LIMIT 3;




-- Calculate the percentage contribution of each category to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    SUM(orders_details.quantity * pizzas.price)
                FROM
                    orders_details
                        JOIN
                    pizzas
                        JOIN
                    pizza_types ON orders_details.pizza_id = pizzas.pizza_id
                        AND pizzas.pizza_type_id = pizza_types.pizza_type_id) * 100,
            2) AS Revenue_Contribution_percentage
FROM
    orders_details
        JOIN
    pizzas
        JOIN
    pizza_types ON orders_details.pizza_id = pizzas.pizza_id
        AND pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY Revenue_Contribution_percentage DESC;



-- Analyze the cumulative revenue generated over time.

select 
	order_date, round(sum(revenue) over (order by order_date),2) as Cumulative_revenue
from(
	select 
		orders.order_date, sum(orders_details.quantity*pizzas.price) as revenue
	from 
	orders 
		join 
    orders_details 
		join 
    pizzas on orders.order_id=orders_details.order_id and orders_details.pizza_id=pizzas.pizza_id 
group by orders.order_date 
order by orders.order_date) 
as sales;
 
 
 
 
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select 
	category, name, round(revenue,2) 
from (
	select category, name, revenue , rank() over (partition by category order by revenue desc) as rnk 
	from (
		select 
			pizza_types.category, pizza_types.name, sum(orders_details.quantity*pizzas.price) as revenue
			from 
				pizza_types 
					join 
				pizzas 
					join 
				orders_details on pizza_types.pizza_type_id=pizzas.pizza_type_id and pizzas.pizza_id=orders_details.pizza_id
			group by pizza_types.category, pizza_types.name) as a)as b
where rnk < 4;
