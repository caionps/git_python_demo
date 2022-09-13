--------------------------------------------------------
--  Arquivo criado - sábado-setembro-10-2022   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package PK_CAD_CLIENTE_EBS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CA"."PK_CAD_CLIENTE_EBS_API" AS  
   
procedure p_integra_cliente_ebs   
( p_nr_matricula               in varchar2 --ca.fat_financeiro.nr_matricula%type
, p_id_pessoa                  in ca.cp_pessoa.id_pessoa%type
, p_fg_retorno                 out varchar2
, p_ds_retorno                 out varchar2
);

end pk_cad_cliente_ebs_api;

/
--------------------------------------------------------
--  DDL for Package PK_CAD_CLIENTE_EBS_CLC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CA"."PK_CAD_CLIENTE_EBS_CLC" AS

  ----------------------------------------------------------------------------------------------------
  -- Public Types
  ----------------------------------------------------------------------------------------------------   
  --
  --subtype organization_rec is ca.pk_gvs_cliente_ebs_plt.organization_rec; 
  --type arr_organization is table of organization_rec; 
  --erro_integracao_ebs exception;
  ---------------------------------------------------------------------------------------------------- 
   
procedure p_integra_cliente_ebs   
( p_nr_matricula               in varchar2 --ca.fat_financeiro.nr_matricula%type
, p_id_pessoa                  in ca.cp_pessoa.id_pessoa%type
, p_organization_rec           in out nocopy ca.pk_cad_cliente_ebs_plt.organization_rec 
, p_cust_account_rec           in out nocopy ca.pk_cad_cliente_ebs_plt.cust_account_rec
, p_location_rec               in out nocopy ca.pk_cad_cliente_ebs_plt.location_rec
, p_cust_acct_site_rec         in out nocopy ca.pk_cad_cliente_ebs_plt.cust_acct_site_rec
, p_cust_site_use_rec          in out nocopy ca.pk_cad_cliente_ebs_plt.cust_site_use_rec
, p_customer_profile_rec       in out nocopy ca.pk_cad_cliente_ebs_plt.customer_profile_rec
, p_payment_method_rec         in out nocopy ca.pk_cad_cliente_ebs_plt.payment_method_rec
, p_person_rec                 in out nocopy ca.pk_cad_cliente_ebs_plt.person_rec
, p_relationship_rec           in out nocopy ca.pk_cad_cliente_ebs_plt.relationship_rec
, p_contact_point_rec          in out nocopy ca.pk_cad_cliente_ebs_plt.contact_point_rec
, p_phone_rec                  in out nocopy ca.pk_cad_cliente_ebs_plt.phone_rec
, p_email_rec                  in out nocopy ca.pk_cad_cliente_ebs_plt.email_rec 
, p_exit_rec                   in out nocopy ca.pk_cad_cliente_ebs_plt.exit_rec
, p_json                       out clob
, p_nr_transacao               out number
, p_fg_retorno                 out varchar2
, p_ds_retorno                 out varchar2
);
-- 
END PK_CAD_CLIENTE_EBS_CLC;

/
--------------------------------------------------------
--  DDL for Package PK_CAD_CLIENTE_EBS_DML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CA"."PK_CAD_CLIENTE_EBS_DML" as 

PROCEDURE p_inserir_cad_integra_cliente_log_ebs   ( p_json       in clob
                                                   ,p_tipo_transacao in varchar2
                                                   ,p_nr_transacao in out varchar2
                                                   ,p_integrado in varchar2
                                                   ,p_st_retorno OUT VARCHAR2
                                                   ,p_ds_retorno OUT CLOB) ;

end PK_CAD_CLIENTE_EBS_DML;

/
--------------------------------------------------------
--  DDL for Package PK_CAD_CLIENTE_EBS_JSN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CA"."PK_CAD_CLIENTE_EBS_JSN" as 

function  f_json_cliente_ebs_out (p_exit_rec in  ca.pk_cad_cliente_ebs_plt.exit_rec) 
return clob ;

function  f_json_cliente_ebs_in  (p_nr_matricula               in  varchar2 
                                , p_id_pessoa                  in  ca.cp_pessoa.id_pessoa%type  
                                , p_organization_rec           in  ca.pk_cad_cliente_ebs_plt.organization_rec 
                                , p_cust_account_rec           in  ca.pk_cad_cliente_ebs_plt.cust_account_rec
                                , p_location_rec               in  ca.pk_cad_cliente_ebs_plt.location_rec
                                , p_cust_acct_site_rec         in  ca.pk_cad_cliente_ebs_plt.cust_acct_site_rec
                                , p_cust_site_use_rec          in  ca.pk_cad_cliente_ebs_plt.cust_site_use_rec
                                , p_customer_profile_rec       in  ca.pk_cad_cliente_ebs_plt.customer_profile_rec
                                , p_payment_method_rec         in  ca.pk_cad_cliente_ebs_plt.payment_method_rec
                                , p_person_rec                 in  ca.pk_cad_cliente_ebs_plt.person_rec
                                , p_relationship_rec           in  ca.pk_cad_cliente_ebs_plt.relationship_rec
                                , p_contact_point_rec          in  ca.pk_cad_cliente_ebs_plt.contact_point_rec
                                , p_phone_rec                  in  ca.pk_cad_cliente_ebs_plt.phone_rec
                                , p_email_rec                  in  ca.pk_cad_cliente_ebs_plt.email_rec ) return clob ;
end PK_CAD_CLIENTE_EBS_JSN;

/
--------------------------------------------------------
--  DDL for Package PK_CAD_CLIENTE_EBS_PLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CA"."PK_CAD_CLIENTE_EBS_PLT" as 

--Parâmetro API = p_organization_rec 

type organization_rec is record (

 organization_type                  VARCHAR2 (2000) 
,organization_name                  VARCHAR2 (2000)
,organization_name_phonetic         VARCHAR2 (2000)
,orig_system_reference              VARCHAR2 (2000)  
);


--Parâmetro API = p_cust_account_rec 
type cust_account_rec is record (

 account_number           VARCHAR2 (2000) 
,status                   VARCHAR2 (2000) 
,customer_type            VARCHAR2 (2000) 
,attribute1               VARCHAR2 (2000)
,orig_system_reference    VARCHAR2 (2000)
);
type arr_cust_account is table of cust_account_rec index by binary_integer;

--Parâmetro API = p_location
type location_rec is record (

 country                VARCHAR2 (2000) 
,address1               VARCHAR2 (2000)  
,address2               VARCHAR2 (2000) 
,address3               VARCHAR2 (2000)  
,address4               VARCHAR2 (2000)  
,state                  VARCHAR2 (2000) 
,city                   VARCHAR2 (2000) 
,postal_code            VARCHAR2 (2000) 
,orig_system_reference  VARCHAR2 (2000) 
);

type arr_location is table of location_rec index by binary_integer;

--Parâmetro API = p_cust_acct_site_rec 
type cust_acct_site_rec is record (

 status                         VARCHAR2 (2000)  
,org_id                         VARCHAR2 (2000)  
,global_attribute_category      VARCHAR2 (2000) 
,global_attribute2              VARCHAR2 (2000) 
,global_attribute3              VARCHAR2 (2000) 
,global_attribute4              VARCHAR2 (2000) 
,global_attribute5              VARCHAR2 (2000) 
,global_attribute6              VARCHAR2 (2000) 
,global_attribute7              VARCHAR2 (2000) 
,global_attribute8              VARCHAR2 (2000) 
,global_attribute10             VARCHAR2 (2000) 
,global_attribute13             VARCHAR2 (2000) 
,attribute1                     VARCHAR2 (2000) 
,attribute2                     VARCHAR2 (2000) 
,orig_system_reference          VARCHAR  (2000) 
);
type arr_cust_acct_site is table of cust_acct_site_rec index by binary_integer;

--Parâmetro API = p_cust_site_use_rec 

type cust_site_use_rec is record (

 site_use_code            VARCHAR2 (2000) 
,location                 VARCHAR2 (2000) 
,bill_to_site_use_id      VARCHAR2 (2000) 
,territory_id             VARCHAR2 (2000) 
,primary_salesrep_id      VARCHAR2 (2000) 
,orig_system_reference    VARCHAR2 (2000) 
);
type arr_cust_site_use is table of cust_site_use_rec index by binary_integer;

--Parâmetro API = p_customer_profile_rec 

type customer_profile_rec is record (

 profile_class_id  VARCHAR2 (2000)   
,standard_terms    VARCHAR2 (2000)   
);
type arr_customer_profile is table of customer_profile_rec index by binary_integer;

--Parâmetro API = p_payment_method_rec 
type payment_method_rec is record (

receipt_method_name  VARCHAR2 (2000) 
);
type arr_payment_method is table of payment_method_rec index by binary_integer;

--Parâmetro API = p_person_rec 
type person_rec is record (

person_last_name              VARCHAR2(2000)
);
type arr_person is table of person_rec index by binary_integer;  

--Parâmetro API = p_relationship_rec 
type relationship_rec is record ( 

 subject_type            VARCHAR2 (2000) 
,subject_table_name      VARCHAR2 (2000) 
,object_type             VARCHAR2 (2000) 
,relationship_code       VARCHAR2 (2000) 
,object_table_name       VARCHAR2 (2000) 
);
type arr_relationship is table of relationship_rec index by binary_integer;

--Parâmetro API = p_contact_point_rec 
type contact_point_rec is record (

 owner_table_name   VARCHAR2 (2000)
,status             VARCHAR2 (2000)   
);
type arr_contact_point is table of contact_point_rec index by binary_integer;

--Parâmetro API = p_phone_rec 
type phone_rec is record (

 phone_line_type                VARCHAR2 (2000) 
,phone_country_code             VARCHAR2 (2000) 
,phone_area_code                VARCHAR2 (2000) 
,phone_number                   VARCHAR2 (2000) 
);
type arr_phone is table of phone_rec index by binary_integer;

--Parâmetro API = p_email_rec 
type email_rec is record (

email_address                  VARCHAR2 (2000) 
);
type arr_email is table of email_rec index by binary_integer;

--Parâmetro API = exit_rec parametro de saida do procedimento 
type exit_rec is record (

   X_ACCOUNT_NUMBER VARCHAR2(2000)
,  X_PARTY_ID_CUST_ACCOUNT NUMBER
,  X_PARTY_NUMBER_CUST_ACCOUNT VARCHAR2(2000)
,  X_PROFILE_ID_CUST_ACCOUNT NUMBER
,  X_RETURN_STATUS_CUST_ACCOUNT VARCHAR2(2000)
,  X_MSG_COUNT_CUST_ACCOUNT NUMBER
,  X_MSG_DATA_CUST_ACCOUNT VARCHAR2(4000)
,  X_LOCATION_ID NUMBER
,  X_RETURN_STATUS_LOCATION VARCHAR2(2000)
,  X_MSG_COUNT_LOCATION NUMBER
,  X_MSG_DATA_LOCATION VARCHAR2(2000)
,  X_PARTY_SITE_ID NUMBER
,  X_PARTY_SITE_NUMBER VARCHAR2(2000)
,  X_RETURN_STATUS_PARTY_SITE VARCHAR2(2000)
,  X_MSG_COUNT_PARTY_SITE NUMBER
,  X_MSG_DATA_PARTY_SITE VARCHAR2(2000)
,  X_CUST_ACCT_SITE_ID NUMBER
,  X_RETURN_STATUS_ACCT_SITE VARCHAR2(2000)
,  X_MSG_COUNT_ACCT_SITE NUMBER
,  X_MSG_DATA_ACCT_SITE VARCHAR2(2000)
,  X_SITE_USE_ID NUMBER
,  X_RETURN_STATUS_SITE_USE VARCHAR2(2000)
,  X_MSG_COUNT_SITE_USE NUMBER
,  X_MSG_DATA_SITE_USE VARCHAR2(2000)
,  X_CUST_ACCOUNT_PROFILE_ID NUMBER
,  X_RETURN_STATUS_CUST_ACCOUNT_PROFILE VARCHAR2(2000)
,  X_MSG_COUNT_CUST_ACCOUNT_PROFILE NUMBER
,  X_MSG_DATA_CUST_ACCOUNT_PROFILE VARCHAR2(2000)
,  X_CUST_RECEIPT_METHOD_ID NUMBER
,  X_RETURN_STATUS_PAYMENT_METHOD VARCHAR2(2000)
,  X_MSG_COUNT_PAYMENT_METHOD NUMBER
,  X_MSG_DATA_PAYMENT_METHOD VARCHAR2(2000)
,  X_PARTY_ID NUMBER
,  X_PARTY_NUMBER VARCHAR2(2000)
,  X_PROFILE_ID_PARTY NUMBER
,  X_RETURN_STATUS_PARTY VARCHAR2(2000)
,  X_MSG_COUNT_PARTY NUMBER
,  X_MSG_DATA_PARTY VARCHAR2(2000)
,  X_RELATIONSHIP_ID NUMBER
,  X_PARTY_ID_RELATIONSHIP NUMBER
,  X_PARTY_NUMBER_RELATIONSHIP VARCHAR2(2000)
,  X_RETURN_STATUS_RELATIONSHIP VARCHAR2(2000)
,  X_MSG_COUNT_RELATIONSHIP NUMBER
,  X_MSG_DATA_RELATIONSHIP VARCHAR2(2000)
,  X_CONTACT_POINT_ID NUMBER
,  X_RETURN_STATUS_CONTACT_POINT VARCHAR2(2000)
,  X_MSG_COUNT_CONTACT_POINT NUMBER
,  X_MSG_DATA_CONTACT_POINT VARCHAR2(2000)
);
 

end pk_cad_cliente_ebs_plt;

/
--------------------------------------------------------
--  DDL for Package PK_CAD_CLIENTE_EBS_QRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CA"."PK_CAD_CLIENTE_EBS_QRY" IS
  
  ----------------------------------------------------------------------------------------------------
  -- Public Types 
  ----------------------------------------------------------------------------------------------------   
  subtype organization_rec is ca.PK_CAD_CLIENTE_EBS_PLT.organization_rec;
  type arr_organization is table of organization_rec;
  
  subtype cust_account_rec is ca.PK_CAD_CLIENTE_EBS_PLT.cust_account_rec;
  type arr_cust_account_rec is table of cust_account_rec;
  
  subtype location_rec is ca.PK_CAD_CLIENTE_EBS_PLT.location_rec;
  type arr_location_rec is table of location_rec;
   
  subtype cust_acct_site_rec is ca.PK_CAD_CLIENTE_EBS_PLT.cust_acct_site_rec;
  type arr_cust_acct_site_rec is table of cust_acct_site_rec;
  
  subtype cust_site_use_rec is ca.PK_CAD_CLIENTE_EBS_PLT.cust_site_use_rec;
  type arr_cust_site_use_rec is table of cust_site_use_rec;
  
  subtype customer_profile_rec is ca.PK_CAD_CLIENTE_EBS_PLT.customer_profile_rec;
  type arr_customer_profile_rec is table of customer_profile_rec;
  
  subtype payment_method_rec is ca.PK_CAD_CLIENTE_EBS_PLT.payment_method_rec;
  type arr_payment_method_rec is table of payment_method_rec;
  
  subtype person_rec is ca.PK_CAD_CLIENTE_EBS_PLT.person_rec;
  type arr_person_rec is table of person_rec;
  
  subtype relationship_rec is ca.PK_CAD_CLIENTE_EBS_PLT.relationship_rec;
  type arr_relationship_rec is table of relationship_rec;
  
  subtype contact_point_rec is ca.PK_CAD_CLIENTE_EBS_PLT.contact_point_rec;
  type arr_contact_point_rec is table of contact_point_rec;
  
  subtype phone_rec is ca.PK_CAD_CLIENTE_EBS_PLT.phone_rec;
  type arr_phone_rec is table of phone_rec;
  
  subtype email_rec is ca.PK_CAD_CLIENTE_EBS_PLT.email_rec;
  type arr_email_rec is table of email_rec;

  ------------------------------------------------------------------------------------------------------------------------
  -- organization_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_organization_rec (pv_id_pessoa in number)
  return organization_rec;  
  ------------------------------------------------------------------------------------------------------------------------
  -- cust_account_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_cust_account_rec (pv_id_pessoa in number
                              ,pv_nr_matricula in varchar2)
  return cust_account_rec;
  ------------------------------------------------------------------------------------------------------------------------
  -- location_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_location_rec (pv_id_pessoa in number
                            ,pv_nr_matricula in varchar2)
  return location_rec;  
  ------------------------------------------------------------------------------------------------------------------------
  -- cust_acct_site_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_cust_acct_site_rec (pv_id_pessoa in number
                                ,pv_nr_matricula in varchar2)
  return cust_acct_site_rec;
  ------------------------------------------------------------------------------------------------------------------------
  -- cust_site_use_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_cust_site_use_rec (pv_id_pessoa in number
                               ,pv_nr_matricula in varchar2)
  return cust_site_use_rec;  
  ------------------------------------------------------------------------------------------------------------------------
  -- customer_profile_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_customer_profile_rec 
  return customer_profile_rec;
  ------------------------------------------------------------------------------------------------------------------------
  -- payment_method_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_payment_method_rec  
  return payment_method_rec;  
  ------------------------------------------------------------------------------------------------------------------------
  -- person_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_person_rec (pv_id_pessoa in number)
                       -- ,pv_nr_matricula in number)
  return person_rec;
  ------------------------------------------------------------------------------------------------------------------------
  -- relationship_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_relationship_rec  
  return relationship_rec;  
  ------------------------------------------------------------------------------------------------------------------------
  -- contact_point_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_contact_point_rec
  return contact_point_rec; 
  ------------------------------------------------------------------------------------------------------------------------
  -- phone_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_phone_rec (pv_id_pessoa in number)
  return phone_rec;  
  ------------------------------------------------------------------------------------------------------------------------
  -- email_rec
  ------------------------------------------------------------------------------------------------------------------------  
  function f_email_rec (pv_id_pessoa in number)
  return email_rec; 

  end PK_CAD_CLIENTE_EBS_QRY;

/
--------------------------------------------------------
--  DDL for Package PK_CAD_CLIENTE_EBS_STM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "CA"."PK_CAD_CLIENTE_EBS_STM" as
--
--------------------------------------------------------------------------------

gc_organization_qry constant varchar2(32767) := 
 q'[select 
         organization_type
        ,organizaton_name
        ,organization_name_phonetic
        ,orig_system_reference
    from  
      ca.vw_cad_cliente_ebs_organization
    where
        id_pessoa = :pv_id_pessoa]' ;

-- # Esta constante está resolvendo apenas para alunos da GRAD e Pos e Inscricao vestibular
gc_cust_account_qry constant varchar2(32767) := 
q'[select 
        account_number,
        status,
        customer_type,
        attribute1,
        orig_system_reference
    from CA.VW_CAD_CLIENTE_EBS_CUST_ACCOUNT
    where
    id_pessoa = :pv_id_pessoa
    and matricula = :pv_nr_matricula]'; ---verificar com o gustavo, qual matricula foi utilizada para a pessoa PJ
     
gc_location_qry constant varchar2(32767) := 
   q'[select    
          country                --p_location_rec.country 
         , ADDRESS1              --p_location_rec.address1 
         , ADDRESS2              --p_location_rec.address2 
         , ADDRESS3              --p_location_rec.address3 
         , ADDRESS4              --p_location_rec.address4 
         , STATE                 --p_location_rec.state
         , CITY                  --p_location_rec.city 
         , POSTAL_CODE           --p_location_rec.postal_code 
         , orig_system_reference --########Revisar informação CNPJ p_location_rec.orig_system_reference 
    from     
      CA.VW_CAD_CLIENTE_EBS_LOCATION p
    where 
          1 = 1
    and p.id_pessoa = :pv_id_pessoa
    and matricula = :pv_nr_matricula]' ;
     
gc_cust_acct_site_qry constant varchar2(32767) := 
   q'[
select 
     status                     --p_party_site_rec.status 
    ,org_id                     --p_cust_acct_site_rec.org_id 
    ,global_attribute_category  --p_cust_acct_site_rec.global_attribute_cate gory 
    ,global_attribute2          --Tipo de Inscrição: `1¿ para CPF `2¿ para CNPJ `3¿ para Outros 
    ,global_attribute3          --Preencher com a raiz do CNPJ ou CPF (9 digitos)
    ,global_attribute4          --Preencher com o identificador Filial do CNPJ (4 digitos) Para CPF sempre será fixo `0000¿.
    ,global_attribute5          --Preencher com o digito do CNPJ ou do CPF (2 digitos)
    ,global_attribute6          --Preencher com o código da Inscrição estadual (caso exista) ? posso colocar nullo?
    ,global_attribute7          --Preencher com o código da Inscrição Municipal (caso exista)
    ,global_attribute8          --Preencher com o Tipo de Contribuinte Ex: CONTRIBUINTE, NÃO CONTRIBUINTE. Conforme lista de valores de Tipos de Contribuinte utilizada pela emrpesa.
    ,global_attribut10          --Definir Preencher com Inscrição do Suframa 
    ,global_attribute13         --Preencher com o Indicador de Inscrição Estadual do Destinatário
    ,ATTRIBUTE1                 --Preencher com o Nome do Responsável Financeiro do Aluno/ Cliente
    ,ATTRIBUTE2                 -- Preencher com o Número do CPF/ CNPJ do Responsável Financeiro do Aluno/ Cliente. Preencher com o número do CPF/ CNPJ do Responsável Financeiro do Aluno/ Cliente no seguinte formato: CPF: 000.000.000-00 CNPJ: 00.000.000/0000-00
    ,ORIG_SYSTEM_ADDRESS_REF    -- Número da Matrícula do Cliente
from
    CA.VW_CAD_CLIENTE_EBS_CUST_ACC_SITE P
where 
      1 = 1
  and p.id_pessoa = :pv_id_pessoa 
  and p.matricula = :pv_nr_matricula]' ;  
     
gc_cust_site_use_qry constant varchar2(32767) := 
   q'[select   
       SITE_USE_CODE        --p_cust_site_use_rec  Este campo armazema o Tipo de endereço BILL_TO, SHIP_TO e DUN.; só permite 1 endereço de cobrança (DUN)
       ,LOCATION            --p_cust_site_use_rec  Preencher código do Local, conforme definido junto a Unifor, será utilizado o Número de Matrícula do Cliente/ Aluno.
       ,bill_to_site_use_id --bill_to_site_use_id 
       ,territory_id
       ,primary_salesrep_id 
       ,ORIG_SYSTEM_ADDRESS_REF -- Número da Matrícula do Cliente
    from 
        ca.VW_CAD_CLIENTE_EBS_CUST_SITE_USE p
    where 
          1 = 1
      and p.id_pessoa = :pv_id_pessoa 
      and p.matricula = :pv_nr_matricula]' ; 

gc_customer_profile_qry constant varchar2(32767) := 
   q'[select
            '0' profile_class_id --p_customer_profile_rec.profile_class_id 
           ,('30DD') standard_terms  
      from dual]' ;


gc_payment_method_qry constant varchar2(32767) := 
   q'[select 
             name receipt_method_name
    	from AR_RECEIPT_METHODS@ebsunifor  t 
       where 
            t.name like 'BRAD_1234_43000_ESCR' 
         and sysdate BETWEEN start_date and  nvl(end_date,'01/01/9999')]';
 
     
gc_person_qry constant varchar2(32767) := 
   q'[select 
            substr(p.nm_pessoa, instr(p.nm_pessoa, ' ') + 1) PERSON_LAST_NAME  
       from    
            ca.cp_pessoa p
      where 
             p.id_pessoa = :pv_id_pessoa]' ;

gc_relationship_qry constant varchar2(32767) := 
   q'[
    select      
         'ORGANIZATION'  subject_type                           --p_relationship_rec. subject_type
        ,'HZ_PARTIES' subject_table_name                        --p_relationship_rec. subject_table_name 
        ,'PERSON' object_type                                   --p_relationship_rec. object_type 
        ,'CONTACT' relationship_code                            --p_relationship_rec. relationship_code 
        ,'HZ_PARTIES'    object_table_name                      --p_relationship_rec. object_table_name
    from
        dual]' ; 
     
gc_contact_point_qry constant varchar2(32767) := 
   q'[
    select
        'HZ_PARTIES'  owner_table_name 
       ,'A' status
    from
        dual]' ; 
     
gc_phone_qry constant varchar2(32767) := 
   q'[
   SELECT 
        phone_line_type ,
        phone_country_code,
        phone_area_code,
        phone_number
        
    FROM (
        SELECT 
                p.id_pessoa,
                CASE WHEN pc.cd_faixa_contato = 1 
                    THEN 
                        'GEN'
                WHEN pc.cd_faixa_contato = 2 OR pc.cd_faixa_contato = 5
                    THEN
                        'MOBILE'
                WHEN pc.cd_faixa_contato = 6 
                    THEN
                        'FAX'
                ELSE '' END as phone_line_type,
                'BR' phone_country_code,
                CASE 
                    WHEN pc.cd_faixa_contato <> 3 THEN SUBSTR(pc.ds_contato ,0,2)
                ELSE 
                    '' 
                END as phone_area_code,
                CASE 
                    WHEN pc.cd_faixa_contato <> 3 THEN SUBSTR(pc.ds_contato ,3,9)
                ELSE 
                    '' 
                End as phone_number
        FROM ca.cp_pessoa_contato pc
            , ca.cp_pessoa p
            , ca.cp_pessoa_fisica pf
         
        WHERE
            p.id_pessoa = pc.id_pessoa
            AND p.id_pessoa = pf.id_pessoa_fisica)
WHERE
    phone_number is not null and phone_area_code is not null and phone_line_type is not null
and phone_area_code <> 0
and id_pessoa = :pv_id_pessoa
and rownum <=1 ]' ; 
     
gc_email_qry constant varchar2(32767) := 
   q'[
    SELECT 
        EMAIL_ADDRESS
    FROM     
        (SELECT 
                p.id_pessoa,
                CASE 
                    WHEN pc.cd_faixa_contato = 3 THEN pc.ds_contato
                ELSE 
                    '' 
                END as EMAIL_ADDRESS,
           pc.fl_ativo     
        FROM 
            ca.cp_pessoa_contato pc
           ,ca.cp_pessoa p
           ,ca.cp_pessoa_fisica pf
        WHERE
            p.id_pessoa = pc.id_pessoa
        AND p.id_pessoa = pf.id_pessoa_fisica)
    WHERE   
        id_pessoa = :pv_id_pessoa
    and EMAIL_ADDRESS is not null
    and fl_ativo = 'S'
    and rownum = 1]' ; 

end PK_CAD_CLIENTE_EBS_STM;

/
