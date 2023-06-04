--��������� ������� ������� ��� �������� � �������� ������� Recency, 
--�������� ������� Frequency � �������� ������� Monetary Value:
--������ Recency ���������� �� ���������� ������. 
--������������ �������� �� ����� �� ������ �� ����, 
--��� �������� 1 ������� ��, ��� ���� ������ �� ����� �������, 
--���� ����� �� ����� �����, � 5 � ��, ��� ��������� ������������ �������.



--����� � ������� Recency.
--��������� ������� �������� � ������, 
--����� ������ ����� ������ ��������� ������� �� 1 ��,
--��� 1 - ��� �������, ������� �� ������ �������.
--� ��� ����� ���������� �� ������ ������ 
--����� ������ � ������ 2022 ����.

��� ������� ������ ������� ������ 
������� � ����������� �� �������.

select 
order_id,
order_ts,
user_id,
bonus_payment,
payment,
"cost",
bonus_grant,
status
from analysis.orders o 


select 
count(distinct user_id), -- ���������� �������� 1 000
count(user_id)           -- ����� ������� � �������� 10 000
from analysis.orders o 


select 
min(order_ts),  -- 2022-02-12 02:41:28.000
max(order_ts)   -- 2022-03-14 02:38:26.000
from analysis.orders o 

select 
distinct bonus_payment -- �� ��� ������ ����� ? ������ �� 0
from analysis.orders o 

-- �������� null ��� ?

--select 
--*
--from analysis.orders o
--where user_id is null or 
--order_id is null or 
--order_ts is null or 
--payment is null



select 
user_id,
count(order_id),
date(date_trunc('day', order_ts))
from analysis.orders o
group BY
user_id,
date(date_trunc('day', order_ts))
order by user_id, date

--��� ����� user_id = 0 ?
--0	1	2022-02-13
--0	2	2022-02-15
--0	1	2022-02-16
--0	1	2022-02-18
--0	1	2022-02-23
--0	1	2022-02-25
--0	1	2022-02-26


-- user_id = 0 ����, ��� �� ������ �� 0 �� 999
select 
distinct user_id,
u.*
from analysis.orders o
left join analysis.users u on 
o.user_id = u.id 


-- �������, ����� 31 ����. ������ ����� ������ ������ �� �������
select
date(date_trunc('day', order_ts))
from analysis.orders o
group by date(date_trunc('day', order_ts))
order by date(date_trunc('day', order_ts))

--������ ������: 12.02.2022 - 14.02.2022 - �������� ���, ��� ��� 14 ������� - ���� ������� ���������.
--������ ������: 15.02.2022 - 21.02.2022 - ������ ���.
--������ ������: 22.02.2022 - 28.02.2022 - ������ ���.
--��������� ������: 01.03.2022 - 07.03.2022 - ������ ���, �� ������� 8 ����� - ������������� ������� ����.
--����� ������: 08.03.2022 - 14.03.2022 - ������ ���.


-- ���� �������� �������� ���� � ��� �� ����� �������� 1 � �������� 2
--case 
--	when date_order >= '2022-02-12' and date_order < '2022-02-15' then 1
--	when date_order >= '2022-02-15' and date_order < '2022-02-22' then 2
--	when date_order >= '2022-02-22' and date_order < '2022-03-01' then 3
--	when date_order >= '2022-03-01' and date_order < '2022-03-08' then 4
--	when date_order >= '2022-03-08' then 5
--end as resently


--1				
--24.02.2022				
--25.02.2022				
--26.02.2022				
--27.02.2022	
--	2			
--	28.02.2022			
--	01.03.2022			
--	02.03.2022			
--	03.03.2022
--	    3		
--		04.03.2022		
--		05.03.2022		
--		06.03.2022		
--		07.03.2022	
--          4	
--			08.03.2022	
--			09.03.2022	
--			10.03.2022	
--			11.03.2022	
--              5
--				12.03.2022
--				13.03.2022
--				14.03.2022



drop table analysis.pre_recency;


create table analysis.pre_recency as
with a as (
select o.*, 
date(date_trunc('day', order_ts)) as date_order 
from analysis.orders o
), 
b as (
select 
distinct date_order,
case 
	when date_order >= '2022-02-12' and date_order < '2022-03-01' then 1 -- � ��� ������ �������� ���������
	when date_order >= '2022-03-01' and date_order < '2022-03-05' then 2 -- ���������������� ���
	when date_order >= '2022-03-05' and date_order < '2022-03-09' then 3 -- ����������� ���
	when date_order >= '2022-03-09' and date_order < '2022-03-13' then 4 -- ����� �����������
	when date_order >= '2022-03-13' then 5                               -- ��������
end as resently
from a),
c as (
select
user_id, max(date_order) as date_order, resently
from a 
join b using(date_order)
group by user_id, resently)
select 
user_id,
max(resently) as recency
from c
group by
user_id;


create table analysis.recency_table as
select
o.user_id,
max(date(date_trunc('day', o.order_ts))) as last_order_dt,
pr.recency
from analysis.orders as o
join analysis.pre_recency as pr on 
o.user_id = pr.user_id
group by 
o.user_id,
pr.recency;



--select
--distinct date(date_trunc('day', order_ts))
--from analysis.orders o
--where 
--user_id IN
--(743,
--279,
--408,
--214,
--949,
--669,
--634,
--487,
--995)




-- ���������� �������/����� �� ������� ������ �� ��������, ��   � ��������� ������ ��������� ��� ������������� �� ���������� (����� �� � �������� ����������)

-- ������� ������ ������� �� �������� Closed � Cancelled


--������ 2: frequency. 
--������� ����������� � ����������� �������. 
--� ����� ������ ����� �������, ��� ��� ���� � �� ��. 
--���������� ������� �� ����� ���� NULL, 
--������� � ������������ � user_id = 10, 
--���������� ������� 0. 

create table analysis.order_info as
select 
osl.order_id,
osl.status_id,
os."key"
from production.orderstatuslog as osl
join analysis.orderstatuses as os on 
osl.status_id = os.id;



create table analysis.pre_frequency_table as
with filter_closed_order as (
select 
o.user_id,
o.status,
oi.key,
count(o.order_id) as cnt
from analysis.orders as o
join analysis.order_info as oi on 
o.order_id = oi.order_id
where oi.key = 'Closed'
group by 
o.user_id,
o.status,
oi.key )
select 
user_id,
sum(cnt) as order_count,
case 
	when sum(cnt) >= 12 then 5
	when sum(cnt)>= 9 and sum(cnt) < 12 then 4
	when sum(cnt)>= 6 and sum(cnt) < 9 then 3
	when sum(cnt)>= 3 and sum(cnt) < 6 then 2
	when sum(cnt) < 3 then 1
end as frequency
from filter_closed_order
group by
user_id;


-- ������ ���� �� NULL, �������� id
--467		
--276		
--837		
--211		
--889		
--930		
--224		
--977		
--514		
--821		
--730		
--784		

-- ���������� ������� �� ����� ���� NULL, ������� � ������������ � user_id ..., ���������� ������� 0

-- frequency_table

drop table analysis.frequency_table;
create table analysis.frequency_table as
SELECT
u.id as user_id,
COALESCE(pft.order_count,0) AS order_count,
COALESCE(pft.frequency,1) AS frequency
FROM analysis.users AS u
LEFT JOIN analysis.pre_frequency_table AS pft ON
u.id = pft.user_id;


--������ 3: monetary value. 
--������ ������������� �� ��������� �������� ����� ��, ��� � � �������, 
--������ ������� ����� �����, ����������� �������������.

-- ��������, ��� payment � "cost" ����������, ����� ����� ����� ���� ��� ����� �� �������
select 
payment,"cost",
case when payment <> "cost" then 1
else 0 end
from analysis.orders


drop table analysis.pre_monetary_value;


create table analysis.pre_monetary_value as
WITH payment_join AS (
SELECT
o.user_id,
o.status,
oi.key,
o.order_id,
o.payment
FROM analysis.orders as o
JOIN analysis.order_info as oi ON o.order_id = oi.order_id
WHERE oi.key = 'Closed'
)
SELECT
user_id,
SUM(payment) as sum_payment
FROM payment_join
GROUP BY user_id;

--- �������� ������������� �������� sum_payment
select 
count(sum_payment),
case 
	when sum_payment >= 24000 then 5
	when sum_payment >= 18000 and sum_payment < 24000 then 4
	when sum_payment >= 12000 and sum_payment < 18000 then 3
	when sum_payment >= 6000 and sum_payment < 12000 then 2
	when sum_payment < 6000 then 1
end
from analysis.pre_monetary_value
group by
case 
	when sum_payment >= 24000 then 5
	when sum_payment >= 18000 and sum_payment < 24000 then 4
	when sum_payment >= 12000 and sum_payment < 18000 then 3
	when sum_payment >= 6000 and sum_payment < 12000 then 2
	when sum_payment < 6000 then 1
end;

-- monetary_value
create table analysis.monetary_value as
SELECT
u.id as user_id,
coalesce(pmv.sum_payment,0) as order_sum,
case 
	when sum_payment >= 24000 then 5
	when sum_payment >= 18000 and sum_payment < 24000 then 4
	when sum_payment >= 12000 and sum_payment < 18000 then 3
	when sum_payment >= 6000 and sum_payment < 12000 then 2
	else 1
end as monetary_value
FROM analysis.users AS u
left join analysis.pre_monetary_value as pmv on
u.id = pmv.user_id

-- ������

--drop table analysis.order_info;
--drop table analysis.pre_frequency_table;
--drop table analysis.pre_monetary_value;
--drop table analysis.pre_recency;


