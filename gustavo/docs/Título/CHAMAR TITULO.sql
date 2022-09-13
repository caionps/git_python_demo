--set SERVEROUTPUT on
DECLARE
  P_ID_TITULO NUMBER;
  P_BATCH_SOURCE_REC CA.PK_GVS_TITULO_EBS_PLT.BATCH_SOURCE_REC;
  P_TRX_HEADER_REC CA.PK_GVS_TITULO_EBS_PLT.TRX_HEADER_REC;
  P_TRX_LINE_REC CA.PK_GVS_TITULO_EBS_PLT.TRX_LINE_REC;
  P_FG_RETORNO VARCHAR2(200);
  P_DS_RETORNO VARCHAR2(200);
BEGIN
  P_ID_TITULO := 1541407;
  -- Modify the code to initialize the variable
  -- P_BATCH_SOURCE_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_TRX_HEADER_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_TRX_LINE_REC := NULL;

  PK_GVS_TITULO_EBS_CLC.P_INTEGRA_TITULO_EBS(
    P_ID_TITULO => P_ID_TITULO,
    P_BATCH_SOURCE_REC => P_BATCH_SOURCE_REC,
    P_TRX_HEADER_REC => P_TRX_HEADER_REC,
    P_TRX_LINE_REC => P_TRX_LINE_REC,
    P_FG_RETORNO => P_FG_RETORNO,
    P_DS_RETORNO => P_DS_RETORNO
  );
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('P_BATCH_SOURCE_REC = ' || P_BATCH_SOURCE_REC);
*/ 
  --:P_BATCH_SOURCE_REC := P_BATCH_SOURCE_REC;
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('P_TRX_HEADER_REC = ' || P_TRX_HEADER_REC);
*/ 
  --:P_TRX_HEADER_REC := P_TRX_HEADER_REC;
  DBMS_OUTPUT.PUT_LINE('---------    P_TRX_HEADER_REC    ----------');
  DBMS_OUTPUT.PUT_LINE('trx_number = ' || P_TRX_HEADER_REC.trx_number	               );
  DBMS_OUTPUT.PUT_LINE('trx_date = ' || P_TRX_HEADER_REC.trx_date                  );
  DBMS_OUTPUT.PUT_LINE('gl_date = ' || P_TRX_HEADER_REC.gl_date                   );    
  DBMS_OUTPUT.PUT_LINE('trx_currency = ' || P_TRX_HEADER_REC.trx_currency              );
  DBMS_OUTPUT.PUT_LINE('cust_trx_type_name = ' || P_TRX_HEADER_REC.cust_trx_type_name          );
  DBMS_OUTPUT.PUT_LINE('bill_to_customer_ref = ' || P_TRX_HEADER_REC.bill_to_customer_ref        );
  DBMS_OUTPUT.PUT_LINE('bill_to_address_ref = ' || P_TRX_HEADER_REC.bill_to_address_ref         );
  DBMS_OUTPUT.PUT_LINE('ship_to_customer_ref = ' || P_TRX_HEADER_REC.ship_to_customer_ref        );
  DBMS_OUTPUT.PUT_LINE('ship_to_address_ref = ' || P_TRX_HEADER_REC.ship_to_address_ref         );
  DBMS_OUTPUT.PUT_LINE('term_name = ' || P_TRX_HEADER_REC.term_name                   );
  DBMS_OUTPUT.PUT_LINE('primary_salesrep_id = ' || P_TRX_HEADER_REC.primary_salesrep_id         );
  DBMS_OUTPUT.PUT_LINE('receipt_method_name = ' || P_TRX_HEADER_REC.receipt_method_name         );
  DBMS_OUTPUT.PUT_LINE('attribute_category = ' || P_TRX_HEADER_REC.attribute_category          );
  DBMS_OUTPUT.PUT_LINE('attribute1 = ' || P_TRX_HEADER_REC.attribute1                  );
  DBMS_OUTPUT.PUT_LINE('attribute2 = ' || P_TRX_HEADER_REC.attribute2                  );
  DBMS_OUTPUT.PUT_LINE('attribute3 = ' || P_TRX_HEADER_REC.attribute3                  );
  DBMS_OUTPUT.PUT_LINE('attribute4 = ' || P_TRX_HEADER_REC.attribute4                  );
  DBMS_OUTPUT.PUT_LINE('attribute5 = ' || P_TRX_HEADER_REC.attribute5                  );
  DBMS_OUTPUT.PUT_LINE('attribute6 = ' || P_TRX_HEADER_REC.attribute6                  );
  DBMS_OUTPUT.PUT_LINE('attribute7 = ' || P_TRX_HEADER_REC.attribute7                  );
  DBMS_OUTPUT.PUT_LINE('attribute8 = ' || P_TRX_HEADER_REC.attribute8                  );
  DBMS_OUTPUT.PUT_LINE('attribute9 = ' || P_TRX_HEADER_REC.attribute9                  );
  DBMS_OUTPUT.PUT_LINE('attribute10 = ' || P_TRX_HEADER_REC.attribute10                 );
  DBMS_OUTPUT.PUT_LINE('global_attribute_category = ' || P_TRX_HEADER_REC.global_attribute_category   );
  DBMS_OUTPUT.PUT_LINE('header_gdf_attribute1 = ' || P_TRX_HEADER_REC.header_gdf_attribute1       );   
  DBMS_OUTPUT.PUT_LINE('header_gdf_attribute2 = ' || P_TRX_HEADER_REC.header_gdf_attribute2       ); 
  DBMS_OUTPUT.PUT_LINE('header_gdf_attribute3 = ' || P_TRX_HEADER_REC.header_gdf_attribute3       ); 
  DBMS_OUTPUT.PUT_LINE('header_gdf_attribute4 = ' || P_TRX_HEADER_REC.header_gdf_attribute4       );
  DBMS_OUTPUT.PUT_LINE('header_gdf_attribute5 = ' || P_TRX_HEADER_REC.header_gdf_attribute5       );         
  DBMS_OUTPUT.PUT_LINE('interface_header_context = ' || P_TRX_HEADER_REC.interface_header_context    );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute1 = ' || P_TRX_HEADER_REC.interface_header_attribute1 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute2 = ' || P_TRX_HEADER_REC.interface_header_attribute2 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute3 = ' || P_TRX_HEADER_REC.interface_header_attribute3 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute4 = ' || P_TRX_HEADER_REC.interface_header_attribute4 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute5 = ' || P_TRX_HEADER_REC.interface_header_attribute5 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute6 = ' || P_TRX_HEADER_REC.interface_header_attribute6 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute7 = ' || P_TRX_HEADER_REC.interface_header_attribute7 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute8 = ' || P_TRX_HEADER_REC.interface_header_attribute8 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute9 = ' || P_TRX_HEADER_REC.interface_header_attribute9 );
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute10 = ' || P_TRX_HEADER_REC.interface_header_attribute10);
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute11 = ' || P_TRX_HEADER_REC.interface_header_attribute11);
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute12 = ' || P_TRX_HEADER_REC.interface_header_attribute12);
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute13 = ' || P_TRX_HEADER_REC.interface_header_attribute13);
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute14 = ' || P_TRX_HEADER_REC.interface_header_attribute14);
  DBMS_OUTPUT.PUT_LINE('interface_header_attribute15 = ' || P_TRX_HEADER_REC.interface_header_attribute15);
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('P_TRX_LINE_REC = ' || P_TRX_LINE_REC);
*/ 
  --:P_TRX_LINE_REC := P_TRX_LINE_REC;
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('P_FG_RETORNO = ' || P_FG_RETORNO);
*/ 
 -- :P_FG_RETORNO := P_FG_RETORNO;
  /* Legacy output: 
DBMS_OUTPUT.PUT_LINE('P_DS_RETORNO = ' || P_DS_RETORNO);
*/ 
 --:P_DS_RETORNO := P_DS_RETORNO;
--rollback; 
END;
