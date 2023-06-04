-- Применим функцию ntile() 
-- Эта функция возвращает номер группы, в которую попадает соответствующая строка результирующего набора. 
-- Поскольку нам нужно ранжировать клиентов для RFM на 5-ти оценках, то предоставим выбор функции 




with o as (
	select o.user_id, o.order_ts, o.payment
	from production.orders o, production.orderstatuses os 
	where os."key" = 'Closed' and o.status = os.id 
),
uo as (
	select u.id, 
		max(o.order_ts) as "date_last_order",
		count(o.*) as "count_orders",
		coalesce(sum(o.payment),0) as "sum_payment"
	from production.users u
	left join o on o.user_id = u.id 
	where o.order_ts >= '01.01.2022'::timestamp
	group by u.id
	),
frequency as
	(select 
		count_orders,
		ntile(5) OVER( order by count_orders ) as "frequency"
	from (select count_orders from uo group by count_orders) t ),
monetary as
	(select 
		sum_payment,
		ntile(5) OVER( order by sum_payment) as "monetary_value"
	from (select sum_payment from uo group by sum_payment) t ),
recency as
	(select 
		date_last_order,
		ntile(5) OVER( ORDER BY t.date_last_order nulls first) as "recency"
	from (select date_last_order from uo group by date_last_order) t )
	
SELECT uo.id as "user_id",   
	recency.recency,
	frequency.frequency,
	monetary.monetary_value
from uo
join frequency on frequency.count_orders = uo.count_orders
join recency on recency.date_last_order = uo.date_last_order
join monetary on monetary.sum_payment = uo.sum_payment



-- Запишем результат DDL-запрос для создания витрины.



create table analysis.dm_rfm_segments (
	user_id int NOT NULL PRIMARY KEY,
    recency int NOT NULL CHECK(recency >= 1 AND recency <= 5)
	frequency int NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
	monetary_value int NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);```

```SQL
insert into analysis.dm_rfm_segments 
with o as (
	select o.user_id, o.order_ts, o.payment
	from analysis.orders1 o, analysis.orderstatuses os 
	where os."key" = 'Closed' and o.status = os.id 
),
uo as (
	select u.id, 
		max(o.order_ts) as "date_last_order",
		count(o.*) as "count_orders",
		coalesce(sum(o.payment),0) as "sum_payment"
	from analysis.users u
	left join o on o.user_id = u.id 
	where o.order_ts >= '01.01.2022'::timestamp
	group by u.id
	),
frequency as
	(select 
		count_orders,
		ntile(5) OVER( order by count_orders ) as "frequency"
	from (select count_orders from uo group by count_orders) t ),
monetary as
	(select 
		sum_payment,
		ntile(5) OVER( order by sum_payment) as "monetary_value"
	from (select sum_payment from uo group by sum_payment) t ),
recency as
	(select 
		date_last_order,
		ntile(5) OVER( ORDER BY t.date_last_order nulls first) as "recency"
	from (select date_last_order from uo group by date_last_order) t )
	
SELECT uo.id as "user_id",   
	recency.recency,
	frequency.frequency,
	monetary.monetary_value
from uo
join frequency on frequency.count_orders = uo.count_orders
join recency on recency.date_last_order = uo.date_last_order
join monetary on monetary.sum_payment = uo.sum_payment







