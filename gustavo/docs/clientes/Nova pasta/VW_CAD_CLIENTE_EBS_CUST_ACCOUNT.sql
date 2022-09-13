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
