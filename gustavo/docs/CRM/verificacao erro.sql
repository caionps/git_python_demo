--P_DS_ERRO =     Erro no pk_ctr_processo_clc.p_criar_processo - p_cd_requerimento = 134 
--                p_vl_unitario_requerimento= 300 
--                p_id_pessoa= 378173 
--                p_dt_vencimento= 04/12/22 
--                Motivo: ORA-20600: ORA-06512: em "CA.PK_CTR_TITULO_CLC", line 1201
--                error - ORA-04063: package body "CA.PK_CTR_CONTABILIZA_CLC" contém erros
--                ORA-06508: PL/SQL Inscrição CRM : CAN-176336-UN
--p_id_pessoa = 378173

select * from ca.cp_pessoa_fisica pf
where pf.id_pessoa_fisica = 378173
or pf.nr_cpf = 70626553
;
--378153 com o cpf 274094550
--CAN-176336-UN
select * from ca.candidato_work w where w.cd_inscricao_crm like  'CAN-176336-UNI' 
matricula: 61901029
;