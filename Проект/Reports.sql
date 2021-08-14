
-- CREATE OR REPLACE VIEW divergence_of_stock_balances AS
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


-- CREATE OR REPLACE VIEW last_user_of_nomenclature_type AS
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

				