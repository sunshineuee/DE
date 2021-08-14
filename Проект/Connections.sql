ALTER TABLE counterparties
  ADD CONSTRAINT counterparties_country_id_fk 
    FOREIGN KEY (country_id) REFERENCES countries(id);

ALTER TABLE nomenclature
  ADD CONSTRAINT nomenclature_nomenclature_type_id_fk 
    FOREIGN KEY (nomenclature_type_id) REFERENCES nomenclature_types(id),
  ADD CONSTRAINT nomenclature_country_id_fk 
    FOREIGN KEY (country_id) REFERENCES countries(id),
  ADD CONSTRAINT nomenclature_supplier_id_fk 
    FOREIGN KEY (supplier_id) REFERENCES counterparties(id);

ALTER TABLE series
  ADD CONSTRAINT series_nomenclature_type_id_fk 
    FOREIGN KEY (nomenclature_type_id) REFERENCES nomenclature_types(id),
  ADD CONSTRAINT series_supplier_id_fk 
    FOREIGN KEY (supplier_id) REFERENCES counterparties(id);

   ALTER TABLE documents
  ADD CONSTRAINT documents_document_type_id_fk 
    FOREIGN KEY (document_type_id) REFERENCES document_types(id),
  ADD CONSTRAINT documents_counterparty_id_fk 
    FOREIGN KEY (counterparty_id) REFERENCES counterparties(id),
  ADD CONSTRAINT documents_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT documents_warehouse_id_fk 
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id);

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

ALTER TABLE stock_balances
  ADD CONSTRAINT stock_balances_warehouse_id_fk 
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
  ADD CONSTRAINT stock_balances_nomenclature_id_fk 
    FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id),
  ADD CONSTRAINT stock_balances_series_id_fk 
    FOREIGN KEY (series_id) REFERENCES series(id);

