                         -- pizza bussiness project
-- SET 1:BASIC

-- 1) Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS Total_order;

-- 2) Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(order_details.quantity * pizzas.price) AS Total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- 3) Identify the highest-priced pizza.
use pizzahut;
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1
;

-- 4) Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(order_details.order_details_id) AS cnt
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY cnt DESC;

-- 5) List the top 5 most ordered pizza types(name)
-- along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quant
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quant DESC
LIMIT 5
;

-- SET-2 INTERMEDIATE

-- 6) Join the necessary tables to find the total quantity 
-- of each pizza category ordered.

SELECT 
    SUM(order_details.quantity) AS total_quantity,
    pizza_types.category
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- 7) Determine the distribution of orders by hour of the day.

select hour(order_time),count(order_id) from orders 
group by hour(order_time);

-- 8) Join relevant tables to find the category-wise distribution of pizzas.
use pizzahut;
SELECT 
    category, COUNT(name) AS Total_distribution
FROM
    pizza_types
GROUP BY category;

-- 9) Group the orders by date and 
-- calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity)) AS avg_no_pizza_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- 10) Determine the top 3 most ordered pizza types(name) based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name order by Revenue DESC limit 3;

-- SET-3 ADVANCED

-- 11) Analyze the cumulative revenue generated over date.

select order_date,sum(Revenue) over(order by order_date)as cummulative_revenue 
from
(select orders.order_date,sum(order_details.quantity*pizzas.price) as Revenue
from orders join order_details on
orders.order_id=order_details.order_id
join pizzas
on pizzas.pizza_id=order_details.pizza_id group by orders.order_date order by Revenue )as sales_per_day;

-- 12) Calculate the percentage 
-- contribution of each pizza type(category) to total revenue.

-- (select sum(order_details.quantity * pizzas.price) as total_sales
-- from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
-- join order_details on 
-- pizzas.pizza_id=order_details.pizza_id);

-- percentage=each sale/total sales*100


SELECT 
    pizza_types.category,
    (SUM(order_details.quantity * pizzas.price) / (SELECT 
            SUM(order_details.quantity * pizzas.price) AS total_sales
        FROM
            pizza_types
                JOIN
            pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
                JOIN
            order_details ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;


-- 13) Determine the top 3 most ordered pizza types name with for each category  
-- based on revenue for each pizza category.
select name,category,Total_sales from
(select name,category,Total_sales,rank() over(partition by category order by Total_sales desc)as rn
from
(select pizza_types.name,pizza_types.category,SUM(order_details.quantity * pizzas.price) AS Total_sales
from pizza_types
join pizzas
on 
pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name,pizza_types.category) AS a)as b
where rn<=3;
