-- Задания на БД vk:

-- 1. Проанализировать какие запросы могут выполняться наиболее
-- часто в процессе работы приложения и добавить необходимые индексы.
CREATE INDEX communities_updated_at_idx ON communities(updated_at); 
-- думаю, групп будет много, а для ленты новостей пригодится выбирать последние обновления регулярно
CREATE INDEX friendship_updated_at_idx ON friendship(updated_at); 
CREATE INDEX friendship_statuses_updated_at_idx ON friendship_statuses(updated_at); 
CREATE INDEX likes_created_at_idx ON likes(created_at); 
CREATE INDEX media_updated_at_idx ON media(updated_at); 
CREATE INDEX profiles_updated_at_idx ON profiles(updated_at); 
-- по той же причине
SHOW INDEX FROM users;


-- 2. Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- (сумма количестива пользователей во всех группах делённая на количество групп)
-- самый молодой пользователь в группе (желательно вывести имя и фамилию)
-- самый старший пользователь в группе (желательно вывести имя и фамилию)
-- количество пользователей в группе
-- всего пользователей в системе (количество пользователей в таблице users)
-- отношение в процентах для последних двух значений 
-- (общее количество пользователей в группе / всего пользователей в системе) * 100


SELECT DISTINCT 
 communities.name,
 (SELECT COUNT(communities_users.user_id) FROM communities_users)/(SELECT COUNT(DISTINCT communities_users.community_id) FROM communities_users)  AS average,
 FIRST_VALUE(CONCAT(users.first_name, ' ', users.last_name)) OVER (PARTITION BY communities.id ORDER BY profiles.birthday) as young,
 LAST_VALUE(CONCAT(users.first_name, ' ', users.last_name)) OVER (PARTITION BY communities.id ORDER BY profiles.birthday
    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS  'old',
 COUNT(communities_users.user_id) OVER (PARTITION BY communities.id) AS 'count',
 (SELECT COUNT(*) from users) AS users,
 COUNT(communities_users.user_id) OVER (PARTITION BY communities.id)/(SELECT COUNT(*) from users) AS '%%'
from communities_users
Left Join profiles ON communities_users.user_id = profiles.user_id
Left Join communities ON communities.id = communities_users.community_id
Left Join users ON users.id = communities_users.user_id 

;
 -- COUNT(DISTINCT communities_users.user_id)  AS average,

