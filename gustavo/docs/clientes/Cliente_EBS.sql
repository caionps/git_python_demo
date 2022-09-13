--select enviado pelo Glaydson
select DISTINCT hao.name, hcasa.org_id,
       hp.party_name "NOME DO CLIENTE",
       hcasa.global_attribute8,
       Hcasa.STATUS "A-ATIVO/I-INATIVO",
       hcsu.status,
       HL.LOCATION_ID,
       hl.city,
       hl.address1,
       hl.address1 || ', ' || hl.address2 || ' - ' || hl.address3 ||
       ' - ' || hl.address4 || ' - ' || hl.city || ' - ' || hl.state "ENDEREÇO COMPLETO",
       hcaa.account_number "NUMERO DA CONTA",
       hcaa.orig_system_reference,
       hcasa.global_attribute2 "2-CNPJ / 1-CPF",
       hcasa.global_attribute3 || hcasa.global_attribute4 ||
       hcasa.global_attribute5 "CNPJ/CPF",
       hcsu.site_use_code,
       hcsu.location "LOCAL",
       hcsu.bill_to_site_use_id "BILL_TO ATRIBUÍDO",
       hcsu.site_use_id,
       hcaa.CUST_ACCOUNT_ID,
       hcsu.cust_acct_site_id,
       hcsu.creation_date,
       hcsu.last_update_date "DATA DA ÚLTIMA ATUALIZAÇÃO",
       hcsu.orig_system_reference,
       gcc.code_combination_id,
       gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' ||
       gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' ||
       gcc.segment7 || '.' || gcc.segment8 || '.' || gcc.segment9 || '.' ||
       gcc.segment10 || '.' || gcc.segment11 || '.' || gcc.segment12 "CLASS. CONTABIL",
       (select distinct hcsu1.location
          from apps.hz_parties@ebsunifor             hp1,
               apps.hz_cust_accounts_all@ebsunifor   hcaa1,
               apps.hz_cust_acct_sites_all@ebsunifor hcasa1,
               apps.hz_cust_site_uses_all@ebsunifor  hcsu1,
               APPS.HZ_LOCATIONS@ebsunifor           HL1,
               APPS.HZ_PARTY_SITES@ebsunifor         hps1,
               apps.gl_code_combinations@ebsunifor   gcc1
         where hp1.party_id = hcaa1.party_id
           and hcaa1.cust_account_id = hcasa1.cust_account_id
           and hcasa1.cust_acct_site_id = hcsu1.cust_acct_site_id
           and hcasa.cust_acct_site_id = hcasa1.cust_acct_site_id
           and hp1.party_id = hp.party_id ---033039223
           and hcaa1.party_id = hcaa.party_id
           and hcaa1.cust_account_id = hcaa.cust_account_id
           and hcasa1.cust_account_id = hcasa.cust_account_id
           and hcasa1.cust_acct_site_id = hcasa.cust_acct_site_id
           and hcsu1.cust_acct_site_id = hcsu.cust_acct_site_id
           AND hl1.location_id = hl.location_id
           AND hps1.location_id = hps.location_iD
           AND hcsu1.GL_ID_REC = hcsu.GL_ID_REC
           AND GCC1.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID
           and HCSU1.SITE_USE_CODE = 'BILL_TO'
           AND hcsu.bill_to_site_use_id IS NOT NULL) "BILL TO ATRIBUIDO AO SHIP TO"
  from apps.hz_parties@ebsunifor                hp,
       apps.hz_cust_accounts_all@ebsunifor      hcaa,
       apps.hz_cust_acct_sites_all@ebsunifor    hcasa,
       apps.hz_cust_site_uses_all@ebsunifor     hcsu,
       APPS.HZ_LOCATIONS@ebsunifor              HL, --hl.address1
       APPS.HZ_PARTY_SITES@ebsunifor            hps,
       apps.gl_code_combinations@ebsunifor      gcc,
       apps.hr_all_organization_units@ebsunifor hao
 where hp.party_id = hcaa.party_id
   and hcaa.cust_account_id = hcasa.cust_account_id
   and hcasa.cust_acct_site_id = hcsu.cust_acct_site_id
   and hl.location_id = hps.location_id
   and hps.party_id = hp.party_id
   and hps.party_site_id = hcasa.party_site_id
   and hcasa.org_id = hao.organization_id
   and hcsu.GL_ID_REC = GCC.CODE_COMBINATION_ID(+)
   AND hcasa.org_id not in (83,84)
   and hao.name like 'OU_UNF_100'
  -- and hcsu.site_use_code = 'BILL_TO'
   -- AND hp.party_name LIKE 'YANA MARIA GUILHERME MARTINS'  --'CATHERINE MONTEIRO DOS SANTOS'
   --AND hcasa.org_id = 753
   AND hcasa.global_attribute8 = 'NAO CONTRIBUINTE'
   --AND hl.state = 'TO'
 ORDER BY HP.PARTY_NAME 
 ;

SELECT * FROM APPS.HZ_PARTY_SITES@ebsunifor;
  
SELECT * FROM APPS.HZ_LOCATIONS@ebsunifor 
;