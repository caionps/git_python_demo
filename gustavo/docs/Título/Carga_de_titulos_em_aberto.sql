SELECT 
  NULL                  INTERFACE_LINE_ID                  --Sequence da tabela de Interface. Será fornecido pelo Oracle
,'CARGA INICIAL NF'     INTERFACE_LINE_CONTEXT             --De acordo com as regras de extração de carga definidas para Primary Keys.
,'065_UNF'	 		    INTERFACE_LINE_ATTRIBUTE1          --Código da empresa concatenado com Descrição: EXEMPLO: 065_UNF
,'100_UNF'   		    INTERFACE_LINE_ATTRIBUTE2          --Código da filial concatenado com _Descrição: EXEMPLO: 100_UNF
,T.ID_TITULO 		    INTERFACE_LINE_ATTRIBUTE3          --Número da Nota Fiscal – FATURA/DUPLICATA | Número da Nota de Débito (Para ND) ou Crédito (Para NC)|Número do Banco (Para Cheque Pré-datado ou Devolvido)
,2			            INTERFACE_LINE_ATTRIBUTE4          --Subsérie da NF para Fatura/Duplicata| Tipo (Para Nota de Débito ou Crédito)| Número da Agência (Para Cheque Devolvido ou Pré-datado)
,'X'			        INTERFACE_LINE_ATTRIBUTE5          --Número da Parcela (Para Fatura/Duplicata ou NC) Número do Cheque (Para Cheque Devolvido ou Pré-Datado)
,'X'			        INTERFACE_LINE_ATTRIBUTE6          --Sequência para Cheque Devolvido ou Pré-datado
,'X'			        INTERFACE_LINE_ATTRIBUTE7          --Tipo de Cheque (Devolvido ou Pré-Datado)
,'CARGA INICIAL'        HEADER_ATTRIBUTE_CATEGORY          --FIXO: CARGA INICIAL
,'*'                    HEADER_ATTRIBUTE2                  --NOSSO NÚMERO
,CASE BAN.NR_BANCO
    WHEN 237 THEN (BAN.NM_BANCO || BAC.NR_AGENCIA ||BAC.CD_CEDENTE||'-'||BAC.DV_CEDENTE)
 ELSE
    BAN.NM_BANCO 
 END 
                        HEADER_ATTRIBUTE3                  --Banco/Agência/Conta Bancária 
,T.DT_VENCIMENTO	    HEADER_ATTRIBUTE4                  --DATA DE VENCIMENTO DO UOL. (DD/MM/YYYY) 
,'*'         	        HEADER_ATTRIBUTE5                  --Identificador da Posição do Título. 
,'*'		            HEADER_ATTRIBUTE6                  --Status do título no SERASA Ex: BLOQUEADO/INCLUIDO/EXCLUIDO
,'*'		            HEADER_ATTRIBUTE7                  --Data da última movimentação no SERASA para identificar se o Título foi Incluído/Excluído. (DD/MM/YYYY)
,'*'                    HEADER_ATTRIBUTE8                  --Status do Título na cobradora. Ex: ENVIADO/DEVOLVIDO
,(SELECT DT_MOVIMENTO FROM CTR_TITULO_MOVIMENTO WHERE ID_TITULO = T.ID_TITULO AND ROWNUM <= 1) 
                        HEADER_ATTRIBUTE9                  --Data da última movimentação na cobradora. (DD/MM/YYYY)
, BAN.NM_BANCO		    HEADER_ATTRIBUTE10                 --Nome da cobradora em que o título se encontra.
, '*'		            HEADER_ATTRIBUTE11                 --Motivo de Devolução para Cheques devolvidos. Informar o Número da Alínea  
,'65100_CARGA_ND'	    BATCH_SOURCE_NAME                  --EX: Para NFF, 65100_CARGA_NFF; Para ND, 65100_CARGA_ND;Para Cheque Devolvidos, 65100_CARGA_CHQ_DEVOL Para Cheque Programado, 65100_CARGA_CHQ_PROG, 65100_CARGA_NC
,'inf contabil'	        SET_OF_BOOKS_ID                    --Identificador do Livro Contábil do Brasil. Obs: Teremos o valor somente após a criação do livro contábil no sistema. #Consultar no EBS Pegar a informação com a Alice quando for enviar a carga.
,'LINE'         	    LINE_TYPE                          --Para carga Inicial será fixo: LINE
,'CARGA INICIAL' 	    DESCRIPTION                        --DESCRIÇÃO DO ITEM Para carga Inicial será fixo: CARGA INICIAL
,'BRL'      		    CURRENCY_CODE                      --BRL é a moeda funcional e será fixo: BRL
,ca.pk_ctr_util.f_calcular_valores_titulo(3, t.id_titulo) 
                        AMOUNT                             --Para carga inicial informar o valor do saldo em aberto da respectiva parcela.Formatar o valor com casas decimais.
,'*'		            CUST_TRX_TYPE_NAME                 --Tipo de Transação referente ao NOP. Será criado um Tipo de Transação para cada Filial e contexto.
,'UNF_CARGA'		    TERM_NAME                          --Informe a Condição de Pagamento do Título
,(select 
    case cp.tp_pessoa
        when 'F' then (select distinct lpad(nr_cpf,   9, 0)|| lpad(dv_cpf, 2, 0)  from cp_pessoa_fisica where id_pessoa_fisica = cp.id_pessoa)
        when 'j' then (select distinct lpad(nr_cnpj, 12, 0) from cp_pessoa_juridica where id_pessoa_juridica = cp.id_pessoa)
    end as cpf_cnpj
from 
    cp_pessoa cp
where 
    id_pessoa = nvl(t.id_pessoa_cobranca,t.id_pessoa_cliente))
                    	ORIG_SYSTEM_BILL_CUSTOMER_REF      --Raiz do CNPJ para PJ. CPF completo para PF
,(select 
    case cp.tp_pessoa
        when 'F' then (select distinct lpad(nr_cpf,   9, 0)|| lpad(dv_cpf,  2, 0)||'-001'  from cp_pessoa_fisica where id_pessoa_fisica = cp.id_pessoa)
        when 'j' then (select distinct lpad(nr_cnpj, 12, 0)|| lpad(dv_cnpj, 2, 0)||'-001' from cp_pessoa_juridica where id_pessoa_juridica = cp.id_pessoa)
    end as cpf_cnpj
from 
    cp_pessoa cp
where 
    id_pessoa = nvl(t.id_pessoa_cobranca,t.id_pessoa_cliente))
  	                    ORIG_SYSTEM_BILL_ADDRESS_REF       --CNPJ Completo + “-001”CPF Completo + “-001”
,(select 
    case cp.tp_pessoa
        when 'F' then (select distinct lpad(nr_cpf,   9, 0)|| lpad(dv_cpf, 2, 0)  from cp_pessoa_fisica where id_pessoa_fisica = cp.id_pessoa)
        when 'j' then (select distinct lpad(nr_cnpj, 12, 0) from cp_pessoa_juridica where id_pessoa_juridica = cp.id_pessoa)
    end as cpf_cnpj
from 
    cp_pessoa cp
where 
    id_pessoa = nvl(t.id_pessoa_cobranca,t.id_pessoa_cliente))
                     	ORIG_SYSTEM_SHIP_CUSTOMER_REF      --Raiz do CNPJ para PJ. CPF completo para PF
,(select 
    case cp.tp_pessoa
        when 'F' then (select distinct lpad(nr_cpf,   9, 0)|| lpad(dv_cpf, 2, 0)  from cp_pessoa_fisica where id_pessoa_fisica = cp.id_pessoa)
        when 'j' then (select distinct lpad(nr_cnpj, 12, 0) from cp_pessoa_juridica where id_pessoa_juridica = cp.id_pessoa)
    end as cpf_cnpj
from 
    cp_pessoa cp
where 
id_pessoa = nvl(t.id_pessoa_cobranca,t.id_pessoa_cliente))
	                    ORIG_SYSTEM_SHIP_ADDRESS_REF       --Raiz do CNPJ para PJ. CPF completo para PF
,(select 
    case cp.tp_pessoa
        when 'F' then (select distinct lpad(nr_cpf,   9, 0)|| lpad(dv_cpf, 2, 0)  from cp_pessoa_fisica where id_pessoa_fisica = cp.id_pessoa)
        when 'j' then (select distinct lpad(nr_cnpj, 12, 0) from cp_pessoa_juridica where id_pessoa_juridica = cp.id_pessoa)
    end as cpf_cnpj
from 
    cp_pessoa cp
where 
    id_pessoa = nvl(t.id_pessoa_cobranca,t.id_pessoa_cliente))
                    	ORIG_SYSTEM_SOLD_CUSTOMER_REF      --Raiz do CNPJ para PJ. CPF completo para PF
,CASE T.CD_AGENTE_COBRADOR
    WHEN 237 THEN 'CARGA_MET_REC_ESC'
 ELSE
    'CARGA_MET_REC_CART'
 END                    RECEIPT_METHOD_NAME                --Fixo: CARGA_MET_REC_ESC (Para título escritural em cobrança bancária) Fixo: CARGA_MET_REC_CART (Para títulos em carteira)
,'User'		            CONVERSION_TYPE                    --Fixo: User
,1			            CONVERSION_RATE                    --Fixo: 1
,T.DT_HR_INCLUSAO  	    TRX_DATE                           --DATA DE EMISSÃO DO DOCUMENTO (NF, ND ou NC).
,LAST_DAY(SYSDATE)      GL_DATE                            --DATA DE CONTABILIZAÇÃO.
,(T.ID_TITULO||'_'||1)  TRX_NUMBER                         --Para NF, utilizar Número da Nota Fiscal/Fatura/ Nota de Débito + “_” + Série (se diferente de nulo) + “_” + Número da parcela. Ex: 001623_1E_A, 000146_A (série nula).- Para ND e NC, utilizar Número da Nota de Débito como consta no UOL + “_” + Tipo(Duplicata/Crédito = 1; Cheque = 2)
,NULL		            MTL_SYSTEM_ITEMS_SEG1              --Para carga Inicial este campo será nulo.
,1			            LINE_NUMBER                        --NUMERO DA LINHA (Item). Fixo: 1
,1			            QUANTITY                           --QUANTIDADE DOS ITENS (Fixo 1)
,1			            QUANTITY_ORDERED                   --QUANTIDADE DOS ITENS (Fixo 1)
,ca.pk_ctr_util.f_calcular_valores_titulo(3, t.id_titulo) 		
                        UNIT_SELLING_PRICE                 --Para carga inicial informar o valor do saldo em aberto da respectiva parcela. Formatar o valor com casas decimais.
,ca.pk_ctr_util.f_calcular_valores_titulo(3, t.id_titulo)
                        UNIT_STANDARD_PRICE                --Para carga inicial informar o valor do saldo em aberto da respectiva parcela. Formatar o valor com casas decimais.
,'-3'                   PRIMARY_SALESREP_NUMBER            --Informar o código do vendedor.  Caso não exista vendedor, informar ‘-3’ 
,'65100_CARGA INICIAL'  MEMO_LINE_NAME                     --Nomes definidos no item Pré-Requisitos. (Será criada uma memo line de Carga para cada Filial)
,'UN'			        UOM_CODE                           --Fixo: UN
,'S'		            TAX_EXEMPT_FLAG                    --Fixo: S
,'USUARIOEBS'		    CREATED_BY                         --USUARIO DE CRIACAO – ID DO USUÁRIO DE CARGA Deverá ser definido um usuário de Carga para esta interface.
,SYSDATE	            CREATION_DATE                      --Data da carga do registro.  Sysdate do dia da Carga
,'USUARIOEBS'		    LAST_UPDATED_BY                    --USUARIO DE ATUALIZACAO – IDDO USUÁRIO DE CARGA Deverá ser definido um usuário de Carga para esta interface.
,SYSDATE	            LAST_UPDATE_DATE                   --Data da carga do registro. Sysdate do dia da Carga
,101		            ORG_ID                             --ID DA ORGANIZACAO/Unidade Operacional cadastrada no Oracle. No ambiente atual.SELECT * FROM HR_ALL_ORGANIZATION_UNITS WHERE NAME LIKE OU_UNF%
,'5.949'	            LINE_GDF_ATTRIBUTE1                --Deverá existir no AR. Fixo: 5.949
,'00000000'             LINE_GDF_ATTRIBUTE2                --Fixo: 00000000
,'FABRICACAO PROPRIA'	LINE_GDF_ATTRIBUTE3                --Fixo: FABRICACAO PROPRIA
,0 		            	LINE_GDF_ATTRIBUTE4                --ORIGEM DO ITEM: 0=NACIONAL OU 1=IMPORTADO 2=IMPORTADO ADQ. NO MERCADO INTERNO
,'B'       			    LINE_GDF_ATTRIBUTE5                --TIPO FISCAL DO ITEM. Fixo: B
,'00'		        	LINE_GDF_ATTRIBUTE6                --00 SITUACAO TRIBUTÁRIA FEDERAL
,'00'			        LINE_GDF_ATTRIBUTE7                --00 SITUACAO TRIBUTÁRIA ESTADUAL
,101			        WAREHOUSE_ID                       --ID da Organização de Inventário referente à Filial de Faturamento.
,'JL.BR.ARXTWMAI.Additional Info'
                        LINE_GDF_ATTR_CATEGORY              --Fixo: JL.BR.ARXTWMAI.Additional Info 
,'JL.BR.ARXTWMAI.Additional Info' 
                        HEADER_GDF_ATTR_CATEGORY            --Fixo: JL.BR.ARXTWMAI.Additional Info
,'R'       			    HEADER_GDF_ATTRIBUTE1               --Tipo de Juros
,'3'		            HEADER_GDF_ATTRIBUTE2               --Taxa/Quantia de Juros. 
,'30'			        HEADER_GDF_ATTRIBUTE3               --Período de Juros   Fixo: 30    
,'S'			        HEADER_GDF_ATTRIBUTE4               --Fórmula de Juros   Fixo: S
,'2'			        HEADER_GDF_ATTRIBUTE5               --Dias de Tolerância Fixo: 2

FROM
	CA.CTR_TITULO T,
	CA.BANCO BAN,
	CTR_BANCO_AGENCIA_CARTEIRA BAC
WHERE
    T.CD_AGENTE_COBRADOR = BAN.NR_BANCO (+)    
AND T.DT_LIQUIDACAO IS NULL
AND T.CD_FAIXA_ST_TITULO IN (1, 2)