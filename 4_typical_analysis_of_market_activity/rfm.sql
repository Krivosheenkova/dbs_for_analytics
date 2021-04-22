USE `orders`;

SET @R1 := 365; 
SET @R3 := 100;
SET @R4 := 60;
SET @R5 := 30;

SET @F1 := 1;
SET @F2 := 2;
SET @F3 := 10;
SET @F4 := 20;
SET @F5 := 50;

SET @M1 := 0;
SET @M2 := 500;
SET @M3 := 1000;
SET @M4 := 10000;
SET @M5 := 50000;

SET @last_date := (SELECT MAX(`o_date`) FROM `orders_20190822`);

WITH
	  `R` as (SELECT  `user_id`, 
	                MAX(`o_date`) `maxdate`, 
	                DATEDIFF(@last_date, MAX(`o_date`)) `days` 
	        FROM `orders_20190822` 
	        WHERE `price` > 0 
	        GROUP BY `user_id`),

	  `F` AS (SELECT `user_id`, 
	   			     COUNT(DISTINCT `id_o`) `cnt` 
	   		  FROM `orders_20190822` 	
	  		  WHERE `price` > 0
	  		  GROUP BY `user_id`),
	  
	  `M` AS (SELECT `user_id`, 
	  			     SUM(`price`) `sum_price` 
	  	      FROM `orders_20190822` 
	  	      WHERE `price` > 0 
	  	      GROUP BY `user_id`),
	  
	  `RF` as (SELECT `R`.`user_id`, 
	  				  `R`.`days` as `R`, 
	  				  `F`.`cnt` as `F`, 
	  				  CASE  WHEN `R`.`days` > @R5 THEN 5
	            			WHEN  `R`.`days` BETWEEN @R4 AND @R5 THEN 4
	            			WHEN `R`.`days` BETWEEN @R3 and @R4 THEN 3
	            			WHEN `R`.`days` BETWEEN @R3 AND @R1 THEN 2
	      					ELSE 1 
	      					END as 
	      						`R1`,

	      			  CASE  WHEN `F`.`cnt` BETWEEN @F1 AND @F2 THEN 1
	            			WHEN  `F`.`cnt` BETWEEN @F2 AND @F3 THEN 2
	            			WHEN `F`.`cnt` BETWEEN @F3 AND @F4 THEN 3
	            			WHEN `F`.`cnt` BETWEEN @F4 AND @F5 THEN 4
	      					ELSE 5
	      			  END as `F1`, 

	      			  CASE WHEN `M`.`sum_price` BETWEEN @M1 AND @M2 THEN 1
	      			  	   WHEN `M`.`sum_price` BETWEEN @M2 AND @M3 THEN 2
	      			  	   WHEN `M`.`sum_price` BETWEEN @M3 AND @M4 THEN 3
	      			  	   WHEN `M`.`sum_price` BETWEEN @M4 AND @M5 THEN 4
	      			  	   WHEN `M`.`sum_price` > @M5 THEN 5
	      			  	   ELSE 0
	      			  END
	      			   as `M1`

	      
	    	   FROM `R` 
	    	   INNER JOIN `F` 
	    	   ON `R`.`user_id` = `F`.`user_id`
	    	   INNER JOIN `M`
	    	   ON `F`.`user_id` = `M`.`user_id`),

	  `USERGROUPS` AS (SELECT `RF`.`user_id`,
	  						  `RF`.`R`,
	      					  `RF`.`F`,
	      					  CONCAT('R', `RF`.`R1`,'-', 'F', `RF`.`F1`, '-', 'M', `RF`.`M1`) `RF`,
	      					  CASE  
	            			  WHEN  CONCAT(`RF`.`R1`,`RF`.`F1`, `RF`.`M1`) 
	            			  	IN ("555", "455", "355", "345", "354", "445", "245", "255", "325", "335") 
	            			  	THEN 'VIP' 
	      
	            			  WHEN  CONCAT(`RF`.`R1`,`RF`.`F1`, `RF`.`M1`) 
	            			  	IN ("443", "441", "442", "444", "333", "341", "342", "343", "344", "321", "322", "323", "324", "334") 
	            			  	THEN 'REGULAR' 

	            		      WHEN CONCAT(`RF`.`R1`, `RF`.`F1`, `RF`.`M1`)
	            		      	IN ("221", "222", "223", "224", "115",  "225", "231", "232", "233", "234", "235", "241", "242", "243", "244", "251", "252", "253", "254", "311", "312", "313", "314", "315",  "124", "125", "211", "212")
	            		      	THEN "HOPEFOOL"

	            			  WHEN CONCAT(`RF`.`R1`,`RF`.`F1`, `RF`.`M1`) 
	            			  	NOT IN ("111", "112", "113", "114", "121", "122", "123") 
	            			  	THEN 'LOST'

	            			  ELSE 'undefined_group' 

	      				      END as `G`
	    			   FROM `RF`)
  
	  SELECT `u`.`G` `group`,
	  		 `u`.`user_id` `user_id`, 
	  		 `u`.`RF` `index`,
	  		 `R`.`days` `days`, 
	  		 `F`.`cnt` `orders`,
	  		 `m`.`sum_price` `sum`

	  FROM `USERGROUPS` `u` LEFT JOIN `M` `m` 
	  ON `u`.`user_id` = `m`.`user_id` left join `R` ON `R`.`user_id` = `m`.`user_id`
	  LEFT JOIN `F` ON `F`.`user_id` = `R`.`user_id`;

