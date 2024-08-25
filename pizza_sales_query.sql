use pizza_hut;
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(quantity * price), 2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    name, price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    size, SUM(quantity) AS ordered_quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY ordered_quantity DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    name, SUM(quantity) AS ordered_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY ordered_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    category, SUM(quantity) AS ordered_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS pizza_count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total_quantity), 0) AS avg_pizza_order_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) AS total_quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date
    ) AS sum_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, SUM(quantity * price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY revenue desc
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT category, SUM(quantity * price) * 100 / (SELECT SUM(quantity * price)
                                                FROM 
                                                pizzas
					            JOIN    
						order_details ON pizzas.pizza_id = order_details.pizza_id
	                                        ) AS percentage_contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category;

-- Analyze the cumulative revenue generated over time.
SELECT order_date, SUM(revenue) OVER (ORDER BY order_date) AS revenue
FROM (SELECT order_date, SUM(quantity * price) AS revenue
      FROM 
      orders
          JOIN
      order_details ON orders.order_id = order_details.order_id
          JOIN
      pizzas ON order_details.pizza_id = pizzas.pizza_id
      GROUP BY order_date
      ) AS sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue
FROM (SELECT category, name, revenue, RANK() OVER(PARTITION BY category ORDER BY revenue desc) AS ranks
      FROM (SELECT category, name, SUM(quantity * price) AS revenue
            FROM
            pizza_types
		JOIN
	    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN    
	    order_details ON pizzas.pizza_id = order_details.pizza_id
            GROUP BY category , name
            ) AS T1
     ) AS T2
WHERE ranks<=3;
