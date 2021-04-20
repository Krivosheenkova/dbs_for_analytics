USE `orders`;

SET @R3 := 3; 
SET @R2 := 30;

SET @F1 := 20;
SET @F2 := 100; 


SET @last_date := (SELECT MAX(`o_date`) FROM `orders_20190822` WHERE `o_date` < '2017/05/01');

WITH  `users_17_05` as (SELECT DISTINCT (`user_id`) 
  						FROM `orders_20190822` 	
  						WHERE `o_date` >= @last_date),

	  `R` as (SELECT  `user_id`, 
	                MAX(`o_date`) `maxdate`, 
	                DATEDIFF(@last_date, MAX(`o_date`)) `days` 
	        FROM `orders_20190822` WHERE `o_date` < @last_date 
	        GROUP BY `user_id`),

	  `F` AS (SELECT `user_id`, 
	   			     COUNT(DISTINCT `id_o`) `cnt` 
	   		  FROM `orders_20190822` 	
	  		  WHERE `o_date` < @last_date
	  		  GROUP BY `user_id`),
	  
	  `M` AS (SELECT `user_id`, 
	  			     DATE_FORMAT(`o_date`,"%y%m") `period`, 
	  			     SUM(`price`) `sum_price` 
	  	      FROM `orders_20190822` 
	  	      WHERE `o_date` < @last_date 
	  	      GROUP BY `user_id`, `period`),
	  
	  `RF` as (SELECT `R`.`user_id`, 
	  				  `R`.`days` as `R`, 
	  				  `F`.`cnt` as `F`, 
	  				  CASE  WHEN `R`.`days` <= @R3 THEN 3
	            			WHEN  `R`.`days` <= @R2 THEN 2
	      					ELSE 1 
	      					END as `R1`,
	      					CASE  WHEN `F`.`cnt` <= @F1 THEN 1
	            			WHEN  `F`.`cnt` <= @F2 THEN 2
	      					ELSE 3 
	      					END as `F1`, 0 as `M1`
	      
	    	   FROM `R` 
	    	   INNER JOIN `F` 
	    	   ON `R`.`user_id` = `F`.`user_id`),

	  `USERGROUPS` AS (SELECT `RF`.`user_id`,
	  						  `RF`.`R`,
	      					  `RF`.`F`,
	      					  CONCAT(`RF`.`R1`,`RF`.`F1`) `RF`,
	      					  CASE  
	            				/* часто покупающие и которые последний раз покупали не так давно.*/
	            			  WHEN  CONCAT(`RF`.`R1`,`RF`.`F1`) 
	            			  	IN ('33', '23', '32', '31', '22', '21') 
	            			  	THEN 'good_regular_users' 
	      
	      				        /* часто покупающиe, но которые не покупали уже значительное время.*/
	            			  WHEN  CONCAT(`RF`.`R1`,`RF`.`F1`) 
	            			  	IN ('13') 
	            			  	THEN 'bad_regular_users' 
	            
	            				/* пользователи с 1 и 2 покупками за все время*/
	            			  WHEN  `RF`.`F` < 3 
	            			  	AND CONCAT(`RF`.`R1`,`RF`.`F1`) NOT IN ('31', '21') 
	            			  	THEN 'lost_users'

	            			  ELSE 'undefined_group' 
	      				      END as `G`
	    			   FROM `RF` INNER JOIN `M` ON `M`.`user_id` = `RF`.`user_id`)
  
	  	SELECT
	  	`u`.`G`
	  	-- ,m.user_id
	  	,`m`.`period`
	  	,SUM(`M`.`m`)
	  	,count(`M`.`user_id`)
	  from `M` `m` 
	  left join `USERGROUPS` `u` on `m`.`user_id` = `u`.`user_id`
	  group by `u`.`G`, `period`;
  




-- /* таблица когорт вида: 1234567 | 1701 */
-- DROP TABLE IF EXISTS cogs; 
-- CREATE TABLE cogs AS 
-- 	SELECT user_id, DATE_FORMAT(MIN(o_date), '%y%m') cog 
-- 	FROM orders_20190822 WHERE o_date < @last_date 
-- 	GROUP BY user_id;

-- /* таблица вида: 1701 | 1702 | 1982101.0 */
-- DROP TABLE IF EXISTS USERCOGS;
-- CREATE TABLE USERCOGS AS 
-- 	(
-- 		SELECT t.cog, DATE_FORMAT((o_date), "%y%m") `date`, SUM(price) `sum_price` 
-- 		FROM orders_20190822 as o 
-- 			JOIN cogs t ON o.user_id = t.user_id 
-- 		GROUP BY t.cog, DATE_FORMAT((o.o_date), "%y%m");

-- 	);


-- CREATE TABLE users_17_05 AS (
-- 		SELECT user_id 
-- 		FROM orders_20190822 
-- 		WHERE o_date < @last_date
-- 		);


-- /* вычислим хороших пользователей, у которых больше трех покупок, которые не так давно покупали */
-- DROP TABLE IF EXISTS good_regular_users; 
-- CREATE TABLE good_regular_users AS (
-- 	SELECT COUNT(DISTINCT id_o) / COUNT(DISTINCT O_date) frequency, 
-- 		   MIN(o_date), 
-- 		   o_date, 
-- 		   user_id 
--     FROM orders_20190822 
--     WHERE DATEDIFF(@last_date, o_date) < 30 
--     	  AND 
--     	  user_id IN (SELECT user_id FROM users_17_05) 
--     GROUP BY user_id HAVING COUNT(*) > 3);

