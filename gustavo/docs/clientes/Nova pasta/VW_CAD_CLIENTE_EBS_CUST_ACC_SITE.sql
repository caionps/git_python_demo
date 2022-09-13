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
