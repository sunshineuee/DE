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
