select organization_name_phonetic,
p.* 
from  HZ_PARTIES@ebsunifor p where party_type = 'ORGANIZATION'
order by creation_date desc;
select * from HZ_CUST_ACCOUNTS@ebsunifor; 

select * from HZ_CONTACT_POINTS@ebsunifor
;
select * from HZ_CUST_ACCT_RELATE_ALL@ebsunifor ;
select * from HZ_CUST_ACCT_ROLES@ebsunifor ;
select * from HZ_CUST_ACCT_SITES_ALL@ebsunifor ;

select * from  HZ_CUST_SITE_USES_ALL@ebsunifor;
select * from  HZ_LOCATIONS@ebsunifor;
select * from  HZ_ORG_CONTACTS@ebsunifor ;

select * from HZ_PARTY_SITES@ebsunifor;

select * from ca.aluno a where a.nr_cpf = 614234932
select * from ca.cad_integra_cliente_log_ebs cicle;