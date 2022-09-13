--cursor C_HZ_PARTIES (p_party_name in varchar2 ) is 
--      select party_id from HZ_PARTIES@ebsunifor
--        where party_type = 'ORGANIZATION'
--          and party_name = p_party_name;
          
       select * from HZ_PARTIES@ebsunifor
        where party_type = 'ORGANIZATION'
        and creation_date > '01/08/2022'
        order by creation_date desc;

 --  cursor C_CUST (p_cust_account in varchar2  ) is
--      select CUST_ACCOUNT_ID  from HZ_CUST_ACCOUNTS@ebsunifor
      
--      where account_number = p_cust_account;
      
      select *  from HZ_CUST_ACCOUNTS@ebsunifor
       where creation_date > '01/08/2022'
       order by creation_date desc;
      
   cursor C_HZ_GEOGRAPHIES_STATE ( p_geography_code in varchar2,
                                   p_geography_type in varchar2,
                                   p_country_code   in varchar2) is
    select geography_element1_id , geography_element2_id  from HZ_GEOGRAPHIES@ebsunifor
      where geography_code = p_geography_code
        and geography_type = p_geography_type
        and country_code   = p_country_code
        and sysdate between start_date and end_date;
        
   
   cursor C_HZ_GEOGRAPHIES_CITY ( p_geography_code in varchar2,
                                  p_geography_type in varchar2,
                                  p_country_code   in varchar2,
                                  p_geography_element1_id in number,
                                  p_geography_element2_id in number ) is
    select 'x' from HZ_GEOGRAPHIES@ebsunifor
      where geography_code = p_geography_code
        and geography_type = p_geography_type
        and country_code   = p_country_code
        and geography_element1_id = p_geography_element1_id
        and geography_element2_id = p_geography_element2_id
        and sysdate between start_date and end_date;
        
   cursor C_HZ_LOCATIONS ( p_orig_system_reference in varchar2) is      
    select 'x' from HZ_LOCATIONS@ebsunifor
      where orig_system_reference = p_orig_system_reference;
 
 
   cursor C_HZ_CUST_ACCT_SITES_ALL  ( p_orig_system_reference in varchar2) is      
    select 'x' from HZ_CUST_ACCT_SITES_ALL@ebsunifor
      where orig_system_reference = p_orig_system_reference;
      
      
   cursor C_ORG_ORGANIZATION_DEFINITIONS ( p_org_name in varchar2 ) is
      select operating_unit 
        from ORG_ORGANIZATION_DEFINITIONS@ebsunifor
       where organization_name = p_org_name; 
       
       
   cursor C_RA_TERMS ( p_term_name in varchar2 ) is
      select term_id from RA_TERMS@ebsunifor
       where sysdate BETWEEN start_date_active and  nvl(end_date_active,'01/01/9999')
         and  name = p_term_name;
         
   cursor C_AR_RECEIPT_METHODS ( p_payment_method_name in varchar2 ) is
     select receipt_method_id from AR_RECEIPT_METHODS@ebsunifor
      where name =  p_payment_method_name
        and end_date is null;