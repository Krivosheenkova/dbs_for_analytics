-- Проанализировать, какой период данных выгружен
(SELECT `o_date` `period_from_to` FROM `orders_20190822` ORDER BY `o_date` LIMIT 1)  
UNION 
(SELECT `o_date` FROM `orders_20190822` ORDER BY `o_date` DESC LIMIT 1);

SELECT DATEDIFF((SELECT `o_date` FROM `orders_20190822` ORDER BY `o_date` DESC LIMIT 1), 
                (SELECT `o_date` FROM `orders_20190822` ORDER BY `o_date` LIMIT 1)) `period_days`;

-- Посчитать кол-во строк
SELECT COUNT(*) `number_rows` FROM `orders_20190822`;

-- кол-во заказов 
SELECT COUNT(DISTINCT `id_o`) `unique_order_ids` FROM `orders_20190822`;

-- кол-во уникальных пользователей
SELECT COUNT(DISTINCT `user_id`) `unique_user_ids` FROM `orders_20190822`;

-- по годам, по месяцам средний чек
SELECT `year`, `month`, `avg_check` `average_check` 
FROM 
	(SELECT YEAR(`o_date`) `year`, MONTH(`o_date`) `month`, ROUND(AVG(`price`), 2) `avg_check` 
	 FROM `orders_20190822` GROUP BY `id_o`) t 
GROUP BY `month`, `year`;

-- среднее кол-во заказов на пользователя по году
SELECT `year`, AVG(`cnt`) `average_orders_by_user_by_year` 
FROM 
	(SELECT YEAR(`o_date`) `year`, COUNT(*) `cnt` 
     FROM `orders_20190822` GROUP BY `user_id`, YEAR(`o_date`)) t 
GROUP BY `year`;

-- среднее кол-во заказов на пользователя по годам и месяцам 
SELECT `year`, `month`, AVG(`cnt`) `average_orders_by_month_n_year` 
FROM 
	(SELECT YEAR(`o_date`) `year`, MONTH(`o_date`) `month`, COUNT(`user_id`) `cnt` 
	 FROM `orders_20190822` GROUP BY `user_id`) t 
GROUP BY `month`, `year` 
ORDER BY `year`, `month`;


-- Найти кол-во пользователей, кот покупали в одном году и перестали покупать в следующем
CREATE OR REPLACE VIEW `orders2016` AS 
	SELECT * FROM `orders_20190822` WHERE YEAR(`o_date`) = 2016;

CREATE OR REPLACE VIEW `orders2017` AS 
	SELECT * FROM `orders_20190822` WHERE YEAR(`o_date`) = 2017;

SELECT `o16`.`user_id` FROM `orders2016` `o16` 
LEFT JOIN `orders2017` `o17` ON `o16`.`user_id` = `o17`.`user_id` 
 WHERE `o17`.`user_id` IS NULL;

-- быстрее: 
SELECT DISTINCT `user_id` FROM `orders2016` 
	WHERE `user_id` NOT IN (SELECT DISTINCT `user_id` FROM `orders2017`;


-- Найти ID самого активного по кол-ву покупок пользователя
SELECT `user_id`, COUNT(DISTINCT `id_o`) `orders_amount` 
FROM `orders_20190822` GROUP BY `user_id` ORDER BY `orders_amount` DESC LIMIT 10;


-- Найти коэффициенты сезонности по месяцам
SELECT `o`.`year`, `o`.`month`, ROUND(`o`.`orders` / `ob`.`total`, 2) `seasonal_factor` 
FROM 
	(SELECT YEAR(`o_date`) `year`, MONTH(`o_date`) `month`, COUNT(DISTINCT `id_o`) `orders` 
	 FROM `orders_20190822`  GROUP BY `month`, `year`) `o` 

LEFT JOIN 

	(SELECT YEAR(`o_date`) `year`, COUNT(DISTINCT `id_o`) `total` 
	 FROM `orders_20190822` GROUP BY `year`) `ob` 

ON `o`.`year` = `ob`.`year`;