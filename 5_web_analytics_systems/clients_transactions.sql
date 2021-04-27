SELECT 
	COUNT(*) `transactions_count`, 
	SUM(`transaction_sum`) `transactions_sum`, 
	AVG(`transaction_sum`) `transactions_average` 
FROM `transactions`;


SELECT 
	`c`.`id_client` `id_client`, 
	MIN( CONCAT( `t`.`transaction_date`, ' ', `t`.`transaction_time`) ) `datetime`
FROM `clients` `c` 
LEFT JOIN `transactions` `t` ON `c`.`id_client` = `t`.`id_client` 
GROUP BY `id_client`;

SELECT `id`, `limit`, `spent`, `used, %` 
FROM (
	SELECT 
		`c`.`id_client` `id`,
	 	`c`.`limit_sum` `limit`,
	 	`t`.`transaction_sum` `spent`, 
	 	`t`.`transaction_sum` / `c`.`limit_sum` * 100 `used, %`
	FROM `clients` `c` 
	LEFT JOIN `transactions` `t` ON `c`.`id_client` = `t`.`id_client`
	) `t` 
WHERE `used, %` > 70;

