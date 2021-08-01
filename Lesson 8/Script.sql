-- Переписать запросы, заданые к ДЗ урока 6, с использованием JOIN
-- 3.Определить кто больше поставил лайков (всего) - мужчины или женщины?   
SELECT 
  profiles.gender,
  COUNT(*) AS 'Number of likes'
    FROM likes
    Left join profiles
    ON profiles.user_id = likes.user_id
    GROUP BY gender
    ORDER BY COUNT(*) DESC LIMIT 1;
  
-- 4.Вывести для каждого пользователя количество созданных сообщений, постов, загруженных медиафайлов и поставленных лайков.
SELECT
 CONCAT(first_name, ' ', last_name) AS name,
 COUNT(*) AS messages,
 COUNT(*) AS posts,
 COUNT(*) AS media,
 COUNT(*) AS likes 
FROM users
left join messages ON messages.from_user_id = users.id
left join posts ON posts.user_id = users.id
left join media ON media.user_id = users.id
left join likes ON likes.user_id = users.id
GROUP BY CONCAT(first_name, ' ', last_name)
LIMIT 10;
   
   