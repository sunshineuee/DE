
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

   
CREATE TABLE stock_balances(
  warehouse_id INT UNSIGNED NOT NULL COMMENT "Склад",
  nomenclature_id INT UNSIGNED NOT NULL COMMENT "Номенклатура",
  series_id INT UNSIGNED COMMENT "Серия",
  count_move FLOAT COMMENT "Количество",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки",
  UNIQUE(warehouse_id,nomenclature_id,series_id)
) COMMENT "Текущие статки на складах";
	