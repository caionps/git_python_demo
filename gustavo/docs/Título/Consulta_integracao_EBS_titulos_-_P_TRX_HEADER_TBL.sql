--algumas informacoes terão que ser passadas para o select com complementada de outra maneira
--um exemplo é a matricula e outro ex são os cheques
create or replace view ca.vw_gvs_TRX_HEADER
as
select 
t.id_titulo as trx_number				      --				Null			Este é o número da transação para a fatura, de acordo com o número da transação do UOL.
,t.dt_hr_inclusao as trx_date			      --				Null			Data de emissão da transação no UOL.
,t.dt_hr_inclusao as gl_date			      --				Null			Data de contabilização da transação. Deve ser a mesma data da transação.
,'BRL' as trx_currency					      --			    Null			Fixo: BRL.
,(SELECT RCTA.NAME FROM RA_CUST_TRX_TYPES_ALL@ebsunifor RCTA WHERE RCTA.CREATED_BY <> -1 AND END_DATE IS NULL and name ='INSCR_PROC_SELETIVO') 
       as cust_trx_type_name                  --				Null			Nome do tipo de transação do AR. Recuperar o NOME de acordo com os Tipos de Transação cadastrados no EBS.Para verificar os Tipos de Transações cadastrados no EBS, utilizar a consulta abaixo:---SELECT RCTA.NAME FROM RA_CUST_TRX_TYPES_ALL RCTA WHERE RCTA.CREATED_BY <> -1 AND END_DATE IS NULL
,case 
    when p.tp_pessoa = 'F' then (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0))  
    when p.tp_pessoa = 'J' then 'Juridica'
    when p.tp_pessoa = 'E' then decode( pe.nr_cpf, null, pe.nr_passaporte,lpad(pe.nr_cpf,9,0)||lpad(pe.dv_cpf,2,0))
    end as bill_to_customer_ref		   	      --Yes					 	   		Faturar para o ID do cliente. Isso deve existir na tabela hz_cust_accounts. O cliente deve ser um cliente ativo ('A'). Validado em relação a hz_cust_accounts.cust_account_id.     ####verificar o id do cliente correspondente ao UOL. #Consultar no EBS via dblink ou api
,case 
           when p.tp_pessoa = 'F' then (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0))  
           when p.tp_pessoa = 'J' then 'Juridica'
           when p.tp_pessoa = 'E' then decode( pe.nr_cpf, null, pe.nr_passaporte,lpad(pe.nr_cpf,9,0)||lpad(pe.dv_cpf,2,0))
           end ||'_'|| 'resolver_matricula' as bill_to_address_ref			      	--				Null			ID do endereço de faturamento do cliente. Isso deve existir em hz_cust_acct_sites para o ID de faturamento do cliente preenchido.
,case 
           when p.tp_pessoa = 'F' then (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0))  
           when p.tp_pessoa = 'J' then 'Juridica'
           when p.tp_pessoa = 'E' then decode( pe.nr_cpf, null, pe.nr_passaporte,lpad(pe.nr_cpf,9,0)||lpad(pe.dv_cpf,2,0))
           end ||'_'|| 'resolver_matricula' as ship_to_customer_ref			      	--				    			Entregar para o ID do cliente. Isso deve existir na tabela hz_cust_accounts. O cliente deve ser um cliente ativo ('A'). Validado em relação a hz_cust_accounts.cust_account_id.  #Consultar no EBS
,case 
           when p.tp_pessoa = 'F' then (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0))  
           when p.tp_pessoa = 'J' then 'Juridica'
           when p.tp_pessoa = 'E' then decode( pe.nr_cpf, null, pe.nr_passaporte,lpad(pe.nr_cpf,9,0)||lpad(pe.dv_cpf,2,0))
           end ||'_'|| 'resolver_matricula' as ship_to_address_ref			      	--				Null			ID do endereço de entrega do cliente. Isso deve existir em hz_cust_acct_sites para o ID de faturamento do cliente preenchido.#Consultar no EBS
,(SELECT RT.NAME FROM APPS.RA_TERMS@ebsunifor RT WHERE CREATED_BY <> -1 AND END_DATE_ACTIVE IS NULL and name ='31DD') 
    as term_name			           	      	--				Null			Identificador de Condições de Pagamento. O Term ID deve ser válido para a data da transação. Se não for preenchido, ele será recuperado de ra_terms com base em bill_to_customer_id e bill_to_site_use_id.#Consultar no EBS
,'-3' as primary_salesrep_id			      	--				Null			Fixo: -3
,(SELECT ARM.NAME FROM AR_RECEIPT_METHODS@ebsunifor ARM WHERE ARM.CREATED_BY <> 1 AND ARM.END_DATE IS NULL and name = 'BRAD_0452_311356_CART') 
        as receipt_method_name			      	--				Null			ID do método de recebimento utilizado na transação. Caso não seja informado, será utilizado o método de recebimento padrão do cadastro do cliente.  #Consultar no EBS
,'Null' as attribute_category			      	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute1			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute2			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute3			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute4			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute5			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute6			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute7			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute8			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute9			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'Null' as attribute10			   	     	--				Null			Preencher de acordo com a Regra 1#, descrita no final da tabela. #Verifcar Tipos de transação existentes no EBS.
,'JL.BR.ARXTWMAI.Additional Info' as global_attribute_category--Null			Fixo: JL.BR.ARXTWMAI.Additional Info
,'R' as HEADER_GDF_ATTRIBUTE1       			--				Null			Tipo de Juros. Fixo: R
,t.pc_juros as HEADER_GDF_ATTRIBUTE2       		--				Null			Taxa/ Quantia de Juros. Informar a taxa de juros a ser cobrada na transação.
,30 as HEADER_GDF_ATTRIBUTE3       				--				Null			Períod o de Juros. Fixo: 30.
,'S' as HEADER_GDF_ATTRIBUTE4       			--				Null			Fórmula de Juros. Fixo: S
, 2 as HEADER_GDF_ATTRIBUTE5       				--				Null			Dias de Tolerência. Fixo: 2
,'UOL ND???' as interface_header_contex 		--				Null			De acordo com as regras definidas para Primary Keys. #Verifcar Regra no documento.
,null as interface_header_attribute1	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute2	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute3	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute4	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute5	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute6	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute7	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute8	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute9	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute10	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
--,'065_UNF'      as INTERFACE_LINE_ATTRIBUTE1 --                                 Código da empresa concatenado com Descrição: EXEMPLO: 065_UNF	
--,'100_UNF'      as INTERFACE_LINE_ATTRIBUTE2 --                                 Código da filial concatenado com _Descrição: EXEMPLO: 100_UNF	
--,t.id_titulo    as INTERFACE_LINE_ATTRIBUTE3 --                                 Número da Nota Fiscal – FATURA/DUPLICATA, Número da Nota de Débito (Para ND) ou Crédito (Para NC) e Número do Banco (Para Cheque Pré-datado ou Devolvido).	
--,'2'            as INTERFACE_LINE_ATTRIBUTE4 --                                 Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor “X”.
from 
	ca.ctr_titulo t,
    ca.cp_pessoa p
      left join ca.cp_pessoa_fisica pf on p.id_pessoa = pf.id_pessoa_fisica
      left join ca.cp_pessoa_juridica pj on p.id_pessoa = pj.ID_PESSOA_JURIDICA
      left join ca.cp_pessoa_estrangeiro pe on p.id_pessoa = pe.ID_PESSOA_ESTRANGEIRO
where
    t.id_pessoa_cobranca = p.id_pessoa

--Dúvidas:
--Verificar se o cliente da fatura e da entrega vamos utilizar o mesmo ?
--teremos emissão de título para pessoa juridica no vestibular e 1 matricula
;