-------------------------------------------- Swiggy Data Analysis ----------------------------------------------------

/*
1. Find customers who have never ordered
2. Average Price/dish
3. Find the top restaurant in terms of the number of orders for a given month
4. restaurants with monthly sales greater than x for 
5. Show all orders with order details for a particular customer in a particular date range
6. Find restaurants with max repeated customers 
7. Month over month revenue growth of swiggy
8. Customer - favorite food
*/


/* Q1. Find Customers name who have never ordered ? 
soln */

select name from users
where user_id NOT IN (select user_id from orders)


/* Q2. Average Price/dish
soln */

select f_name, round(AVG(price),2) AS "Avg Price" 
from food f
join menu m
on m.f_id ::bigint = f.f_id
group by f.f_id
order by "Avg Price" desc

/* Q3. Find the top restaurant in terms of the number of orders for a given month(july)? 
soln : */

SELECT o.r_id, r.r_name, COUNT(*) as total_orders
FROM orders o
JOIN restaurants r ON o.r_id = r.r_id
WHERE EXTRACT(MONTH FROM o.date) = 7
GROUP BY o.r_id, r.r_name
order by total_orders desc limit 1;

/* Q4 restaurants with monthly sales greater than x for 
soln */
select * from orders

select r.r_name, sum(amount) AS revenue
from orders o 
join restaurants r
on o.r_id = r.r_id
WHERE EXTRACT(MONTH FROM o.date) = 7
GROUP BY o.r_id, r.r_name
Having sum(amount) > 1000
order by revenue desc;


/* Q5 Show all orders with order details for a particular customer in a particular date range
soln : */

select o.order_id,r.r_name, f.f_name from orders o
join restaurants r
on o.r_id = r.r_id
join order_details od
on o.order_id = od.order_id
join food f
on od.f_id = f.f_id
where user_id = (select user_id from users where name like 'Khushboo' )
AND date  BETWEEN '2022-06-10' AND '2022-07-10'

/* Q6 Find restaurants with max repeated customers */

with my_cte as (
	select r_id, user_id, count(*) as visits
    from orders 
    group by r_id,user_id
    having count(*)>1
    order by visits
	)
select r.r_name, count(*) as loyal_customer
from my_cte
join restaurants as r
on my_cte.r_id = r.r_id
group by r.r_id
order by loyal_customer desc
limit 1;

/* Q7 Month over month revenue growth of swiggy */

select month,round((((revenue-prev)/prev)*100),2) as monthly_rev from 
(
	with sales as
	( 
		SELECT TO_CHAR(date, 'Month') AS month, SUM(amount) AS revenue
        FROM orders
        GROUP BY TO_CHAR(date, 'Month')
        order by TO_CHAR(date, 'Month') desc
    )
select month,revenue,lag(revenue,1) over(order by revenue) as prev from sales

)t

/* Q8 Customer with favorite food */

with temp as 
(
	select o.user_id,od.f_id,count(*) as frequency
    from orders o
    join order_details od
    on o.order_id = od.order_id
    group by o.user_id,od.f_id
)
select u.name,f.f_name,t1.frequency from temp t1 
join users u on u.user_id=t1.user_id
join food f on f.f_id=t1.f_id
where t1.frequency = (select MAX(frequency) from temp t2 where t2.user_id=t1.user_id)
order by u.user_id


------------------------------------------ Bonus Question ----------------------------------------------------------

/* 
Q : Find most loyal customer for all restuarants
Q : Month over month revenue growth of a restuarants */


/* Q : Find most loyal customer for all restuarants */

with my_cte as (
	select r_id, user_id, count(*) as visits
    from orders 
    group by r_id,user_id
    having count(*)>1
    order by visits
	)
select r.r_name, count(*) as loyal_customer
from my_cte
join restaurants as r
on my_cte.r_id = r.r_id
group by r.r_id
order by loyal_customer desc


/* Q : Month over month revenue growth of a restuarants */

select month,round((((revenue-prev)/prev)*100),2) as monthly_rev from 
(
	with sales as
	( 
		SELECT TO_CHAR(date, 'Month') AS month, SUM(amount) AS revenue
        FROM orders o
		JOIN restaurants r ON o.r_id = r.r_id
		WHERE r.r_name = 'kfc'
        GROUP BY TO_CHAR(date, 'Month')
        order by TO_CHAR(date, 'Month') desc
    )
select month,revenue,lag(revenue,1) over(order by revenue) as prev from sales

)t








