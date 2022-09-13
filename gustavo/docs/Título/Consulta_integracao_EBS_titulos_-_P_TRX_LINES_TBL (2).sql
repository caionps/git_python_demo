select
 null   as trx_header_id               			-- number    yes   	identificador para o registro do cabeçalho da fatura. isso deve ser exclusivo para cada registro. #Pode ser um sequencial unico qualquer?
,null   as trx_line_id                 			-- number    yes   	identificador das linhas da transação. #Qual identificar é esse?
,null   as link_to_trx_line_id         			-- number          	esta coluna é necessária apenas se o tipo de linha for tax e freight (se estiver associado a qualquer linha). para as linhas do tipo tax, informar o trx_line_id da linha do tipo line.
,null   as line_number                 			-- number    yes   	sequencial do número da linha da invoice. #COnsultar EBS?
,null   as description                 			-- varchar2 (240)  	descrição da linha da transação, validado de acordo com o campo name.ar_memo_lines_all_tl. #verificar. Acredito que terá as formas de composição do titulo que deveremos consultar.
,1      as quantity_ordered            			-- number          	fixo: 1
,1      as quantity_invoiced           			-- number          	fixo: 1 
,t.vl_original   as unit_standard_price			-- number          	valor unitário do item, com duas casas decimais.
,t.vl_original   as unit_selling_price 			-- number          	valor unitário do item, com duas casas decimais.
,'line' as line_type                   			-- varchar2(20)    	yes informar:line, para linhas de itens. tax, para linhas de impostos.
,null as attribute_category            			-- varchar2(30)    	descriptive flexfield structure definition column. #O que se trata este campo? Temos alguns exemplos?
,null as attribute1_15                 			-- varchar2 (150)  	descriptive flexfield segment. #O que se trata este campo? Como obter este dado?
,'UOL ND' as interface_line_context    			-- varchar2(30)    	de acordo com as regras definidas para primary keys.
--,null as interface_line_attribute1_15 		-- varchar2(30)    	de acordo com a regra 1#, descrita ao final da tabela.
,'065_UNF'      as INTERFACE_LINE_ATTRIBUTE1 	--                  Código da empresa concatenado com Descrição: EXEMPLO: 065_UNF	
,'100_UNF'      as INTERFACE_LINE_ATTRIBUTE2 	--                  Código da filial concatenado com _Descrição: EXEMPLO: 100_UNF	
,t.id_titulo    as INTERFACE_LINE_ATTRIBUTE3 	--                  Número da Nota Fiscal – FATURA/DUPLICATA, Número da Nota de Débito (Para ND) ou Crédito (Para NC) e Número do Banco (Para Cheque Pré-datado ou Devolvido).	
,'2'            as INTERFACE_LINE_ATTRIBUTE4 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor “X”.
,t.vl_original as amount              			-- number           valor da linha.
,null as tax_rate                     			-- number           taxa de imposto. obrigatório para a linha tax.
,null as memo_line_id                 			-- number           identificador do item de linha. preencher apenas para linhas do tipo  line. #verificar no EBS
,'UN' as uom_code                     			-- varchar2(3)      unidade de medida. #Quais as unidades disponiveis? 'UN'
,null as vat_tax_id                   			-- number           identificador do código de imposto (ar_vat_tax). obrigatório para linhas do tipo tax.
,null as tax_exempt_flag              			-- varchar2(1)      fixo: y para linhas do tipo tax. nulo para linhas do do tipo line.
--,null as global_attribute1_20_20    			-- varchar2 (150)   preencher de acordo com a regra 2#, descrita no final da tabela.
,'5949' as LINE_GDF_ATTRIBUTE1        			-- 					CFOP da nota fiscal. Para os demais tipos de transação informar o CFOP 5949.
,'00000000' as LINE_GDF_ATTRIBUTE2 				--					Código da Classificação Fiscal do Item da nota fiscal. Para os demais tipos de transação, diferentes de NFF, informa Fixo: ‘00000000’.
,'FABRICACAO PROPRIA' as LINE_GDF_ATTRIBUTE3 	--					CLASSE DE CONDICAO DA TRANSACAO (Utilização da Mercadoria). Informar a classe da condição da transação das NFFs. Para os demais tipos de transação informar fixo: FABRICACAO PROPRIA;
,'0'  as LINE_GDF_ATTRIBUTE4  					-- 					ORIGEM DO ITEM: 0=NACIONAL OU 1=IMPORTADO 2=IMPORTADO ADQ. NO MERCADO INTERNO.
,'B'  as LINE_GDF_ATTRIBUTE5  					-- 					TIPO FISCAL DO ITEM. Fixo: B.
,'00' as LINE_GDF_ATTRIBUTE6                    -- 					SITUACAO TRIBUTÁRIA FEDERAL. Situação Tributária Federal da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: ‘00’.
,'0' as LINE_GDF_ATTRIBUTE7                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: ‘0’.
,'jl.br.arxtwmai.additional info' as global_attribute_category    -- varchar2(30)     fixo: jl.br.arxtwmai.additional info
,null as amount_includes_tax_flag     			-- varchar2(1)      informar y para impostos inclusivos, nas linhas do tipo tax. para as demais linhas deixar nulo.
,123  as warehouse_id                 			-- number           fixo: 123

from 
    ca.ctr_titulo t		