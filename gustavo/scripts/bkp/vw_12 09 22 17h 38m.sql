--------------------------------------------------------
--  Arquivo criado - segunda-feira-setembro-12-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View D_V_LCT_EBS_CONTA_CONTABIL
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."D_V_LCT_EBS_CONTA_CONTABIL" ("CD_CONTA_CONTABIL_EBS", "DS_CONTA_CONTABIL_EBS", "DT_ATUALIZACAO", "CD_LINHA_PRODUTO", "FG_CONTABILIZA", "FG_ATIVO") AS 
  Select l.flex_value         cd_conta_contabil_ebs
     , l.description        ds_conta_contabil_ebs

     , start_date_active    dt_atualizacao
     , null                 cd_linha_produto

     , case
        when  substr(l.compiled_value_attributes,-7,1) = 'Y'  then -- Flag que indica se contabiliza
             'S'
        else
             'N'
       end                  fg_contabiliza
    , case
        when l.enabled_flag                           = 'Y'   then -- Flag que indica se o valor esta ativo
             'S'
        else
             'N'
       end                  fg_ativo
From apps.fnd_flex_value_sets@ebsunifor v
   , apps.fnd_flex_values_vl@ebsunifor  l
Where v.flex_value_set_name = 'FEQ_GL_UNF_CONTA_CONTABIL' -- Nome do conjunto de valores que lista os valores do segmento CONTA
  and v.flex_value_set_id   = l.flex_value_set_id
  and trunc(sysdate) between nvl(start_date_active,trunc(sysdate)) and nvl(end_date_active,trunc(sysdate))
;
  GRANT SELECT ON "CA"."D_V_LCT_EBS_CONTA_CONTABIL" TO "OUL";
  GRANT SELECT ON "CA"."D_V_LCT_EBS_CONTA_CONTABIL" TO "USUARIOS";
  GRANT SELECT ON "CA"."D_V_LCT_EBS_CONTA_CONTABIL" TO "SISTEMAS";
--------------------------------------------------------
--  DDL for View D_V_LCT_EBS_LINHA_PRODUTO
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."D_V_LCT_EBS_LINHA_PRODUTO" ("CD_LINHA_PRODUTO", "DS_LINHA_PRODUTO", "DT_ATUALIZACAO", "FG_CONTABILIZA", "FG_ATIVO") AS 
  select l.flex_value         cd_linha_produto 
     , l.description        ds_linha_produto
     , start_date_active    dt_atualizacao
     , case
        when substr( l.compiled_value_attributes, -1, 1)   = 'Y'  then -- Flag que indica se contabiliza
             'S'
        else
             'N'
       end                  fg_contabiliza
    , case
        when l.enabled_flag                               = 'Y'   then -- Flag que indica se o valor esta ativo
             'S'
        else
             'N'
       end                  fg_ativo
From apps.fnd_flex_value_sets@ebsunifor v
   , apps.fnd_flex_values_vl@ebsunifor l
Where v.flex_value_set_name = 'FEQ_GL_UNF_LINHA_PRODUTO' -- Nome do conjunto de valores que lista os valores do segmento PRODUTO
and   v.flex_value_set_id   = l.flex_value_set_id
--and   l.enabled_flag        = 'Y' -- Flag que indica se o valor esta ativo
and   trunc(sysdate) between nvl(start_date_active,trunc(sysdate)) and nvl(end_date_active,trunc(sysdate))
--and   substr(l.compiled_value_attributes,-1,1) = 'Y' -- Flag que indica se contabiliza;
;
--------------------------------------------------------
--  DDL for View V_AL_CONTA_EBS_ALMOXARIFADO
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."V_AL_CONTA_EBS_ALMOXARIFADO" ("CD_CONTA_EBS", "DS_CONTA_EBS") AS 
  (
select to_number('110502')   cd_conta_ebs, 'ALMOXARIFADO' ds_conta_ebs from dual union
select to_number('11050201') cd_conta_ebs, 'MATERIAL DE MANUTENCAO DE FROTA' ds_conta_ebs from dual union
select to_number('11050202') cd_conta_ebs, 'COMBUSTIVEIS' ds_conta_ebs from dual union
select to_number('11050204') cd_conta_ebs, 'MEDICAMENTOS' ds_conta_ebs from dual union
select to_number('11050208') cd_conta_ebs, 'MATERIAIS ODONTOLOGICOS' ds_conta_ebs from dual union
select to_number('11050209') cd_conta_ebs, 'MATERIAIS DE LABORATORIO' ds_conta_ebs from dual union
select to_number('11050210') cd_conta_ebs, 'MATERIAIS FOTOGRAFICOS' ds_conta_ebs from dual union
select to_number('11050211') cd_conta_ebs, 'MATERIAIS ESPORTIVOS' ds_conta_ebs from dual union
select to_number('11050212') cd_conta_ebs, 'MATERIAIS GRAFICOS' ds_conta_ebs from dual union
select to_number('11050213') cd_conta_ebs, 'MATERIAL INSTITUICIONAL' ds_conta_ebs from dual union
select to_number('11050214') cd_conta_ebs, 'MATERIAL DE ESCRITORIO' ds_conta_ebs from dual union
select to_number('11050215') cd_conta_ebs, 'MATERIAL DE INFORMATICA' ds_conta_ebs from dual union
select to_number('11050216') cd_conta_ebs, 'MATERIAL DE LIMPEZA' ds_conta_ebs from dual union
select to_number('11050217') cd_conta_ebs, 'MATERIAL ELETRICO' ds_conta_ebs from dual union
select to_number('11050218') cd_conta_ebs, 'GENEROS ALIMENTICIOS' ds_conta_ebs from dual union
select to_number('11050219') cd_conta_ebs, 'FARDAMENTOS E SIMILARES ' ds_conta_ebs from dual union
select to_number('11050220') cd_conta_ebs, 'MATERIAL APLICADO A MANUTENCAO' ds_conta_ebs from dual union
select to_number('11050221') cd_conta_ebs, 'MATERIAL APLICADO A CONSERVACAO' ds_conta_ebs from dual union
select to_number('11050222') cd_conta_ebs, 'MATERIAL ELETRONICO' ds_conta_ebs from dual union
select to_number('11050299') cd_conta_ebs, 'OUTROS MATERIAIS' ds_conta_ebs from dual union
--
select to_number('11050223') cd_conta_ebs, 'MATERIAL EDUCATIVO E SIMILARES' ds_conta_ebs from dual union
select to_number('11050224') cd_conta_ebs, 'MATERIAIS DE COZINHA E SIMILARES' ds_conta_ebs from dual union
select to_number('11050225') cd_conta_ebs, 'MATERIAIS DE CAMA, MESA, BANHO E SIMILARES' ds_conta_ebs from dual union
select to_number('11050226') cd_conta_ebs, 'MATERIAIS DE DECORAÇÃO E SIMILARES' ds_conta_ebs from dual union
select to_number('11050227') cd_conta_ebs, 'MATERIAIS DE COPA E SIMILARES' ds_conta_ebs from dual union
select to_number('11050228') cd_conta_ebs, 'MATERIAIS DE AVIAMENTOS E SIMILARES' ds_conta_ebs from dual
)


;
  GRANT SELECT ON "CA"."V_AL_CONTA_EBS_ALMOXARIFADO" TO "SISTEMAS";
  GRANT SELECT ON "CA"."V_AL_CONTA_EBS_ALMOXARIFADO" TO "USUARIOS";
--------------------------------------------------------
--  DDL for View V_LCT_EBS_CONTA_CONTABIL
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."V_LCT_EBS_CONTA_CONTABIL" ("CD_CONTA_CONTABIL_EBS", "DS_CONTA_CONTABIL_EBS", "DT_ATUALIZACAO", "CD_LINHA_PRODUTO", "FG_CONTABILIZA", "FG_ATIVO") AS 
  Select "CD_CONTA_CONTABIL_EBS","DS_CONTA_CONTABIL_EBS","DT_ATUALIZACAO","CD_LINHA_PRODUTO","FG_CONTABILIZA","FG_ATIVO" from ca.lct_ebs_conta_contabil
;
--------------------------------------------------------
--  DDL for View V_LCT_EBS_LINHA_PRODUTO
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."V_LCT_EBS_LINHA_PRODUTO" ("CD_LINHA_PRODUTO", "DS_LINHA_PRODUTO", "DT_ATUALIZACAO", "FG_CONTABILIZA", "FG_ATIVO") AS 
  select "CD_LINHA_PRODUTO","DS_LINHA_PRODUTO","DT_ATUALIZACAO","FG_CONTABILIZA","FG_ATIVO" from ca.lct_ebs_linha_produto
;
  GRANT SELECT ON "CA"."V_LCT_EBS_LINHA_PRODUTO" TO "OUL";
  GRANT SELECT ON "CA"."V_LCT_EBS_LINHA_PRODUTO" TO "SISTEMAS";
  GRANT SELECT ON "CA"."V_LCT_EBS_LINHA_PRODUTO" TO "USUARIOS";
--------------------------------------------------------
--  DDL for View V_LISTAR_PORTARIA_ALUNO
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."V_LISTAR_PORTARIA_ALUNO" ("ID_PORTARIA", "ID_MODALIDADE", "DS_PORTARIA", "NR_MATRICULA") AS 
  select prtr.id_portaria
     , prtr.ds_portaria
     , modl.id_modalidade
     , agrd.nr_matricula

from   ca.gvs_portaria                  prtr
     , ca.fat_academico                 acad
     , ca.gvs_portaria_modalidade       pmod
     , ca.fat_modalidade                modl
     , ca.gvs_portaria_modalidade_curso pcur
     , ca.aluno                         agrd
     
where  prtr.id_academico = acad.id_academico
and    prtr.fg_ativo = 'S'
and    acad.fg_ativo = 'S'
and    sysdate between acad.dt_inicio_utilizacao and acad.dt_termino_utilizacao
and    prtr.id_portaria = pmod.id_portaria
and    pmod.fg_ativo = 'S'
and    pmod.id_modalidade_excecao = modl.id_modalidade
and    modl.fg_ativo = 'S'
and    modl.fg_exclusivo_sistema = 'N'
and    pmod.id_portaria_modalidade = pcur.id_portaria_modalidade
and    pcur.fg_ativo = 'S'
and    pcur.cd_curso = agrd.curso_atual
and    nvl(agrd.st_academica,'X') not in ('G','I','D')
;
  GRANT SELECT ON "CA"."V_LISTAR_PORTARIA_ALUNO" TO "USUARIOS";
  GRANT SELECT ON "CA"."V_LISTAR_PORTARIA_ALUNO" TO "SISTEMAS";
  GRANT SELECT ON "CA"."V_LISTAR_PORTARIA_ALUNO" TO "OUL";
  GRANT SELECT ON "CA"."V_LISTAR_PORTARIA_ALUNO" TO "UOL";
--------------------------------------------------------
--  DDL for View V_PLA_INV_VIAGEM_APROV_CCEBS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."V_PLA_INV_VIAGEM_APROV_CCEBS" ("CD_CENTRO_CUSTO_AREA_BENEF", "DS_OBJETIVO", "CD_IND_SETOR", "DS_IND_SETOR", "CD_PLANO", "CD_SETOR_ORG", "CD_OBJETIVO", "CDIND_SETOR", "CD_ACAO_IND_SETOR", "DS_ACAO_IND_SETOR", "CD_INV", "DS_INVESTIMENTO", "CD_TIPO_INVESTIMENTO", "DS_TIPO_INVESTIMENTO", "QT_ITEM_INVESTIMENTO", "VL_ITEM_INVESTIMENTO", "ST_ITEM_INVESTIMENTO", "DT_INICIO", "DT_FIM", "JUSTIFICATIVA", "DT_ULT_ALT", "CD_ESTABELECIMENTO", "NR_REGISTRO", "OBS_ITEM", "DS_SETOR", "CD_AREA_BENEF", "DS_AREA_BENEF", "DS_LOCAL_INV", "VL_SALDO") AS 
  SELECT
	      CC.CD_CENTRO_CUSTO_EBS AS CD_CENTRO_CUSTO_AREA_BENEF,
				UPPER(O.DS_OBJETIVO) AS DS_OBJETIVO,
				I.CD_IND_SETOR AS CD_IND_SETOR ,
				I.DS_IND_SETOR AS DS_IND_SETOR,
	      IA.CD_PLANO AS CD_PLANO,                 
				IA.CD_SETOR_ORG AS CD_SETOR_ORG,             
				IA.CD_OBJETIVO AS CD_OBJETIVO,              
				IA.CD_IND_SETOR AS CDIND_SETOR,             
				IA.CD_ACAO_IND_SETOR AS CD_ACAO_IND_SETOR,
				AIS.DS_ACAO_IND_SETOR AS DS_ACAO_IND_SETOR,      
				IA.CD_INV AS CD_INV,                   
				IA.DS_INVESTIMENTO AS DS_INVESTIMENTO,          
				IA.CD_TIPO_INVESTIMENTO AS CD_TIPO_INVESTIMENTO,
				TI.DS_TIPO_INVESTIMENTO AS DS_TIPO_INVESTIMENTO,   
				IA.QT_ITEM_INVESTIMENTO AS QT_ITEM_INVESTIMENTO,     
				trim(TO_CHAR(IA.VL_ITEM_INVESTIMENTO, '99999999990D99','NLS_NUMERIC_CHARACTERS='',.''') ) AS VL_ITEM_INVESTIMENTO,  
				IA.ST_ITEM_INVESTIMENTO AS ST_ITEM_INVESTIMENTO,     
				TO_CHAR(IA.DT_INICIO, 'DD/MM/YYYY') AS DT_INICIO,                
				TO_CHAR(IA.DT_FIM, 'DD/MM/YYYY') AS DT_FIM,                  
				IA.JUSTIFICATIVA AS JUSTIFICATIVA,           
				IA.DT_ULT_ALT AS DT_ULT_ALT,        
				IA.CD_ESTABELECIMENTO AS CD_ESTABELECIMENTO,
				IA.NR_REGISTRO AS NR_REGISTRO,       
				IA.OBS_ITEM AS OBS_ITEM,       
				setor.ds_setor AS DS_SETOR,
				IA.CD_AREA_BENEF AS CD_AREA_BENEF,
				setorArea.ds_setor AS DS_AREA_BENEF,
			  IA.DS_LOCAL_INV AS DS_LOCAL_INV,
			  S_VIA_CALCULA_SALDO_QTD_INV (IA.CD_SETOR_ORG, IA.CD_PLANO, IA.CD_OBJETIVO, IA.CD_IND_SETOR, IA.CD_ACAO_IND_SETOR, IA.CD_INV) AS VL_SALDO
			FROM
				CA.PLA_INV_ACAO IA
				, CA.PLA_ACAO_IND_SETOR AIS
				, CA.PLA_OBJETIVO O
				, CA.PLA_IND_SETOR I
				, CA.PLA_TIPO_INVESTIMENTO TI
	      , ca.organograma setor
	      , ca.organograma setorArea
	      ,AL.CENTRO_CUSTO CC
			WHERE IA.ST_ITEM_INVESTIMENTO IN ('6','7')
	    	AND IA.ST_PARECER IN ('4', '5')
	      AND setor.CD_SETOR_ORGANIZACIONAL = IA.CD_SETOR_ORG
	      AND setorArea.CD_SETOR_ORGANIZACIONAL = IA.CD_AREA_BENEF
	      AND setorArea.CD_CENTRO_CUSTO = CC.Cd_Centro_Custo(+)
				AND (IA.CD_TIPO_INVESTIMENTO = TI.CD_TIPO_INVESTIMENTO AND IA.CD_PLANO = TI.CD_PLANO)
				AND IA.CD_ACAO_IND_SETOR = AIS.CD_ACAO_IND_SETOR
				AND IA.CD_IND_SETOR = AIS.CD_IND_SETOR
				AND IA.CD_OBJETIVO = AIS.CD_OBJETIVO
				AND IA.CD_SETOR_ORG = AIS.CD_SETOR_ORG
				AND IA.CD_PLANO = AIS.CD_PLANO
				AND IA.CD_PLANO = I.CD_PLANO
				AND IA.CD_SETOR_ORG = I.CD_SETOR_ORG
				AND IA.CD_OBJETIVO = I.CD_OBJETIVO
				AND IA.CD_IND_SETOR = I.CD_IND_SETOR
				AND IA.CD_OBJETIVO = O.CD_OBJETIVO
				AND IA.CD_PLANO = O.CD_PLANO
	      ORDER BY IA.CD_SETOR_ORG, IA.CD_OBJETIVO, IA.CD_IND_SETOR, IA.CD_ACAO_IND_SETOR, IA.CD_INV
;
  GRANT SELECT ON "CA"."V_PLA_INV_VIAGEM_APROV_CCEBS" TO "SISTEMAS";
  GRANT SELECT ON "CA"."V_PLA_INV_VIAGEM_APROV_CCEBS" TO "OUL";
  GRANT SELECT ON "CA"."V_PLA_INV_VIAGEM_APROV_CCEBS" TO "USUARIOS";
--------------------------------------------------------
--  DDL for View VW_CAD_CLIENTE_EBS_CUST_ACC_SITE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_CAD_CLIENTE_EBS_CUST_ACC_SITE" ("STATUS", "ORG_ID", "GLOBAL_ATTRIBUTE_CATEGORY", "GLOBAL_ATTRIBUTE2", "GLOBAL_ATTRIBUTE3", "GLOBAL_ATTRIBUTE4", "GLOBAL_ATTRIBUTE5", "GLOBAL_ATTRIBUTE6", "GLOBAL_ATTRIBUTE7", "GLOBAL_ATTRIBUTE8", "GLOBAL_ATTRIBUT10", "GLOBAL_ATTRIBUTE13", "ATTRIBUTE1", "ATTRIBUTE2", "ORIG_SYSTEM_ADDRESS_REF", "ID_PESSOA", "MATRICULA") AS 
  SELECT
    'A' status                                                                          --p_party_site_rec.status 
    ,'101' org_id                                                                       --p_cust_acct_site_rec.org_id 
    ,'JL.BR.ARXCUDCI.Additional' global_attribute_category                                                       --p_cust_acct_site_rec.global_attribute_category 
    ,decode(tp_pessoa,'F',1,'J',2,3) global_attribute2                                  --Tipo de Inscrição: `1¿ para CPF `2¿ para CNPJ `3¿ para Outros 
    ,decode(tp_pessoa,'F',lpad(a.nr_cpf,9,0),'J','raiz do CNPJ',null) global_attribute3 --Preencher com a raiz do CNPJ ou CPF (9 digitos)
    ,decode(tp_pessoa,'F','0000','J','Filial do CNPJ (4 digitos)') global_attribute4    --Preencher com o identificador Filial do CNPJ (4 digitos) Para CPF sempre será fixo `0000¿.
    ,decode(tp_pessoa,'F',lpad(pf.dv_cpf,2,0),'J','digito do CNPJ') global_attribute5    --Preencher com o digito do CNPJ ou do CPF (2 digitos)
    ,decode(tp_pessoa,'F',null,'J','Inscricao Estadual') global_attribute6              --Preencher com o código da Inscrição estadual (caso exista) ? posso colocar nullo?
    ,decode(tp_pessoa,'F',null,'J','Inscrição Municipal') global_attribute7             --Preencher com o código da Inscrição Municipal (caso exista)
    ,'NAO CONTRIBUINTE' global_attribute8                                               --Preencher com o Tipo de Contribuinte Ex: CONTRIBUINTE, NÃO CONTRIBUINTE. Conforme lista de valores de Tipos de Contribuinte utilizada pela emrpesa.
    ,null global_attribut10                                                             --Definir Preencher com Inscrição do Suframa 
    ,null global_attribute13                                                            --Preencher com o Indicador de Inscrição Estadual do Destinatário
    ,p.NM_PESSOA ATTRIBUTE1                                                             --Preencher com o Nome do Responsável Financeiro do Aluno/ Cliente
   ,lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0) ATTRIBUTE2 -- Preencher com o Número do CPF/ CNPJ do Responsável Financeiro do Aluno/ Cliente. Preencher com o número do CPF/ CNPJ do Responsável Financeiro do Aluno/ Cliente no seguinte formato: CPF: 000.000.000-00 CNPJ: 00.000.000/0000-00
   ,lpad(a.nr_cpf,9,0) || lpad(a.dv_cpf,2,0) || '_'  || lpad(a.NR_MATRICULA,7,0) ORIG_SYSTEM_ADDRESS_REF -- Número da Matrícula do Cliente
   ,p.id_pessoa
   ,lpad(a.NR_MATRICULA,7,0) matricula
    FROM
      ca.aluno a, --
      ca.cp_pessoa_fisica pf,
      ca.cp_pessoa p
    WHERE
      a.nr_cpf      = pf.nr_cpf
    AND a.dv_cpf    = pf.dv_cpf
    AND p.id_pessoa = pf.id_pessoa_fisica
    UNION
    SELECT
    'A' status                                                                          --p_party_site_rec.status 
    ,'101' org_id                                                                       --p_cust_acct_site_rec.org_id 
    ,'JL.BR.ARXCUDCI.Additional' global_attribute_category                              --p_cust_acct_site_rec.global_attribute_cate gory 
    ,decode(tp_pessoa,'F',1,'J',2,3) global_attribute2                                  --Tipo de Inscrição: `1¿ para CPF `2¿ para CNPJ `3¿ para Outros 
    ,decode(tp_pessoa,'F',lpad(a.nr_cpf,9,0),'J','raiz do CNPJ',null) global_attribute3 --Preencher com a raiz do CNPJ ou CPF (9 digitos)
    ,decode(tp_pessoa,'F','0000','J','Filial do CNPJ (4 digitos)') global_attribute4    --Preencher com o identificador Filial do CNPJ (4 digitos) Para CPF sempre será fixo `0000¿.
    ,decode(tp_pessoa,'F',lpad(pf.dv_cpf,2,0),'J','digito do CNPJ') global_attribute5    --Preencher com o digito do CNPJ ou do CPF (2 digitos)
    ,decode(tp_pessoa,'F',null,'J','Inscricao Estadual') global_attribute6              --Preencher com o código da Inscrição estadual (caso exista) ? posso colocar nullo?
    ,decode(tp_pessoa,'F',null,'J','Inscrição Municipal') global_attribute7             --Preencher com o código da Inscrição Municipal (caso exista)
    ,'NAO CONTRIBUINTE' global_attribute8                                               --Preencher com o Tipo de Contribuinte Ex: CONTRIBUINTE, NÃO CONTRIBUINTE. Conforme lista de valores de Tipos de Contribuinte utilizada pela emrpesa.
    ,null global_attribut10                                                             --Definir Preencher com Inscrição do Suframa 
    ,null global_attribute13                                                            --Preencher com o Indicador de Inscrição Estadual do Destinatário
    ,p.NM_PESSOA ATTRIBUTE1                                                             --Preencher com o Nome do Responsável Financeiro do Aluno/ Cliente
   ,lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0) ATTRIBUTE2 -- Preencher com o Número do CPF/ CNPJ do Responsável Financeiro do Aluno/ Cliente. Preencher com o número do CPF/ CNPJ do Responsável Financeiro do Aluno/ Cliente no seguinte formato: CPF: 000.000.000-00 CNPJ: 00.000.000/0000-00
   ,lpad(a.nr_cpf,9,0) || lpad(a.dv_cpf,2,0) || '_' || lpad(a.NR_MATRICULA,7,0) ORIG_SYSTEM_ADDRESS_REF -- Número da Matrícula do Cliente
   ,p.id_pessoa
   ,lpad(a.NR_MATRICULA,7,0) matricula
    FROM
      pg.aluno a,
      ca.cp_pessoa_fisica pf,
      ca.cp_pessoa p
    WHERE
      a.nr_cpf      = pf.nr_cpf
    AND a.dv_cpf    = pf.dv_cpf
    AND p.id_pessoa = pf.id_pessoa_fisica
    UNION
    SELECT
    'A' status                                                                          --p_party_site_rec.status 
    ,'101' org_id                                                                       --p_cust_acct_site_rec.org_id 
    ,'JL.BR.ARXCUDCI.Additional' global_attribute_category                              --p_cust_acct_site_rec.global_attribute_cate gory 
    ,decode(tp_pessoa,'F',1,'J',2,3) global_attribute2                                  --Tipo de Inscrição: `1¿ para CPF `2¿ para CNPJ `3¿ para Outros 
    ,decode(tp_pessoa,'F',lpad(a.nr_cpf,9,0),'J','raiz do CNPJ',null) global_attribute3 --Preencher com a raiz do CNPJ ou CPF (9 digitos)
    ,decode(tp_pessoa,'F','0000','J','Filial do CNPJ (4 digitos)') global_attribute4    --Preencher com o identificador Filial do CNPJ (4 digitos) Para CPF sempre será fixo `0000¿.
    ,decode(tp_pessoa,'F',lpad(pf.dv_cpf,2,0),'J','digito do CNPJ') global_attribute5    --Preencher com o digito do CNPJ ou do CPF (2 digitos)
    ,decode(tp_pessoa,'F',null,'J','Inscricao Estadual') global_attribute6              --Preencher com o código da Inscrição estadual (caso exista) ? posso colocar nullo?
    ,decode(tp_pessoa,'F',null,'J','Inscrição Municipal') global_attribute7             --Preencher com o código da Inscrição Municipal (caso exista)
    ,'NAO CONTRIBUINTE' global_attribute8                                               --Preencher com o Tipo de Contribuinte Ex: CONTRIBUINTE, NÃO CONTRIBUINTE. Conforme lista de valores de Tipos de Contribuinte utilizada pela emrpesa.
    ,null global_attribut10                                                             --Definir Preencher com Inscrição do Suframa 
    ,null global_attribute13                                                            --Preencher com o Indicador de Inscrição Estadual do Destinatário
    ,p.NM_PESSOA ATTRIBUTE1                                                             --Preencher com o Nome do Responsável Financeiro do Aluno/ Cliente
    ,lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0) ATTRIBUTE2 -- Preencher com o Número do CPF/ CNPJ do Responsável Financeiro do Aluno/ Cliente. Preencher com o número do CPF/ CNPJ do Responsável Financeiro do Aluno/ Cliente no seguinte formato: CPF: 000.000.000-00 CNPJ: 00.000.000/0000-00
    ,lpad(a.nr_cpf,9,0) || lpad(a.dv_cpf,2,0) || '_' || lpad(a.cd_concurso,3,0) || lpad(a.nr_ficha_requerimento,5,0) ORIG_SYSTEM_ADDRESS_REF -- Número da Matrícula do Cliente
--     ,lpad(a.nr_cpf,9,0) || lpad(a.dv_cpf,2,0) || '_' ||a.cd_inscricao_crm ORIG_SYSTEM_ADDRESS_REF -- Número da Matrícula do Cliente
    ,p.id_pessoa
    ,lpad(a.cd_concurso,3,0) || lpad(a.nr_ficha_requerimento,5,0) matricula
--      ,a.cd_inscricao_crm matricula
    FROM
      ca.candidato_work a,
      ca.cp_pessoa_fisica pf,
      ca.cp_pessoa p
    WHERE
      a.nr_cpf      = pf.nr_cpf
    AND a.dv_cpf    = pf.dv_cpf
    AND p.id_pessoa = pf.id_pessoa_fisica
;
--------------------------------------------------------
--  DDL for View VW_CAD_CLIENTE_EBS_CUST_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_CAD_CLIENTE_EBS_CUST_ACCOUNT" ("ACCOUNT_NUMBER", "STATUS", "CUSTOMER_TYPE", "ATTRIBUTE1", "ORIG_SYSTEM_REFERENCE", "ID_PESSOA", "MATRICULA") AS 
  SELECT
  account_number,
  status,
  customer_type,
  attribute1,
  orig_system_reference,
  ID_PESSOA,
  MATRICULA
FROM
  (
    SELECT --GRADUACAO
      lpad(a.nr_cpf,9,0)
      ||lpad(a.dv_cpf,2,0) account_number ,
      'A' status ,
      'R' customer_type ,
      (select codigo from vw_cad_origem_cliente where id_ori_cliente = 1) attribute1 ,
      lpad(a.nr_cpf,9,0)
      ||lpad(a.dv_cpf,2,0) orig_system_reference,
      p.id_pessoa,
      lpad(a.NR_MATRICULA,7,0) matricula
    FROM
      ca.aluno a,
      ca.cp_pessoa_fisica pf,
      ca.cp_pessoa p
    WHERE
      a.nr_cpf      = pf.nr_cpf
    AND a.dv_cpf    = pf.dv_cpf
    AND p.id_pessoa = pf.id_pessoa_fisica
    UNION
    SELECT --ESPECIALIZACAO
      lpad(a.nr_cpf,9,0)
      ||lpad(a.dv_cpf,2,0) account_number ,
      'A' status ,
      'R' customer_type ,
      (select codigo from vw_cad_origem_cliente where id_ori_cliente = 2) attribute1 , --verificar com o gustavo como pegou o campo
      lpad(a.nr_cpf,9,0)
      ||lpad(a.dv_cpf,2,0) orig_system_reference,
      p.id_pessoa,
      lpad(a.NR_MATRICULA,7,0) matricula
    FROM
      pg.aluno a,
      ca.cp_pessoa_fisica pf,
      ca.cp_pessoa p
    WHERE
      a.nr_cpf      = pf.nr_cpf
    AND a.dv_cpf    = pf.dv_cpf
    AND p.id_pessoa = pf.id_pessoa_fisica
    UNION
        SELECT --INSCRICAO VESTIBULAR
      lpad(a.nr_cpf,9,0)
      ||lpad(a.dv_cpf,2,0) account_number ,
      'A' status ,
      'R' customer_type ,
      (select codigo from vw_cad_origem_cliente where id_ori_cliente = 7) attribute1 , 
      lpad(a.nr_cpf,9,0)
      ||lpad(a.dv_cpf,2,0) orig_system_reference,
      p.id_pessoa,
     lpad(a.cd_concurso,3,0) || lpad(a.nr_ficha_requerimento,5,0) matricula
     --a.cd_inscricao_crm matricula
    FROM
      ca.candidato_work a,
      ca.cp_pessoa_fisica pf,
      ca.cp_pessoa p
    WHERE
      a.nr_cpf      = pf.nr_cpf
    AND a.dv_cpf    = pf.dv_cpf
    AND p.id_pessoa = pf.id_pessoa_fisica 
  )
WHERE
  1=1
--    and id_pessoa = :pv_id_pessoa
--    and nr_matricula = :pv_nr_matricula
;
--------------------------------------------------------
--  DDL for View VW_CAD_CLIENTE_EBS_CUST_SITE_USE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_CAD_CLIENTE_EBS_CUST_SITE_USE" ("SITE_USE_CODE", "LOCATION", "BILL_TO_SITE_USE_ID", "TERRITORY_ID", "PRIMARY_SALESREP_ID", "ORIG_SYSTEM_ADDRESS_REF", "ID_PESSOA", "MATRICULA", "ORIGEM") AS 
  SELECT
          s.site_use_code              --p_cust_site_use_rec  Este campo armazema o Tipo de endereço BILL_TO, SHIP_TO e DUN.; só permite 1 endereço de cobrança (DUN)
        , lpad(a.nr_cpf, 9, 0) || lpad(a.dv_cpf, 2, 0)  || '_'
          || lpad(a.nr_matricula, 7, 0)                           location              --p_cust_site_use_rec  Preencher código do Local, conforme definido junto a Unifor, será utilizado o Número de Matrícula do Cliente/ Aluno.
        , decode(s.site_use_code, 'SHIP_TO', 'SITE_USE_ID', NULL) bill_to_site_use_id           -- bill_to_site_use_id         
        , NULL                                                    territory_id
        , '-3'                                                    primary_salesrep_id
        , lpad(a.nr_cpf, 9, 0) || lpad(a.dv_cpf, 2, 0)  || '_'
          || lpad(a.nr_matricula, 7, 0)                           orig_system_address_ref -- Número da Matrícula do Cliente
        , p.id_pessoa                                             id_pessoa
        , lpad(a.nr_matricula, 7, 0)                              matricula
        , 'GRAD'                                                  ORIGEM        
    FROM
        ca.aluno            a,
        ca.cp_pessoa_fisica pf,
        ca.cp_pessoa        p,
        (
            SELECT
                'BILL_TO' site_use_code
            FROM
                dual
            UNION
            SELECT
                'SHIP_TO' site_use_code
            FROM
                dual
        )                   s
    WHERE
            1 = 1
        AND a.nr_cpf = pf.nr_cpf
        AND a.dv_cpf = pf.dv_cpf
        AND p.id_pessoa = pf.id_pessoa_fisica
    UNION
    SELECT
        s.site_use_code              --p_cust_site_use_rec  Este campo armazema o Tipo de endereço BILL_TO, SHIP_TO e DUN.; só permite 1 endereço de cobrança (DUN)
        , lpad(a.nr_cpf, 9, 0) || lpad(a.dv_cpf, 2, 0)  || '_'
          || lpad(a.nr_matricula, 7, 0)                             location              --p_cust_site_use_rec  Preencher código do Local, conforme definido junto a Unifor, será utilizado o Número de Matrícula do Cliente/ Aluno.
        , decode(s.site_use_code, 'SHIP_TO', 'SITE_USE_ID', NULL) bill_to_site_use_id           -- bill_to_site_use_id 
        , NULL                                                    territory_id
        , '-3'                                                    primary_salesrep_id
        , lpad(a.nr_cpf, 9, 0) || lpad(a.dv_cpf, 2, 0)  || '_'
          || lpad(a.nr_matricula, 7, 0)                           orig_system_address_ref -- Número da Matrícula do Cliente
        , p.id_pessoa                                             id_pessoa
        , lpad(a.nr_matricula, 7, 0)                              matricula
        ,'POS'                                                    ORIGEM
    FROM
        pg.aluno            a,
        ca.cp_pessoa_fisica pf,
        ca.cp_pessoa        p,
        (
            SELECT
                'BILL_TO' site_use_code
            FROM
                dual
            UNION
            SELECT
                'SHIP_TO' site_use_code
            FROM
                dual
        )                   s
    WHERE
            a.nr_cpf = pf.nr_cpf
        AND a.dv_cpf = pf.dv_cpf
        AND p.id_pessoa = pf.id_pessoa_fisica
    UNION
    SELECT
          s.site_use_code                                                                         -- p_cust_site_use_rec  Este campo armazema o Tipo de endereço BILL_TO, SHIP_TO e DUN.; só permite 1 endereço de cobrança (DUN)
        , lpad(a.nr_cpf,9,0) ||  lpad(a.dv_cpf,2,0) || '_'  
          || lpad(a.cd_concurso, 3, 0) || lpad(a.nr_ficha_requerimento, 5, 0) location            -- p_cust_site_use_rec  Preencher código do Local, conforme definido junto a Unifor, será utilizado o Número de Matrícula do Cliente/ Aluno.
--        a.cd_inscricao_crm                                                    location          -- p_cust_site_use_rec  Preencher código do Local, conforme definido junto a Unifor, será utilizado o Número de Matrícula do Cliente/ Aluno.          
        , decode(s.site_use_code, 'SHIP_TO', 'SITE_USE_ID', NULL)             bill_to_site_use_id -- bill_to_site_use_id 
        , NULL                                                                territory_id
        , '-3'                                                                primary_salesrep_id
        , lpad(a.nr_cpf,9,0) || lpad(a.dv_cpf,2,0) || '_' 
        || lpad(a.cd_concurso, 3, 0) || lpad(a.nr_ficha_requerimento, 5, 0)   orig_system_address_ref -- Número da Matrícula do Cliente
--        a.cd_inscricao_crm                                                    orig_system_address_ref
        , p.id_pessoa                                                         id_pessoa
        , lpad(a.cd_concurso, 3, 0) || lpad(a.nr_ficha_requerimento, 5, 0)    matricula
        -- a.cd_inscricao_crm                                                   matricula
        ,'CAN'                                                                ORIGEM

    FROM
        ca.candidato_work   a,
        ca.cp_pessoa_fisica pf,
        ca.cp_pessoa        p,
        (
            SELECT
                'BILL_TO' site_use_code
            FROM
                dual
            UNION
            SELECT
                'SHIP_TO' site_use_code
            FROM
                dual
        )                   s
    WHERE
            1 = 1
        AND a.nr_cpf = pf.nr_cpf
        AND a.dv_cpf = pf.dv_cpf
        AND p.id_pessoa = pf.id_pessoa_fisica
;
--------------------------------------------------------
--  DDL for View VW_CAD_CLIENTE_EBS_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_CAD_CLIENTE_EBS_LOCATION" ("COUNTRY", "ADDRESS1", "ADDRESS2", "ADDRESS3", "ADDRESS4", "STATE", "CITY", "POSTAL_CODE", "ORIG_SYSTEM_REFERENCE", "TP", "MATRICULA", "ID_PESSOA") AS 
  Select          'BR' country                                                            --p_location_rec.country 
         ,ender.ADDRESS1 ADDRESS1               --p_location_rec.address1 
         ,ender.ADDRESS2 ADDRESS2                 --p_location_rec.address2 
         ,ender.ADDRESS3 ADDRESS3                 --p_location_rec.address3 
         ,ender.ADDRESS4 ADDRESS4            --p_location_rec.address4 
         ,ender.STATE STATE                       --p_location_rec.state
         ,ender.CITY  CITY                        --p_location_rec.city 
         ,ender.POSTAL_CODE POSTAL_CODE              --p_location_rec.postal_code 
         ,pes.orig_system_reference orig_system_reference
         ,pes.tp
         ,pes.matricula
         ,pes.id_pessoa
from
(
select
--## Nao esta tratando a informaçao do PJ
        (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0)||'_' || lpad(a.nr_matricula, 7, 0)  )            orig_system_reference --########Revisar informação CNPJ p_location_rec.orig_system_reference
        , p.id_pessoa id_pessoa
        , lpad(a.nr_matricula, 7, 0)  matricula
        , 'grad' tp
         
    from   
      ca.cp_pessoa p      
      inner join ca.cp_pessoa_fisica pf on p.id_pessoa = pf.id_pessoa_fisica
      inner JOIN ca.aluno             a  ON  a.NR_CPF = PF.nr_cpf AND  a.dv_cpf = pf.dv_cpf
--      left join ca.cp_pessoa_estrangeiro pe on p.id_pessoa = pe.ID_PESSOA_ESTRANGEIRO  
Union all
  select  (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0)||'_' || lpad(pa.nr_matricula, 7, 0)  ) orig_system_reference --########Revisar informação CNPJ p_location_rec.orig_system_reference
        , p.id_pessoa id_pessoa
        , lpad(pa.nr_matricula, 7, 0)  matricula
        , 'pos' tp
    from   
      ca.cp_pessoa p      
      inner join ca.cp_pessoa_fisica pf on p.id_pessoa = pf.id_pessoa_fisica
      inner JOIN pg.aluno            pa  ON pa.NR_CPF = PF.nr_cpf AND pa.dv_cpf = pf.dv_cpf
Union all
  select (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0)||'_' ||lpad(w.cd_concurso, 3, 0) || lpad(w.nr_ficha_requerimento, 5, 0)) orig_system_reference --########Revisar informação CNPJ p_location_rec.orig_system_reference
        -- (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0)||'_' || CD_INSCRICAO_CRM  )                                            orig_system_reference --########Revisar informação CNPJ p_location_rec.orig_system_reference
        , p.id_pessoa id_pessoa
        --, w.CD_INSCRICAO_CRM  matricula
        , lpad(w.cd_concurso, 3, 0) || lpad(w.nr_ficha_requerimento, 5, 0) matricula
        , 'cand' tp        
    from   
      ca.cp_pessoa p      
      inner join ca.cp_pessoa_fisica pf on p.id_pessoa = pf.id_pessoa_fisica
      inner join ca.candidato_work    w  on  w.NR_CPF = PF.nr_cpf AND  w.dv_cpf = pf.dv_cpf and w.CD_INSCRICAO_CRM is not null
) pes
      inner join (SELECT max(pl.ID_PESSOA_LOGRADOURO) ID_PESSOA_LOGRADOURO, pl.id_pessoa 
                    from ca.cp_pessoa_logradouro pl 
                   where 1=1 
                   --and fl_ativo = 'S' 
                   and (nr_cep<>60165121 and nm_logradouro<>'Av. Beira Mar, 3400' and nr_endereco<>'3400')
                   group by pl.id_pessoa) log
       on log.id_pessoa = pes.id_pessoa     
      inner join (SELECT pl.ID_PESSOA_LOGRADOURO
                    , (nm_tipo_logradouro || ' ' || nm_logradouro) as ADDRESS1
                    , nr_endereco as ADDRESS2
                    , (ds_complemento) as ADDRESS3
                    , (nm_bairro) as ADDRESS4
                    , (nm_localidade) as CITY
                    , (cd_uf) as STATE
                    , regexp_replace(lpad(nr_cep, 8, '0'), '([[:digit:]]{2})([[:digit:]]{3})([[:digit:]]{3})', '\1.\2-\3') as POSTAL_CODE
                    , 'BR' as COUNTRY
                    , fl_ativo
                    from 
                        ca.cp_pessoa_logradouro pl
                    where 
                        1=1 
                        --and fl_ativo = 'S'
                        and (nr_cep<>60165121 and nm_logradouro<>'Av. Beira Mar, 3400' and nr_endereco<>'3400')
                        and pl.CD_FAIXA_TP_ENDERECO = 2  
                        order by pl.id_pessoa_logradouro desc
                        ) ender on ender.ID_PESSOA_LOGRADOURO = log.ID_PESSOA_LOGRADOURO
;
--------------------------------------------------------
--  DDL for View VW_CAD_CLIENTE_EBS_ORGANIZATION
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_CAD_CLIENTE_EBS_ORGANIZATION" ("ORGANIZATION_TYPE", "ORGANIZATON_NAME", "ORGANIZATION_NAME_PHONETIC", "ORIG_SYSTEM_REFERENCE", "ID_PESSOA") AS 
  SELECT
    organization_type ,
    organizaton_name ,
    organization_name_phonetic ,
    orig_system_reference,
    id_pessoa
  FROM
    (
      SELECT DISTINCT
        p.id_pessoa AS id_pessoa ,
        'ORGANIZATION' organization_type ,
        p.NM_PESSOA organizaton_name ,
        NVL(pf.nm_social, p.nm_pessoa) organization_name_phonetic ,
        lpad(pf.nr_cpf,9,0)
        ||lpad(pf.dv_cpf,2,0)orig_system_reference
      FROM
        ca.cp_pessoa_fisica pf,
        ca.cp_pessoa p
      WHERE
        p.id_pessoa = pf.id_pessoa_fisica
      UNION 
      SELECT DISTINCT
        p.id_pessoa AS id_pessoa ,
        'ORGANIZATION' organization_type ,
        p.NM_PESSOA organizaton_name ,
        NVL(p.nm_reduzido_pessoa, p.nm_pessoa) organization_name_phonetic ,
        lpad(pj.nr_cnpj,12,0)
        || lpad(pj.dv_cnpj,2,0) orig_system_reference
      FROM
        ca.cp_pessoa p,
        ca.cp_pessoa_juridica pj
      WHERE
        p.id_pessoa = pj.id_pessoa_juridica
         UNION 
      SELECT DISTINCT
        p.id_pessoa AS id_pessoa ,
        'ORGANIZATION' organization_type ,
        p.NM_PESSOA organizaton_name ,
        NVL(p.nm_reduzido_pessoa, p.nm_pessoa) organization_name_phonetic ,
        decode( pe.nr_cpf, null, pe.nr_passaporte,lpad(pe.nr_cpf,9,0)||lpad(pe.dv_cpf,2,0)) orig_system_reference
      FROM
        ca.cp_pessoa p,
        ca.v_cp_pessoa_estrangeiro pe
      WHERE
        p.id_pessoa = pe.id_pessoa_estrangeiro    )
  WHERE
    1=1
    --and id_pessoa = :pv_id_pessoa
;
--------------------------------------------------------
--  DDL for View VW_GVS_APPLY
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_GVS_APPLY" ("P_CUSTOMER_TRX_NUMBER", "P_AMOUNT_APPLIED", "P_APPLY_DATE", "P_APPLY_GL_DATE", "P_TERMS_SEQUENCE_NUMBER", "P_GLOBAL_ATTRIBUTE_CATEGORY", "P_GLOBAL_ATTRIBUTE1", "P_GLOBAL_ATTRIBUTE2", "P_GLOBAL_ATTRIBUTE4", "P_GLOBAL_ATTRIBUTE5", "P_GLOBAL_ATTRIBUTE6") AS 
  select  
 t.id_titulo     as p_customer_trx_number -- Número da transação na qual deseja aplicar o recebimento.
,'1'             as p_amount_applied  -- Valor do recebimento a ser aplicado na transação.
,'1'             as p_apply_date -- Data da aplicação do recebimento.
,'1'             as p_apply_gl_date-- Data GL da aplicação do recebimento.
,'1'             as p_terms_sequence_number --Número da parcela da transação Número de parcela foi definida na integração de transação Esse número significa em quantas vezes foi parcelado o titulo? No uol sempre será uma parcela. 
,'JL.BR.ARXRWMAI.Additional Info'  as p_global_attribute_category -- Fixo: JL.BR.ARXRWMAI.Additional Info
,'1'             as p_global_attribute1 --Valor recebido na parcela da transação.
,'TOTAL'         as p_global_attribute2 --Fixo: TOTAL
,'1'             as p_global_attribute4 --Valor de juros pagos pelo cliente para a parcela da transação. Caso não tenha juros, informar valor 0,00.
,'1'             as p_global_attribute5 --Caso a transação esteja vencida e o cliente não tenha realizado o pagamento total dos juros calculados, informar o valor: ¿WRITEOFF¿. Caso a transação não tenha juros ou o cliente tenha pagado o valor total dos juros calculados, deixar nulo.
,'1'             as p_global_attribute6 --Caso seja informado o valor ¿WRITEOFF¿ no p_global_attribute5, informar o motivo da dispensa de juros, conforme informado pelo usuário. Caso a transação não tenha juros ou o cliente tenha pagado o valor total dos juros calculados, deixar nulo.

from 
    ca.ctr_titulo t
;
--------------------------------------------------------
--  DDL for View VW_GVS_CREATE_CASH
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_GVS_CREATE_CASH" ("P_CURRENCY_CODE", "P_AMOUNT", "P_RECEIPT_NUMBER", "P_GL_DATE", "P_CUSTOMER_NAME", "P_RECEIPT_METHOD_NAME", "P_ATTRIBUTE_CATEGORY", "P_ATTRIBUTE1", "P_ATTRIBUTE2", "P_ATTRIBUTE3", "P_ATTRIBUTE4", "P_ATTRIBUTE5", "ID_TITULO") AS 
  select
 'BRL'           as p_currency_code -- Fixo: BRL
,t.vl_original  as p_amount --Informar o valor total do recebimento a ser criado.
,'1'             as p_receipt_number --Informar o número do recebimento a ser criado. Esse número deverá ser único.
,'1'             as p_gl_date --Informar a data GL do recebimento. A data GL informada deverá ser igual a data do recebimento e deverá estar em um período GL aberto.
,'1'             as p_customer_name --Informar o número do cliente para o qual o recebimento será criado. Para recuperar o número do cliente, utilizar a consulta abaixo, onde &Customer_name deverá ser o nome do cliente informado pelo UOL.
,'1'             as p_receipt_method_name -- Recuperar o id do método de recebimento, de acordo com o nome do método informado pelo UOL. 
,'1'             as p_attribute_category    --CARTAO DE CREDITO 
,'1'             as p_attribute1            -- Bandeira Cartão
,'1'             as p_attribute2            --Condição de Pagamento
,'1'             as p_attribute3            --Quatro Últimos Dígitos do Cartão
,'1'             as p_attribute4            --Cod. Autorização
,'1'             as p_attribute5            --NSU
,t.id_titulo
from 
    ca.ctr_titulo t
;
--------------------------------------------------------
--  DDL for View VW_GVS_TRX_HEADER
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_GVS_TRX_HEADER" ("TRX_NUMBER", "TRX_DATE", "GL_DATE", "TRX_CURRENCY", "CUST_TRX_TYPE_NAME", "BILL_TO_CUSTOMER_REF", "BILL_TO_ADDRESS_REF", "SHIP_TO_CUSTOMER_REF", "SHIP_TO_ADDRESS_REF", "TERM_NAME", "PRIMARY_SALESREP_ID", "RECEIPT_METHOD_NAME", "ATTRIBUTE_CATEGORY", "ATTRIBUTE1", "ATTRIBUTE2", "ATTRIBUTE3", "ATTRIBUTE4", "ATTRIBUTE5", "ATTRIBUTE6", "ATTRIBUTE7", "ATTRIBUTE8", "ATTRIBUTE9", "ATTRIBUTE10", "GLOBAL_ATTRIBUTE_CATEGORY", "HEADER_GDF_ATTRIBUTE1", "HEADER_GDF_ATTRIBUTE2", "HEADER_GDF_ATTRIBUTE3", "HEADER_GDF_ATTRIBUTE4", "HEADER_GDF_ATTRIBUTE5", "INTERFACE_HEADER_CONTEXT", "INTERFACE_HEADER_ATTRIBUTE1", "INTERFACE_HEADER_ATTRIBUTE2", "INTERFACE_HEADER_ATTRIBUTE3", "INTERFACE_HEADER_ATTRIBUTE4", "INTERFACE_HEADER_ATTRIBUTE5", "INTERFACE_HEADER_ATTRIBUTE6", "INTERFACE_HEADER_ATTRIBUTE7", "INTERFACE_HEADER_ATTRIBUTE8", "INTERFACE_HEADER_ATTRIBUTE9", "INTERFACE_HEADER_ATTRIBUTE10", "INTERFACE_HEADER_ATTRIBUTE11", "INTERFACE_HEADER_ATTRIBUTE12", "INTERFACE_HEADER_ATTRIBUTE13", "INTERFACE_HEADER_ATTRIBUTE14", "INTERFACE_HEADER_ATTRIBUTE15", "ID_TITULO") AS 
  select 
to_char(t.id_titulo) as trx_number				      --				Null			Este é o número da transação para a fatura, de acordo com o número da transação do UOL.
,t.dt_hr_inclusao as trx_date			      --				Null			Data de emissão da transação no UOL.
,t.dt_hr_inclusao as gl_date			      --				Null			Data de contabilização da transação. Deve ser a mesma data da transação.
,'BRL' as trx_currency					      --			    Null			Fixo: BRL.
,(SELECT RCTA.NAME FROM RA_CUST_TRX_TYPES_ALL@ebsunifor RCTA WHERE RCTA.CREATED_BY <> -1 AND END_DATE IS NULL and name ='INSCR_PROC_SELETIVO') --Tirar consulta via DBLINK
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
           end ||'_'|| t.nr_matric_cliente as bill_to_address_ref			      	--				Null			ID do endereço de faturamento do cliente. Isso deve existir em hz_cust_acct_sites para o ID de faturamento do cliente preenchido.
,case 
           when p.tp_pessoa = 'F' then (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0))  
           when p.tp_pessoa = 'J' then 'Juridica'
           when p.tp_pessoa = 'E' then decode( pe.nr_cpf, null, pe.nr_passaporte,lpad(pe.nr_cpf,9,0)||lpad(pe.dv_cpf,2,0))
           end ||'_'|| t.nr_matric_cliente as ship_to_customer_ref			      	--				    			Entregar para o ID do cliente. Isso deve existir na tabela hz_cust_accounts. O cliente deve ser um cliente ativo ('A'). Validado em relação a hz_cust_accounts.cust_account_id.  #Consultar no EBS
,case 
           when p.tp_pessoa = 'F' then (lpad(pf.nr_cpf,9,0)||lpad(pf.dv_cpf,2,0))  
           when p.tp_pessoa = 'J' then 'Juridica'
           when p.tp_pessoa = 'E' then decode( pe.nr_cpf, null, pe.nr_passaporte,lpad(pe.nr_cpf,9,0)||lpad(pe.dv_cpf,2,0))
           end ||'_'|| t.nr_matric_cliente as ship_to_address_ref			      	--				Null			ID do endereço de entrega do cliente. Isso deve existir em hz_cust_acct_sites para o ID de faturamento do cliente preenchido.#Consultar no EBS
,to_date(to_char(t.dt_vencimento,'dd/mm/yyyy'))-to_date(to_char(t.dt_hr_inclusao,'dd/mm/yyyy'))||'DD'--(SELECT RT.NAME FROM APPS.RA_TERMS@ebsunifor RT WHERE CREATED_BY <> -1 AND END_DATE_ACTIVE IS NULL and name ='31DD') 
    as term_name			           	      	--				Null			Identificador de Condições de Pagamento. O Term ID deve ser válido para a data da transação. Se não for preenchido, ele será recuperado de ra_terms com base em bill_to_customer_id e bill_to_site_use_id.#Consultar no EBS
,'-3' as primary_salesrep_id			      	--				Null			Fixo: -3
,(SELECT ARM.NAME FROM AR_RECEIPT_METHODS@ebsunifor ARM WHERE ARM.CREATED_BY <> 1 AND ARM.END_DATE IS NULL and name = 'BRAD_0452_311356_CART')  --Tirar consulta via DBLINK
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
,30  as HEADER_GDF_ATTRIBUTE3       				--			Null			Períod o de Juros. Fixo: 30.
,'S' as HEADER_GDF_ATTRIBUTE4       			--				Null			Fórmula de Juros. Fixo: S
, 2  as HEADER_GDF_ATTRIBUTE5       				--			Null			Dias de Tolerência. Fixo: 2
,case t.cd_faixa_st_titulo
    when 1 then 'UOL ND' 
    when 2 then 'UOL ND'
    when 3 then 'UOL NC'
 end  as interface_header_context 		--				Null			De acordo com as regras definidas para Primary Keys. #Verifcar Regra no documento.
,'065_UNF'   as interface_header_attribute1	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,'100_UNF'   as interface_header_attribute2	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,t.id_titulo as interface_header_attribute3	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,'X' as interface_header_attribute4	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,'X' as interface_header_attribute5	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,'X' as interface_header_attribute6	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,'X' as interface_header_attribute7	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute8	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute9	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute10	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute11	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute12	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute13	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute14	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.
,null as interface_header_attribute15	        --				Null	        De acordo com a Regra 2#, descrita ao final da tabela.   #Verifcar Regra no documento.

--,'065_UNF'      as INTERFACE_LINE_ATTRIBUTE1 --                                 Código da empresa concatenado com Descrição: EXEMPLO: 065_UNF	
--,'100_UNF'      as INTERFACE_LINE_ATTRIBUTE2 --                                 Código da filial concatenado com _Descrição: EXEMPLO: 100_UNF	
--,t.id_titulo    as INTERFACE_LINE_ATTRIBUTE3 --                                 Número da Nota Fiscal ¿ FATURA/DUPLICATA, Número da Nota de Débito (Para ND) ou Crédito (Para NC) e Número do Banco (Para Cheque Pré-datado ou Devolvido).	
--,'2'            as INTERFACE_LINE_ATTRIBUTE4 --                                 Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
, t.id_titulo
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
--------------------------------------------------------
--  DDL for View VW_GVS_TRX_LINE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CA"."VW_GVS_TRX_LINE" ("LINE_NUMBER", "DESCRIPTION", "QUANTITY_ORDERED", "QUANTITY_INVOICED", "UNIT_STANDARD_PRICE", "UNIT_SELLING_PRICE", "LINE_TYPE", "ATTRIBUTE_CATEGORY", "ATTRIBUTE1", "ATTRIBUTE2", "ATTRIBUTE3", "ATTRIBUTE4", "ATTRIBUTE5", "ATTRIBUTE6", "ATTRIBUTE7", "ATTRIBUTE8", "ATTRIBUTE9", "ATTRIBUTE10", "ATTRIBUTE11", "ATTRIBUTE12", "ATTRIBUTE13", "ATTRIBUTE14", "ATTRIBUTE15", "INTERFACE_LINE_CONTEXT", "INTERFACE_LINE_ATTRIBUTE1", "INTERFACE_LINE_ATTRIBUTE2", "INTERFACE_LINE_ATTRIBUTE3", "INTERFACE_LINE_ATTRIBUTE4", "INTERFACE_LINE_ATTRIBUTE5", "INTERFACE_LINE_ATTRIBUTE6", "INTERFACE_LINE_ATTRIBUTE7", "INTERFACE_LINE_ATTRIBUTE8", "INTERFACE_LINE_ATTRIBUTE9", "INTERFACE_LINE_ATTRIBUTE10", "INTERFACE_LINE_ATTRIBUTE11", "INTERFACE_LINE_ATTRIBUTE12", "INTERFACE_LINE_ATTRIBUTE13", "INTERFACE_LINE_ATTRIBUTE14", "INTERFACE_LINE_ATTRIBUTE15", "AMOUNT", "TAX_RATE", "UOM_CODE", "TAX_EXEMPT_FLAG", "LINE_GDF_ATTRIBUTE1", "LINE_GDF_ATTRIBUTE2", "LINE_GDF_ATTRIBUTE3", "LINE_GDF_ATTRIBUTE4", "LINE_GDF_ATTRIBUTE5", "LINE_GDF_ATTRIBUTE6", "LINE_GDF_ATTRIBUTE7", "LINE_GDF_ATTRIBUTE8", "LINE_GDF_ATTRIBUTE9", "LINE_GDF_ATTRIBUTE10", "LINE_GDF_ATTRIBUTE11", "LINE_GDF_ATTRIBUTE12", "LINE_GDF_ATTRIBUTE13", "LINE_GDF_ATTRIBUTE14", "LINE_GDF_ATTRIBUTE15", "LINE_GDF_ATTRIBUTE16", "LINE_GDF_ATTRIBUTE17", "LINE_GDF_ATTRIBUTE18", "LINE_GDF_ATTRIBUTE19", "LINE_GDF_ATTRIBUTE20", "GLOBAL_ATTRIBUTE_CATEGORY", "AMOUNT_INCLUDES_TAX_FLAG", "WAREHOUSE_ID", "ID_TITULO") AS 
  select
 --null   as trx_header_id               			-- number    yes   	identificador para o registro do cabeçalho da fatura. isso deve ser exclusivo para cada registro. #Pode ser um sequencial unico qualquer?
--,null   as trx_line_id                 			-- number    yes   	identificador das linhas da transação. #Qual identificar é esse?
--,null   as link_to_trx_line_id         			-- number          	esta coluna é necessária apenas se o tipo de linha for tax e freight (se estiver associado a qualquer linha). para as linhas do tipo tax, informar o trx_line_id da linha do tipo line.
RANK() OVER(PARTITION BY m.id_modalidade ORDER BY m.id_modalidade)   as line_number                 			-- number    yes   	sequencial do número da linha da invoice. #COnsultar EBS?
,nvl(m.nm_modalidade,(
                    select 
                        re.ds_requerimento 
                    from    
                        sa.processo p inner join
                        sa.requerimento re on re.cd_requerimento = p.cd_requerimento
                    where 
                        nr_processo = t.nr_processo ))  as description                 			-- varchar2 (240)  	descrição da linha da transação, validado de acordo com o campo name.ar_memo_lines_all_tl. #verificar. Acredito que terá as formas de composição do titulo que deveremos consultar.
,1      as quantity_ordered            			-- number          	fixo: 1
,1      as quantity_invoiced           			-- number          	fixo: 1 
,TO_CHAR (nvl(mctm.vl_modalidade,t.vl_original),'999999D99MI','NLS_NUMERIC_CHARACTERS = '',.''')   as unit_standard_price			-- number          	valor unitário do item, com duas casas decimais.
,TO_CHAR (nvl(mctm.vl_modalidade,t.vl_original),'999999D99MI','NLS_NUMERIC_CHARACTERS = '',.''')   as unit_selling_price 			-- number          	valor unitário do item, com duas casas decimais.
,'LINE' as line_type                   			-- varchar2(20)    	yes informar:line, para linhas de itens. tax, para linhas de impostos.
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
,case t.cd_faixa_st_titulo
    when 1 then 'UOL ND' -- em aberto
    when 2 then 'UOL ND' -- em aberto parcial
    when 7 then 'UOL NC' -- cancelado
 end as interface_line_context    			-- varchar2(30)    	de acordo com as regras definidas para primary keys.
--,null as interface_line_attribute1_15 		-- varchar2(30)    	de acordo com a regra 1#, descrita ao final da tabela.
,'065_UNF'      as INTERFACE_LINE_ATTRIBUTE1 	--                  Código da empresa concatenado com Descrição: EXEMPLO: 065_UNF	
,'100_UNF'      as INTERFACE_LINE_ATTRIBUTE2 	--                  Código da filial concatenado com _Descrição: EXEMPLO: 100_UNF	
,t.id_titulo    as INTERFACE_LINE_ATTRIBUTE3 	--                  Número da Nota Fiscal ¿ FATURA/DUPLICATA, Número da Nota de Débito (Para ND) ou Crédito (Para NC) e Número do Banco (Para Cheque Pré-datado ou Devolvido).	
,'X'             as INTERFACE_LINE_ATTRIBUTE4 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'             as INTERFACE_LINE_ATTRIBUTE5 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE6 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE7 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE8 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE9 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE10 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE11 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE12 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE13 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE14 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,'X'            as INTERFACE_LINE_ATTRIBUTE15 	--                  Subsérie da NF para Fatura/Duplicata,Tipo (Para Nota de Débito ou Crédito), Número da Agência (Para Cheque Devolvido ou Pré-datado). Caso o campo for NULO, enviar o valor ¿X¿.
,TO_CHAR (nvl(mctm.vl_modalidade,t.vl_original),'999999D99MI','NLS_NUMERIC_CHARACTERS = '',.''') as amount              			-- number           valor da linha.
,decode('tipo_transacao','TAX','txaImposto',null) as tax_rate    -- number           taxa de imposto. obrigatório para a linha tax.
--,null as memo_line_id                 		-- number           identificador do item de linha. preencher apenas para linhas do tipo  line. #verificar no EBS
,'UN' as uom_code                     			-- varchar2(3)      unidade de medida. #Quais as unidades disponiveis? 'UN'
--,null as vat_tax_id                   		-- number           identificador do código de imposto (ar_vat_tax). obrigatório para linhas do tipo tax.
,decode('tipo_transacao','TAX','Y',null) as tax_exempt_flag  	-- varchar2(1)      fixo: y para linhas do tipo tax. nulo para linhas do do tipo line.
--,null as global_attribute1_20_20    			-- varchar2 (150)   preencher de acordo com a regra 2#, descrita no final da tabela.
,'5949' as LINE_GDF_ATTRIBUTE1        			-- 					CFOP da nota fiscal. Para os demais tipos de transação informar o CFOP 5949.
,'00000000' as LINE_GDF_ATTRIBUTE2 				--					Código da Classificação Fiscal do Item da nota fiscal. Para os demais tipos de transação, diferentes de NFF, informa Fixo: `00000000¿.
,'FABRICACAO PROPRIA' as LINE_GDF_ATTRIBUTE3 	--					CLASSE DE CONDICAO DA TRANSACAO (Utilização da Mercadoria). Informar a classe da condição da transação das NFFs. Para os demais tipos de transação informar fixo: FABRICACAO PROPRIA;
,'0'  as LINE_GDF_ATTRIBUTE4  					-- 					ORIGEM DO ITEM: 0=NACIONAL OU 1=IMPORTADO 2=IMPORTADO ADQ. NO MERCADO INTERNO.
,'B'  as LINE_GDF_ATTRIBUTE5  					-- 					TIPO FISCAL DO ITEM. Fixo: B.
,'00' as LINE_GDF_ATTRIBUTE6                    -- 					SITUACAO TRIBUTÁRIA FEDERAL. Situação Tributária Federal da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `00¿.
,'0' as LINE_GDF_ATTRIBUTE7                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE8                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE9                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE10                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE11                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE12                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE13                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE14                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE15                    -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE16                    -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE17                    -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE18                    -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE19                    -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'0' as LINE_GDF_ATTRIBUTE20                     -- 					SITUACAO TRIBUTÁRIA ESTADUAL. Situação Tributária Estadual da NFF. Para os demais tipos de transação diferentes de NFF, informar fixo: `0¿.
,'jl.br.arxtwmai.additional info' as global_attribute_category    -- varchar2(30)     fixo: jl.br.arxtwmai.additional info
,decode('tipo_transacao','TAX_inclusivo','Y',null) as amount_includes_tax_flag -- varchar2(1)      informar y para impostos inclusivos, nas linhas do tipo tax. para as demais linhas deixar nulo.
,123  as warehouse_id                 			-- number           fixo: 123
,t.id_titulo

from 
    ca.ctr_titulo t	left join
    ca.fat_mc_titulo mct on mct.id_titulo = t.id_titulo left join
    ca.fat_mc_titulo_modalidade mctm on mctm.id_mc_titulo = mct.id_mc_titulo left join
    ca.fat_modalidade m on m.id_modalidade = mctm.id_modalidade_cobranca
;
