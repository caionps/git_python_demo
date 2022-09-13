--Cadastro de cliente de um candidato do CRM 
-->pk_cad_cliente_ebs_api.p_integra_cliente_ebs

--Cliente Novo (Parte; Conta; Site) 
--um candidato que não foi entegrado ao EBS e possui id_pessoa
SELECT pl.id_pessoa_logradouro, LPAD(W.CD_CONCURSO,3,0) || LPAD(W.NR_FICHA_REQUERIMENTO,5,0)  matricula, pf.id_pessoa_fisica id_pessoa,  w.* --, pl.*
FROM CA.candidato_work W 
INNER JOIN CA.CP_PESSOA_FISICA PF ON PF.NR_CPF=W.NR_CPF 
inner join ca.cp_pessoa_logradouro pl on pf.id_pessoa_fisica = pl.id_pessoa
WHERE 1=1
--AND CD_CONCURSO between ( 600) and (631) --concursos mais recentes
  and not exists(  select *  
                 from HZ_CUST_ACCOUNTS@ebsunifor t
                where creation_date > '01/08/2022'
                  and t.account_number = lpad(PF.NR_CPF,9,0)||lpad(pf.dv_cpf,2,0) )
ORDER BY CD_CONCURSO DESC, NR_FICHA_REQUERIMENTO DESC
--Já testei:   
-->>P_NR_MATRICULA := 'CAN-7220-EAD'	P_ID_PESSOA := 153435 ; erro  153435
-->>P_NR_MATRICULA := 63100084          P_ID_PESSOA := 366106 ; -- LUANA MELO DA SILVA	ok
-->>P_NR_MATRICULA := 63100041 ;        P_ID_PESSOA := 74190  ; OK
-->>P_NR_MATRICULA :=  ;        P_ID_PESSOA := 71059 ERRO
;


--Cliente Existente (Parte; Conta; Site)
--um candidato que foi entegrado ao EBS e possui id_pessoa
--Repetir com cliente integrado
SELECT w.NM_CANDIDATO, w.dt_alteracao, w.cd_concurso,W.CD_INSCRICAO_CRM matricula, pf.id_pessoa_fisica id_pessoa
FROM CA.candidato_work W 
INNER JOIN CA.CP_PESSOA_FISICA PF ON PF.NR_CPF=W.NR_CPF and pf.dv_cpf=w.dv_cpf
--inner join ca.cp_pessoa_usuario pu on pf.id_pessoa_fisica = pu.id_pessoa
WHERE CD_CONCURSO between ( 600) and (631) --concursos mais recentes
  and exists(  select *  
                 from HZ_CUST_ACCOUNTS@ebsunifor t
                where creation_date > '01/08/2022'
                  and t.account_number = lpad(PF.NR_CPF,9,0)||lpad(pf.dv_cpf,2,0) )
--and W.CD_INSCRICAO_CRM is not null       
ORDER BY CD_CONCURSO DESC, NR_FICHA_REQUERIMENTO DESC
;
--Aluno existe
--Cliente Novo (Parte; Conta; Site) 
--um aluno graduação que não foi entegrado ao EBS e possui id_pessoa e endereço
SELECT pl.id_pessoa_logradouro, w.nr_matricula matricula, pf.id_pessoa_fisica id_pessoa,  w.*, pl.*
FROM CA.aluno W 
INNER JOIN CA.CP_PESSOA_FISICA PF ON PF.NR_CPF=W.NR_CPF 
inner join ca.cp_pessoa_logradouro pl on pf.id_pessoa_fisica = pl.id_pessoa
WHERE 1=1 and substr(w.nr_matricula,1,3) = 221
  and not exists(  select *  
                 from HZ_CUST_ACCOUNTS@ebsunifor t
                where creation_date > '01/08/2022'
                  and t.account_number = lpad(PF.NR_CPF,9,0)||lpad(pf.dv_cpf,2,0) )
ORDER BY w.nr_matricula DESC
--Já testei:   
-->>   P_NR_MATRICULA := 2219528	;  P_ID_PESSOA := 133343; ok

;
--INTEGRA FINANCEIRO CRM
-->pk_financeiro_crm_api.gerar_financeiro_inscricao

--set SERVEROUTPUT on;

select * from ca.cad_integra_cliente_log_ebs cicle order by creation_date desc;

