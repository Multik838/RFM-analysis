# Проект 1-го спринта RFM-analysis

### Описание
RFM analysis is a marketing tool commonly used by businesses for successful customer segmentation. RFM stands for Recency, Frequency, and Monetary Value, and as the name suggests, it helps to analyze the customer’s behavior over a period of time.

Recency brings the latest purchase of a customer into consideration. This metric helps in determining the time between two purchases, indicating the customer’s loyalty towards the company.

Frequency measures how often a customer buys a product or service. This metric tracks the number of times a customer has purchased from the company as it helps to identify a customer’s repeat buying behavior.

Monetary Value emphasizes the economic aspect of a customer. This metric assesses a customer's spending patterns, determining the customer’s overall contribution to the company’s revenue.

Using RFM analysis, businesses can segment their customers into different categories. For example, a customer who has recently made large purchases from the company has a low recency score but a high monetary score.

By understanding these customer segments, companies can customize their marketing and sales strategies, as well as create targeted promotions that resonate with specific segments of their customer base. This targeted approach leads to increased customer retention, loyalty, and ultimately, higher revenue for the business.

### 1.1. Requirements for the target showcase.
Assign each client three values — the value of the Recency factor, the value of the Frequency factor and the value of the Monetary Value factor:
- The Recency factor is measured by the last order. Distribute customers on a scale from one to five, where the value of 1 will be given to those who either did not make orders at all, or did them for a very long time, and 5 — to those who ordered relatively recently.
- The Frequency factor is estimated by the number of orders. Distribute customers on a scale from one to five, where the value of 1 will be given to customers with the least number of orders, and 5 — with the largest.
- The Monetary Value factor is estimated by the amount spent. Distribute customers on a scale from one to five, where the value of 1 will be given to the customers with the smallest amount, and 5 — with the largest.


**Necessary checks and conditions:**

Check that the number of customers in each segment is the same. For example, if there are only 100 clients in the database, then 20 clients should get the value 1, another 20 — the value 2, etc.
For analysis, you need to select only successfully completed orders - an order with the Closed status.
When calculating the showcase, they are asked to refer only to objects from the analysis scheme. In order not to duplicate the data (the data is in the same database), we decide to create a view. Thus, the View will be in the analysis schema and subtract data from the production schema.
Where data is stored: the production schema contains operational tables.

**Where to save the showcase:** the showcase should be located in the same database in the analysis scheme.

The structure of the showcase: the showcase should be called dm_rfm_segments and consist of the following fields: - user_id - recency (number from 1 to 5) - frequency (number from 1 to 5) - monetary_value (number from 1 to 5) Data depth: data from the beginning of 2022 is needed in the showcase.

Updates are not needed.

###  1.2. The structure of the source data.
The data will be taken from the production schema, the following tables and the corresponding columns:

The users table. Fields used: id(int type) - user ID.
The order statuses table. Fields used: id(int type) - order status identifier, key(varchar type(255)) - status key value.
The orders table. Fields used: user_id(int type) - user ID, order_ts(timestamp type) - date and time of the order, payment(numeric(19,5)) - amount of payment for the order.

###  1.3. Качество данных
 |    Table      |    View for analytics   |   Object   |  Tools/Connection    |  description    | 
 | ------------- | ----------------------- | ---------- | -------------------- | --------------- |
 | production.users | analysis.users | id int NOT  | PRIMARY KEY | Первичный ключ	Обеспечивает уникальность записей о пользователях |
 | production.orderstatuses | analysis.orderstatuses | id int NOT NULL | PRIMARY KEY | Первичный ключ	Обеспечивает уникальность записей о пользователях |
 | production.orderstatuses | analysis.orderstatuses | key varchar(255) NOT NULL | NOT NULL | Обеспечивает отсутствие пустых значений поля ключа статуса заказа |
 | production.orders | analysis.orders | id int NOT NULL | PRIMARY KEY | Первичный ключ	Обеспечивает уникальность записей о заказах |
 | production.orders | analysis.orders | status varchar(255) NOT NULL | NOT NULL | Обеспечивает отсутствие пустых значений поля ключа статуса заказа |
 | production.orders | analysis.orders | user_id int NOT NULL | NOT NULL | Обеспечивает отсутствие пустых значений поля идентификатора пользователя  |
 | production.orders | analysis.orders | order_ts timestamp NOT NULL | NOT NULL | Обеспечивает отсутствие пустых значений поля даты заказа           | 

**The users and order statuses tables.**

There are no complaints about the quality of the data.

**The orders table.**

There are no complaints about the quality of the available data. Possible sources of problems:

-- no foreign key, for the user_id field.
-- table orders has information about orders without payment,
no verification of the payment field for a value greater than 0;

###  1.4. Preparation of the data showcase

**1.4.1. SQL queries to create a VIEW for tables from the production schema.** in the analysis schema.**

To create users:

CREATE VIEW analysis.Users AS
SELECT * FROM production.Users;

To create OrderItems:

CREATE VIEW analysis.OrderItems AS
SELECT * FROM production.OrderItems;

To create OrderStatuses:

CREATE VIEW analysis.OrderStatuses AS
SELECT * FROM production.OrderStatuses;

To create Products:

CREATE VIEW analysis.Products AS
SELECT * FROM production.Products;

To create Orders:

CREATE VIEW analysis.Orders AS
SELECT * FROM production.Orders;

**1.4.2. SQL queries to create table analysis.dm_rfm_segments.**

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



