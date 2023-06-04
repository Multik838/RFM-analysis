create or replace view analysis.orders
as
 select orders.order_id, orders.order_ts, orders.user_id, orders.bonus_payment, orders.payment, orders."cost", orders.bonus_grant, ord_status.status
 from production.orders
 join
(  
	--29982
	SELECT order_id, "key" as status, row_number() over(partition by order_id order by dttm desc) rn
	FROM production.orderstatuslog
	JOIN production.orderstatuses on orderstatuses.id = orderstatuslog.status_id
) as ord_status on orders.order_id = ord_status.order_id and ord_status.rn = 1
;