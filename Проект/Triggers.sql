
DROP PROCEDURE IF EXISTS stock_balances_update;
delimiter //
CREATE PROCEDURE stock_balances_update(IN warehouse_id_ int, IN nomenclature_id_ int, IN series_id_ int, IN count_move_ float,IN document_type_id int)
begin
	SET @direction = IF(
				(SELECT direction from document_types WHERE id = document_type_id),
				1,-1);
	SET @count_move = (SELECT t.count_move FROM (SELECT SUM(count_move) as count_move FROM stock_balances 
		WHERE warehouse_id = warehouse_id_ 
			AND nomenclature_id = nomenclature_id_ 
			AND (series_id_ is null AND series_id IS NULL 
				OR series_id = series_id_)) as t);
	CASE
    WHEN @count_move IS NULL THEN 
		begin
			Insert into stock_balances(warehouse_id, nomenclature_id, series_id,count_move) VALUES 
				(warehouse_id_,
				nomenclature_id_,
				series_id_, 
				@direction * count_move_);
		end;
    ELSE 
		begin
			UPDATE stock_balances SET
				count_move = @count_move
				 			 + @direction * count_move_
			WHERE
				warehouse_id = warehouse_id_ AND 
				nomenclature_id = nomenclature_id_ AND 
				(series_id IS NULL AND series_id_ IS NULL 
				OR series_id = series_id_);
		end;
	END Case;
end;
 //
delimiter ;


DROP PROCEDURE IF EXISTS operations_line_num_update;
delimiter //
CREATE PROCEDURE operations_line_num_update()
begin
	DROP Table IF EXISTS operations_line_num;
	CREATE TEMPORARY TABLE operations_line_num
		SELECT wind.nn,wind.id
		From (SELECT ROW_NUMBER () Over (PARTITION BY operations.document_id ORDER BY operations.id) as nn, operations.id FROM operations) AS wind;
	SET @maxnn = (SELECT max(line_num) from operations);
	Update operations set line_num = @maxnn + (SELECT o.nn from operations_line_num o WHERE o.id = operations.id);			
	Update operations set line_num = (SELECT o.nn from operations_line_num o WHERE o.id = operations.id);			
end;
 //
delimiter ;


DROP TRIGGER IF EXISTS operations_insert_After;
delimiter //
CREATE TRIGGER operations_insert_After After INSERT ON operations
FOR EACH ROW
begin
	call stock_balances_update(NEW.warehouse_id,NEW.nomenclature_id,NEW.series_id,NEW.count_move,NEW.document_type_id);
END; //
delimiter ;

DROP TRIGGER IF EXISTS operations_update_After;
delimiter //
CREATE TRIGGER operations_update_After After Update ON operations
FOR EACH ROW
begin
	call stock_balances_update(OLD.warehouse_id,OLD.nomenclature_id,OLD.series_id,-OLD.count_move,OLD.document_type_id);
	call stock_balances_update(NEW.warehouse_id,NEW.nomenclature_id,NEW.series_id,NEW.count_move,NEW.document_type_id);
END; //
delimiter ;


DROP TRIGGER IF EXISTS operations_insert_BEFORE;
delimiter //
CREATE TRIGGER operations_insert_BEFORE BEFORE insert ON operations
FOR EACH ROW
BEGIN 
	SET @nomenclature_type_id = (SELECT nomenclature_type_id from nomenclature WHERE nomenclature.id = new.nomenclature_id);
	IF NOT(SELECT use_series FROM nomenclature_types WHERE id = @nomenclature_type_id) THEN 
		SET new.series_id = NULL;
	ELSEIF new.series_id IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in serie';
	ELSEIF NOT(SELECT nomenclature_type_id = @nomenclature_type_id FROM series WHERE id = new.series_id) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'serie is not correct';
	END IF;
END; //
delimiter ;

DROP TRIGGER IF EXISTS operations_update_BEFORE;
delimiter //
CREATE TRIGGER operations_update_BEFORE BEFORE UPDATE ON operations
FOR EACH ROW
BEGIN 
	SET @nomenclature_type_id = (SELECT nomenclature_type_id from nomenclature WHERE nomenclature.id = new.nomenclature_id);
	IF NOT(SELECT use_series FROM nomenclature_types WHERE id = @nomenclature_type_id) THEN 
		SET new.series_id = NULL;
	ELSEIF new.series_id IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in serie';
	ELSEIF NOT(SELECT nomenclature_type_id = @nomenclature_type_id FROM series WHERE id = new.series_id) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'serie is not correct';
	END IF;
END; //
delimiter ;

DROP TRIGGER IF EXISTS operations_delete;
delimiter //
CREATE TRIGGER operations_delete After DELETE ON operations
FOR EACH ROW
	call stock_balances_update(OLD.warehouse_id,OLD.nomenclature_id,OLD.series_id,-OLD.count_move,OLD.document_type_id)
delimiter ;

DROP TRIGGER IF EXISTS counterparties_insert;
delimiter //
CREATE TRIGGER counterparties_insert BEFORE insert ON counterparties
FOR EACH ROW
BEGIN 
	IF New.entity = TRUE AND New.INN IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in TIN';		
	ELSEIF New.entity = FALSE AND New.passport IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in passport';		
	END IF;
	Case 
	WHEN New.entity = TRUE THEN 
		set New.passport = NULL;
	ELSE 
		BEGIN 
			set New.INN = NULL;
			set New.KPP = NULL;
			set New.OKPO = NULL;
		END;
	END Case;
END; //
delimiter ;

DROP TRIGGER IF EXISTS counterparties_update;
delimiter //
CREATE TRIGGER counterparties_update BEFORE update ON counterparties
FOR EACH ROW
BEGIN 
	IF New.entity = TRUE AND New.INN IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in TIN';		
	ELSEIF New.entity = FALSE AND New.passport IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in passport';		
	END IF;
	Case 
	WHEN New.entity = TRUE THEN 
		set New.passport = NULL;
	ELSE 
		BEGIN 
			set New.INN = NULL;
			set New.KPP = NULL;
			set New.OKPO = NULL;
		END;
	END Case;
END; //
delimiter ;

DROP TRIGGER IF EXISTS nomenclature_insert;
delimiter //
CREATE TRIGGER nomenclature_insert BEFORE insert ON nomenclature
FOR EACH ROW
BEGIN 
	IF NOT(SELECT use_code FROM nomenclature_types WHERE id = New.nomenclature_type_id) THEN set New.code = NULL; 
	ELSEIF New.code IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in code'; END IF;
	IF NOT(SELECT use_weight FROM nomenclature_types WHERE id = New.nomenclature_type_id) THEN set New.weight = NULL;
	ELSEIF New.weight IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in weight'; END IF;
	IF NOT(SELECT use_volume FROM nomenclature_types WHERE id = New.nomenclature_type_id) THEN set New.volume = NULL;
	ELSEIF New.volume IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in volume'; END IF;
END; //
delimiter ;

DROP TRIGGER IF EXISTS nomenclature_update;
delimiter //
CREATE TRIGGER nomenclature_update BEFORE UPDATE ON nomenclature
FOR EACH ROW
BEGIN 
	IF NOT(SELECT use_code FROM nomenclature_types WHERE id = New.nomenclature_type_id) THEN set New.code = NULL; 
	ELSEIF New.code IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in code'; END IF;
	IF NOT(SELECT use_weight FROM nomenclature_types WHERE id = New.nomenclature_type_id) THEN set New.weight = NULL;
	ELSEIF New.weight IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in weight'; END IF;
	IF NOT(SELECT use_volume FROM nomenclature_types WHERE id = New.nomenclature_type_id) THEN set New.volume = NULL;
	ELSEIF New.volume IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fill in volume'; END IF;
END; //
delimiter ;

DROP TRIGGER IF EXISTS series_insert;
delimiter //
CREATE TRIGGER series_insert BEFORE insert ON series
FOR EACH ROW
BEGIN 
	IF NOT(SELECT use_series FROM nomenclature_types WHERE id = New.nomenclature_type_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'series off'; END IF;
END; //
delimiter ;

DROP TRIGGER IF EXISTS series_update;
delimiter //
CREATE TRIGGER series_update BEFORE UPDATE ON series
FOR EACH ROW
BEGIN 
	IF NOT(SELECT use_series FROM nomenclature_types WHERE id = New.nomenclature_type_id) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'series off'; END IF;
END; //
delimiter ;








	