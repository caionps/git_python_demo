create or replace view VW_GVS_TRX_LINE
as
select
 --null   as trx_header_id               			-- number    yes   	identificador para o registro do cabe�alho da fatura. isso deve ser exclusivo para cada registro. #Pode ser um sequencial unico qualquer?
--,null   as trx_line_id                 			-- number    yes   	identificador das linhas da transa��o. #Qual identificar � esse?
--,null   as link_to_trx_line_id         			-- number          	esta coluna � necess�ria apenas se o tipo de linha for tax e freight (se estiver associado a qualquer linha). para as linhas do tipo tax, informar o trx_line_id da linha do tipo line.
 rownum   as line_number                 			-- number    yes   	sequencial do n�mero da linha da invoice. #COnsultar EBS?
,'descri��o da linha da transa��o'   as description                 			-- varchar2 (240)  	descri��o da linha da transa��o, validado de acordo com o campo name.ar_memo_lines_all_tl. #verificar. Acredito que ter� as formas de composi��o do titulo que deveremos consultar.
,1      as quantity_ordered            			-- number          	fixo: 1
,1      as quantity_invoiced           			-- number          	fixo: 1 
,t.vl_original   as unit_standard_price			-- number          	valor unit�rio do item, com duas casas decimais.
,t.vl_original   as unit_selling_price 			-- number          	valor unit�rio do item, com duas casas decimais.
,'line' as line_type                   			-- varchar2(20)    	yes informar:line, para linhas de itens. tax, para linhas de impostos.
,null as attribute_category            			-- varchar2(30)    	descriptive flexfield structure definition column. #O que se trata este campo? Temos alguns exemplos?
,null as attribute1                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute2                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute3                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute4                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute5                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute6                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute7                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute8                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute9                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute10                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute11                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute12                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute13                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute14                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,null as attribute15                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,'UOL ND' as interface_line_context    			-- varchar2(30)    	de acordo com as regras definidas para primary keys.
--,null as interface_line_attribute1_15 		-- varchar2(30)    	de acordo com a regra 1#, descrita ao final da tabela.
,'065_UNF'      as INTERFACE_LINE_ATTRIBUTE1 	--                  C�digo da empresa concatenado com Descri��o: EXEMPLO: 065_UNF	
,'100_UNF'      as INTERFACE_LINE_ATTRIBUTE2 	--                  C�digo da filial concatenado com _Descri��o: EXEMPLO: 100_UNF	
,t.id_titulo    as INTERFACE_LINE_ATTRIBUTE3 	--                  N�mero da Nota Fiscal � FATURA/DUPLICATA, N�mero da Nota de D�bito (Para ND) ou Cr�dito (Para NC) e N�mero do Banco (Para Cheque Pr�-datado ou Devolvido).	
,'X'            as INTERFACE_LINE_ATTRIBUTE4 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE5 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE6 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE7 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE8 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE9 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE10 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE11 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE12 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE13 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE14 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,'X'            as INTERFACE_LINE_ATTRIBUTE15 	--                  Subs�rie da NF para Fatura/Duplicata,Tipo (Para Nota de D�bito ou Cr�dito), N�mero da Ag�ncia (Para Cheque Devolvido ou Pr�-datado). Caso o campo for NULO, enviar o valor �X�.
,t.vl_original as amount              			-- number           valor da linha.
,decode('tipo_transacao','TAX','txaImposto',null) as tax_rate    -- number           taxa de imposto. obrigat�rio para a linha tax.
--,null as memo_line_id                 		-- number           identificador do item de linha. preencher apenas para linhas do tipo  line. #verificar no EBS
,'UN' as uom_code                     			-- varchar2(3)      unidade de medida. #Quais as unidades disponiveis? 'UN'
--,null as vat_tax_id                   		-- number           identificador do c�digo de imposto (ar_vat_tax). obrigat�rio para linhas do tipo tax.
,decode('tipo_transacao','TAX','Y',null) as tax_exempt_flag  	-- varchar2(1)      fixo: y para linhas do tipo tax. nulo para linhas do do tipo line.
--,null as global_attribute1_20_20    			-- varchar2 (150)   preencher de acordo com a regra 2#, descrita no final da tabela.
,'5949' as LINE_GDF_ATTRIBUTE1        			-- 					CFOP da nota fiscal. Para os demais tipos de transa��o informar o CFOP 5949.
,'00000000' as LINE_GDF_ATTRIBUTE2 				--					C�digo da Classifica��o Fiscal do Item da nota fiscal. Para os demais tipos de transa��o, diferentes de NFF, informa Fixo: �00000000�.
,'FABRICACAO PROPRIA' as LINE_GDF_ATTRIBUTE3 	--					CLASSE DE CONDICAO DA TRANSACAO (Utiliza��o da Mercadoria). Informar a classe da condi��o da transa��o das NFFs. Para os demais tipos de transa��o informar fixo: FABRICACAO PROPRIA;
,'0'  as LINE_GDF_ATTRIBUTE4  					-- 					ORIGEM DO ITEM: 0=NACIONAL OU 1=IMPORTADO 2=IMPORTADO ADQ. NO MERCADO INTERNO.
,'B'  as LINE_GDF_ATTRIBUTE5  					-- 					TIPO FISCAL DO ITEM. Fixo: B.
,'00' as LINE_GDF_ATTRIBUTE6                    -- 					SITUACAO TRIBUT�RIA FEDERAL. Situa��o Tribut�ria Federal da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �00�.
,'0' as LINE_GDF_ATTRIBUTE7                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE8                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE9                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE10                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE11                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE12                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE13                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE14                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE15                    -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE16                    -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE17                    -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE18                    -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE19                    -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'0' as LINE_GDF_ATTRIBUTE20                     -- 					SITUACAO TRIBUT�RIA ESTADUAL. Situa��o Tribut�ria Estadual da NFF. Para os demais tipos de transa��o diferentes de NFF, informar fixo: �0�.
,'jl.br.arxtwmai.additional info' as global_attribute_category    -- varchar2(30)     fixo: jl.br.arxtwmai.additional info
,decode('tipo_transacao','TAX_inclusivo','Y',null) as amount_includes_tax_flag -- varchar2(1)      informar y para impostos inclusivos, nas linhas do tipo tax. para as demais linhas deixar nulo.
,123  as warehouse_id                 			-- number           fixo: 123
,t.id_titulo

from 
    ca.ctr_titulo t	
    
--SELECT AMLT.NAME
--FROM APPS.AR_MEMO_LINES_ALL_TL@ebsunifor AMLT where name like '%GRAD%';
--
--SELECT TAX_CODE
--FROM APPS.AR_VAT_TAX_ALL_B@ebsunifor
--WHERE END_DATE IS NULL;    
    ;


