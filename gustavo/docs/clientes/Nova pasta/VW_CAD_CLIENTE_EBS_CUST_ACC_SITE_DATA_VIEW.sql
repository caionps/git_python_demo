--------------------------------------------------------
--  Arquivo criado - sábado-setembro-10-2022   
--------------------------------------------------------
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
      ca.aluno a,
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
                   group by pl.id_pessoa) log
       on log.id_pessoa = pes.id_pessoa     
      inner join (SELECT pl.ID_PESSOA_LOGRADOURO
                    , upper(TRIM(nm_tipo_logradouro || ' ' || nm_logradouro)) as ADDRESS1
                    , nr_endereco as ADDRESS2
                    , ds_complemento as ADDRESS3
                    , nm_bairro as ADDRESS4
                    , nm_localidade as CITY
                    , cd_uf as STATE
                    , regexp_replace(lpad(nr_cep, 8, '0'), '([[:digit:]]{2})([[:digit:]]{3})([[:digit:]]{3})', '\1.\2-\3') as POSTAL_CODE
                    , 'BR' as COUNTRY
                    , fl_ativo
                    from 
                        ca.cp_pessoa_logradouro pl
                    where 
                        1=1 
                        --and fl_ativo = 'S'
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
