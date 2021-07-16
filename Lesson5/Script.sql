
-- по теме проекта выберу привычную для себя условную систему сладского учета


use lesson5;
CREATE TABLE USERS(created_at VARCHAR(256), updated_at VARCHAR(256));

DELETE FROM USERS;
INSERT INTO
    USERS (created_at, updated_at)
VALUES
    ('20.10.2017 8:10','25.11.2018 10:11'),
    ('21.6.2015 8:10',NULL),
   	(NULL,'3.7.2019 10:11');
   
SELECT * from users;
-- 1.1 Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
UPDATE users
    SET created_at = NOW() where created_at is NULL;
UPDATE users
	SET updated_at = NOW() where updated_at is NULL;
-- 1.2 Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i');
UPDATE users SET updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');

ALTER TABLE users MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
-- 1.3 В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. 
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.
create table storehouses_products (
    storehouse_id INT unsigned,
    product_id INT unsigned,
    `value` INT unsigned 
);

INSERT INTO
    storehouses_products (storehouse_id, product_id, value)
VALUES
    (1, 1, 15),
    (1, 3, 0),
    (1, 5, 10),
    (1, 7, 5),
    (1, 8, 0);

SELECT 
    value
FROM
    storehouses_products ORDER BY CASE WHEN value = 0 then 1 else 0 end, value;
   

-- 2.1 Подсчитайте средний возраст пользователей в таблице users.
 SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())), 0) AS AVG_Age FROM users;

-- 2.2 Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, а не года рождения.
 SELECT
	DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day,
	COUNT(*) AS total
FROM
	users
GROUP BY
	day
-- 2.3 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.
SELECT ROUND(exp(SUM(ln(value))), 0) AS factorial FROM integers;
    
