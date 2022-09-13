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
