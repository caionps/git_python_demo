--P_BATCH_SOURCE_REC 
--batch_source_name
SELECT RBSA.NAME "NAME"
FROM RA_BATCH_SOURCES_ALL@ebsunifor RBSA
WHERE RBSA.CREATED_BY <> '-1'
AND RBSA.STATUS = 'A'
AND RBSA.BATCH_SOURCE_TYPE = 'FOREIGN'
;

--TRX_HEADER_REC_TYPE 
-- cust_trx_type_name
SELECT RCTA.NAME
FROM RA_CUST_TRX_TYPES_ALL@ebsunifor RCTA
WHERE RCTA.CREATED_BY <> -1
AND END_DATE IS NULL;

-- term_name
SELECT RT.NAME
FROM APPS.RA_TERMS RT
WHERE CREATED_BY <> -1
AND END_DATE_ACTIVE IS NULL;


-- receipt_method_name
SELECT ARM.NAME 
FROM AR_RECEIPT_METHODS@ebsunifor ARM
WHERE ARM.CREATED_BY <> 1
AND ARM.END_DATE IS NULL;


PARA LINHAS DO TIPO “LINE”:


--TRX_LINE_REC_TYPE 
--description
SELECT AMLT.NAME
FROM APPS.AR_MEMO_LINES_ALL_TL@ebsunifor AMLT
WHERE AMLT.LANGUAGE = 'PTB'
AND AMLT.CREATED_BY <> -1;

--PARA LINHA DO TIPO “TAX”:

SELECT TAX_CODE
FROM APPS.AR_VAT_TAX_ALL_B@ebsunifor
WHERE END_DATE IS NULL;



--cria tabela de controle uso api
/*
informação              Tipo        Descrição
x_customer_trx_id       VARCHAR2    Nome da API
x_customer_trx_id       NUMBER      Retorna customer_trx_id caso seja chamado para criar uma única fatura. Este parâmetro funciona apenas com o procedimento CREATE_SINGLE_INVOICE.
x_return_status         VARCHAR2    API status.
x_message_data          VARCHAR2    Mensagem caso a API encontre um erro inesperado.
DT_REGISTRO             DATE        Data do retorno / envio

*/
