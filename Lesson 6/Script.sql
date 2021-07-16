ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT profiles_city_id_fk 
    FOREIGN KEY (city_id) REFERENCES cities(id);
   
ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id);
   
ALTER TABLE cities
  ADD CONSTRAINT cities_country_id_fk 
    FOREIGN KEY (country_id) REFERENCES countries(id);
   
ALTER TABLE communities_users
  ADD CONSTRAINT communities_users_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT communities_users_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id);
  
ALTER TABLE media
  ADD CONSTRAINT media_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_media_type_id_fk 
    FOREIGN KEY (media_type_id) REFERENCES media_types(id); 
    
ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_community_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT media_media_id_fk 
    FOREIGN KEY (media_id) REFERENCES media(id); 
   
ALTER TABLE friendship
  ADD CONSTRAINT friendship_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_friend_id_fk 
    FOREIGN KEY (friend_id) REFERENCES users(id),
  ADD CONSTRAINT friendship_friendship_status_id_fk 
    FOREIGN KEY (friendship_status_id) REFERENCES friendship_statuses(id);    
   
 ALTER TABLE likes
  ADD CONSTRAINT likes_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT likes_target_id_fk 
    FOREIGN KEY (target_id) REFERENCES users(id);   

-- 3.Определим кто больше поставил лайков (всего) - мужчины или женщины (для получения разбивки по всем полам достаточно будет убрать LIMIT 1 из запроса):   
SELECT 
  (SELECT gender from profiles WHERE profiles.user_id = likes.user_id) AS gender,
  COUNT(*) AS 'Number of likes'
    FROM likes 
    GROUP BY gender
    ORDER BY COUNT(*) DESC LIMIT 1;
-- 4.Подсчитать количество лайков, которые получили десять самых молодых пользователей:
SELECT
  target_id,
 (SELECT(CONCAT(first_name, ' ', last_name)) FROM users WHERE users.id = likes.target_id) AS name,
 (SELECT birthday from profiles WHERE profiles.user_id = likes.target_id) AS birthday,
  COUNT(*) AS 'Number of likes'  
FROM likes WHERE target_type = 2
GROUP BY target_id
ORDER BY birthday DESC LIMIT 10;
   
  
   