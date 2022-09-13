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
