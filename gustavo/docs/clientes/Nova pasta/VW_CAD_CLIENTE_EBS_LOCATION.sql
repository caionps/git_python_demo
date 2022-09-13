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
