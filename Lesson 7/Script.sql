-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ (orders) в интернет-магазине.

SELECT 
	u.id AS user_id, u.name,
	o.id AS order_id
FROM 
	users AS u
RIGHT JOIN
	orders AS o 
ON
	u.id = o.user_id;

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT 
	p.id, p.name, p.price,
	c.id AS cat_id,
	c.name AS catalog
FROM
	products AS p
JOIN
	catalogs AS c
ON 
	p.catalog_id = c.id; 
