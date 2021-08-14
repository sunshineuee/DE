DROP DATABASE IF EXISTS warehouse;
CREATE DATABASE warehouse;
USE warehouse;

CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор", 
  first_name VARCHAR(100) NOT NULL COMMENT "Имя пользователя",
  last_name VARCHAR(100) NOT NULL COMMENT "Фамилия пользователя",
  email VARCHAR(100) UNIQUE COMMENT "Почта",
  phone VARCHAR(100) UNIQUE COMMENT "Телефон",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Пользователи";  


CREATE TABLE nomenclature_types(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор", 
  name VARCHAR(100) NOT NULL COMMENT "Наименование",
  use_code BOOLEAN NOT NULL COMMENT "Артикул обязателен",  
  use_weight BOOLEAN NOT NULL COMMENT "Вес обязателен",  
  use_volume BOOLEAN NOT NULL COMMENT "Объем обязателен",  
  use_series BOOLEAN NOT NULL COMMENT "Использовать серии",  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Типы номенклатуры";  


CREATE TABLE countries (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор",
  name VARCHAR(150) NOT NULL COMMENT "Наименование"
) COMMENT "Страны";


CREATE TABLE counterparties(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор", 
  name VARCHAR(100) NOT NULL COMMENT "Наименование",
  entity BOOLEAN NOT NULL COMMENT "Юридическое лицо",
  INN VARCHAR(12) COMMENT "ИНН",  
  KPP VARCHAR(9) COMMENT "КПП",  
  OKPO VARCHAR(10) COMMENT "ОКПО",
  passport VARCHAR(10) COMMENT "Серия и номер паспорта",
  country_id INT UNSIGNED,  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Контрагенты";  
ALTER TABLE counterparties
  ADD CONSTRAINT counterparties_country_id_fk 
    FOREIGN KEY (country_id) REFERENCES countries(id);

   
CREATE TABLE nomenclature (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор", 
  name VARCHAR(100) NOT NULL COMMENT "Наименование",
  nomenclature_type_id INT UNSIGNED NOT NULL COMMENT "Тип номенклатуры",
  code VARCHAR(32) COMMENT "Артикул",  
  weight FLOAT COMMENT "Вес",
  volume FLOAT COMMENT "Объем",
  supplier_id INT UNSIGNED COMMENT "Поставщик",
  country_id INT UNSIGNED,  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Номенклатура";  
ALTER TABLE nomenclature
  ADD CONSTRAINT nomenclature_nomenclature_type_id_fk 
    FOREIGN KEY (nomenclature_type_id) REFERENCES nomenclature_types(id),
  ADD CONSTRAINT nomenclature_country_id_fk 
    FOREIGN KEY (country_id) REFERENCES countries(id),
  ADD CONSTRAINT nomenclature_supplier_id_fk 
    FOREIGN KEY (supplier_id) REFERENCES counterparties(id);


CREATE TABLE series(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор", 
  name VARCHAR(100) NOT NULL COMMENT "Название",
  nomenclature_type_id INT UNSIGNED NOT NULL COMMENT "Тип номенклатуры",
  number_seria VARCHAR(100) COMMENT "Серийный номер",
  fit_to DATETIME COMMENT "Годен до",
  production_date DATETIME COMMENT "Дата производства",
  supplier_id INT UNSIGNED COMMENT "Поставщик",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  UNIQUE(nomenclature_type_id,number_seria)
) COMMENT "Серии";  
-- как бы мне сделать уникальность в рамках двух реквизитов: типа номенклатуры и номера серии...;
ALTER TABLE series
  ADD CONSTRAINT series_nomenclature_type_id_fk 
    FOREIGN KEY (nomenclature_type_id) REFERENCES nomenclature_types(id),
  ADD CONSTRAINT series_supplier_id_fk 
    FOREIGN KEY (supplier_id) REFERENCES counterparties(id);

   
CREATE TABLE warehouses(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор",
  name VARCHAR(150) NOT NULL COMMENT "Наименование",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Склады";


CREATE TABLE document_types(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор",
  name VARCHAR(150) NOT NULL COMMENT "Наименование",
  direction BOOLEAN NOT NULL COMMENT "Приход/расход",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Типы документов";


CREATE TABLE documents (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
  date_document DATETIME NOT NULL COMMENT "Дата документа",
  num_document VARCHAR(32) NOT NULL COMMENT "Номер докмента",
  document_type_id INT UNSIGNED NOT NULL COMMENT "Тип документа",
  counterparty_id INT UNSIGNED COMMENT "Контрагент",
  user_id INT UNSIGNED COMMENT "Менеджер",
  warehouse_id INT UNSIGNED NOT NULL COMMENT "Склад",
  filename VARCHAR(255) NOT NULL COMMENT "Путь к файлу",
  size INT NOT NULL COMMENT "Размер файла",
  metadata JSON COMMENT "Метаданные файла",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Документы";
ALTER TABLE documents
  ADD CONSTRAINT documents_document_type_id_fk 
    FOREIGN KEY (document_type_id) REFERENCES document_types(id),
  ADD CONSTRAINT documents_counterparty_id_fk 
    FOREIGN KEY (counterparty_id) REFERENCES counterparties(id),
  ADD CONSTRAINT documents_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT documents_warehouse_id_fk 
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id);

   
CREATE TABLE operations(
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор",
  document_id INT UNSIGNED NOT NULL COMMENT "Складской документ",
  document_type_id INT UNSIGNED NOT NULL COMMENT "Тип документа",
  line_num INT UNSIGNED NOT NULL COMMENT "Номер строки",
  counterparty_id INT UNSIGNED COMMENT "Контрагент",
  user_id INT UNSIGNED COMMENT "Менеджер",
  warehouse_id INT UNSIGNED NOT NULL COMMENT "Склад",
  nomenclature_id INT UNSIGNED NOT NULL COMMENT "Номенклатура",
  series_id INT UNSIGNED COMMENT "Серия",
  count_move FLOAT COMMENT "Количество",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  UNIQUE(document_id,line_num)
) COMMENT "Складские операции";
-- Данные Документов и Складских оперций частично дублируются умышленно, потому что 
-- Документы это больше реестр для поиска и хренения перцички, 
-- а Складские операции аналитический регистр как для хранения детальной информации по документу так и расчетов оборотов по складу
-- ввод и редактирование данных 
ALTER TABLE operations
  ADD CONSTRAINT operations_document_id_fk 
    FOREIGN KEY (document_id) REFERENCES documents(id),
  ADD CONSTRAINT operations_document_type_id_fk 
    FOREIGN KEY (document_type_id) REFERENCES document_types(id),
  ADD CONSTRAINT operations_user_counterparty_id_fk 
    FOREIGN KEY (counterparty_id) REFERENCES counterparties(id),  
  ADD CONSTRAINT operations_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),  
  ADD CONSTRAINT operations_warehouse_id_fk 
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),  
  ADD CONSTRAINT operations_nomenclature_id_fk 
    FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id),  
  ADD CONSTRAINT operations_series_id_fk 
    FOREIGN KEY (series_id) REFERENCES series(id);

   
CREATE TABLE stock_balances(
  warehouse_id INT UNSIGNED NOT NULL COMMENT "Склад",
  nomenclature_id INT UNSIGNED NOT NULL COMMENT "Номенклатура",
  series_id INT UNSIGNED COMMENT "Серия",
  count_move FLOAT COMMENT "Количество",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  UNIQUE(warehouse_id,nomenclature_id,series_id)
) COMMENT "Текущие статки на складах";
ALTER TABLE stock_balances
  ADD CONSTRAINT stock_balances_warehouse_id_fk 
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
  ADD CONSTRAINT stock_balances_nomenclature_id_fk 
    FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id),
  ADD CONSTRAINT stock_balances_series_id_fk 
    FOREIGN KEY (series_id) REFERENCES series(id);
   


CREATE OR REPLACE VIEW divergence_of_stock_balances AS
SELECT  operations.warehouse_id,operations.nomenclature_id,operations.series_id, stock_balances.count_move, 
	sum(operations.count_move * if((SELECT document_types.direction from document_types WHERE document_types.id = operations.document_type_id),1,-1)) as 'sum'
FROM 
	operations left join stock_balances on
	 operations.warehouse_id = stock_balances.warehouse_id 
	 AND operations.nomenclature_id = stock_balances.nomenclature_id 
	 AND (operations.series_id = stock_balances.series_id 
	 	OR (operations.series_id IS NULL AND  stock_balances.series_id IS NULL)
	 	)
group by operations.warehouse_id,operations.nomenclature_id,operations.series_id,stock_balances.count_move
HAVING 
	sum(operations.count_move * if((SELECT document_types.direction from document_types WHERE document_types.id = operations.document_type_id),1,-1))
		<> stock_balances.count_move
order by operations.warehouse_id,operations.nomenclature_id,operations.series_id
;


CREATE OR REPLACE VIEW last_user_of_nomenclature_type AS
SELECT DISTINCT 
	nomenclature.nomenclature_type_id,
	FIRST_VALUE(operations.user_id) OVER(PARTITION BY nomenclature.nomenclature_type_id Order BY documents.date_document DESC) as last_user
FROM operations left join nomenclature on operations.nomenclature_id = nomenclature.id 
				left join documents    on operations.document_id = documents.id 
WHERE nomenclature.nomenclature_type_id IN (SELECT 
	Nom_direction.nomenclature_type_id
FROM (SELECT 	DISTINCT
	Nom_direction.nomenclature_type_id,
	FIRST_VALUE(Nom_direction.direction) OVER (PARTITION BY Nom_direction.nomenclature_type_id Order BY Nom_direction.sum_ DESC) as pop_direction
FROM (SELECT  DISTINCT 
	nomenclature.nomenclature_type_id,
	document_types.direction,
	SUM(operations.count_move) OVER(PARTITION BY nomenclature.nomenclature_type_id,document_types.direction) as sum_
FROM operations left join nomenclature on operations.nomenclature_id = nomenclature.id 
				left JOIN document_types on operations.document_type_id = document_types.id	) AS Nom_direction)	AS Nom_direction
WHERE Nom_direction.pop_direction = 1)
;

				
  	

CREATE INDEX counterparties_entity_idx ON counterparties(entity);
CREATE INDEX counterparties_INN_idx ON counterparties(INN);
CREATE INDEX counterparties_passport_idx ON counterparties(passport);
CREATE INDEX counterparties_updated_at_idx ON counterparties(updated_at); 

CREATE INDEX documents_num_document_idx ON documents(num_document); 
CREATE INDEX documents_updated_at_idx ON documents(updated_at); 

CREATE INDEX nomenclature_code_idx ON nomenclature(code); 
CREATE INDEX nomenclature_updated_at_idx ON nomenclature(updated_at); 

CREATE INDEX operations_document_id_idx ON operations(document_id); 

CREATE INDEX series_number_seria_idx ON series(number_seria); 
CREATE INDEX series_nomenclature_type_id_idx ON series(nomenclature_type_id); 
CREATE INDEX series_updated_at_idx ON series(updated_at); 


DROP PROCEDURE IF EXISTS stock_balances_update;


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








	