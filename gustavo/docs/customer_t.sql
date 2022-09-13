--set serveroutput on 
DECLARE


  p_organization_rec_organization_type  varchar2(2000);
  p_organization_rec_organization_name  varchar2(2000);
  p_organization_rec_organization_name_phonetic  varchar2(2000);
  p_organization_rec_party_rec_orig_system_reference  varchar2(2000);
  P_cust_account_rec_account_number  varchar2(2000);
  P_cust_account_rec_status  varchar2(2000);
  P_cust_account_rec_customer_type  varchar2(2000);
  p_cust_account_rec_attribute1  varchar2(2000);
  p_cust_account_rec_orig_system_reference  varchar2(2000);
  p_location_rec_country   varchar2(2000);
  p_location_rec_address1  varchar2(2000);
  p_location_rec_address2  varchar2(2000);
  p_location_rec_address3  varchar2(2000);
  p_location_rec_address4  varchar2(2000);
  p_location_rec_state  varchar2(2000);
  p_location_rec_city  varchar2(2000);
  p_location_rec_postal_code  varchar2(2000);
  p_location_rec_orig_system_reference  varchar2(2000);
  p_party_site_rec_status  varchar2(2000);
  p_cust_acct_site_rec_org_id  varchar2(2000);
  p_cust_acct_site_rec_global_attribute_category  varchar2(2000);
  p_cust_acct_site_rec_global_attribute2  varchar2(2000);
  p_cust_acct_site_rec_global_attribute3  varchar2(2000);
  p_cust_acct_site_rec_global_attribute4  varchar2(2000);
  p_cust_acct_site_rec_global_attribute5  varchar2(2000);
  p_cust_acct_site_rec_global_attribute6  varchar2(2000);
  p_cust_acct_site_rec_global_attribute7  varchar2(2000);
  p_cust_acct_site_rec_global_attribute8  varchar2(2000);
  p_cust_acct_site_rec_global_attribute10  varchar2(2000);
  p_cust_acct_site_rec_global_attribute13  varchar2(2000);
  p_cust_acct_site_rec_attribute1  varchar2(2000);
  p_cust_acct_site_rec_attribute2  varchar2(2000);
  p_cust_acct_site_rec_orig_system_reference  varchar2(2000);
  p_cust_site_use_rec_site_use_code  varchar2(2000);
  p_cust_site_use_rec_location  varchar2(2000);
  p_cust_site_use_rec_bill_to_site_use_id  varchar2(2000);
  p_cust_site_use_rec_territory_id  varchar2(2000);
  p_cust_site_use_rec_primary_salesrep_id  varchar2(2000);
  p_cust_site_use_rec_orig_system_reference  varchar2(2000);
  p_customer_profile_rec_profile_class_id  varchar2(2000);
  P_TERM_NAME  varchar2(2000);
  P_PAYMENT_METHOD_NAME  varchar2(2000);
  p_person_rec_person_last_name  varchar2(2000);
  p_relationship_rec_subject_type  varchar2(2000);
  p_relationship_rec_subject_table_name  varchar2(2000);
  p_relationship_rec_object_type   varchar2(2000);
  p_relationship_rec_relationship_code  varchar2(2000);
  p_relationship_rec_object_table_name  varchar2(2000);
  p_contact_point_rec_owner_table_name  varchar2(2000);
  p_phone_rec_phone_line_type  varchar2(2000);
  p_phone_rec_phone_country_code  varchar2(2000);
  p_phone_rec_phone_area_code   varchar2(2000);
  p_phone_rec_phone_number  varchar2(2000);
  p_Contact_point_rec_status  varchar2(2000);
  p_email_rec_email_address  varchar2(2000);
  X_ACCOUNT_NUMBER VARCHAR2(200);
  X_PARTY_ID_CUST_ACCOUNT NUMBER;
  X_PARTY_NUMBER_CUST_ACCOUNT VARCHAR2(200);
  X_PROFILE_ID_CUST_ACCOUNT NUMBER;
  X_RETURN_STATUS_CUST_ACCOUNT VARCHAR2(200);
  X_MSG_COUNT_CUST_ACCOUNT NUMBER;
  X_MSG_DATA_CUST_ACCOUNT VARCHAR2(4000);
  X_LOCATION_ID NUMBER;
  X_RETURN_STATUS_LOCATION VARCHAR2(200);
  X_MSG_COUNT_LOCATION NUMBER;
  X_MSG_DATA_LOCATION VARCHAR2(200);
  X_PARTY_SITE_ID NUMBER;
  X_PARTY_SITE_NUMBER VARCHAR2(200);
  X_RETURN_STATUS_PARTY_SITE VARCHAR2(200);
  X_MSG_COUNT_PARTY_SITE NUMBER;
  X_MSG_DATA_PARTY_SITE VARCHAR2(200);
  X_CUST_ACCT_SITE_ID NUMBER;
  X_RETURN_STATUS_ACCT_SITE VARCHAR2(200);
  X_MSG_COUNT_ACCT_SITE NUMBER;
  X_MSG_DATA_ACCT_SITE VARCHAR2(200);
  X_SITE_USE_ID NUMBER;
  X_RETURN_STATUS_SITE_USE VARCHAR2(200);
  X_MSG_COUNT_SITE_USE NUMBER;
  X_MSG_DATA_SITE_USE VARCHAR2(200);
  X_CUST_ACCOUNT_PROFILE_ID NUMBER;
  X_RETURN_STATUS_CUST_ACCOUNT_PROFILE VARCHAR2(200);
  X_MSG_COUNT_CUST_ACCOUNT_PROFILE NUMBER;
  X_MSG_DATA_CUST_ACCOUNT_PROFILE VARCHAR2(200);
  X_CUST_RECEIPT_METHOD_ID NUMBER;
  X_RETURN_STATUS_PAYMENT_METHOD VARCHAR2(200);
  X_MSG_COUNT_PAYMENT_METHOD NUMBER;
  X_MSG_DATA_PAYMENT_METHOD VARCHAR2(200);
  X_PARTY_ID NUMBER;
  X_PARTY_NUMBER VARCHAR2(200);
  X_PROFILE_ID_PARTY NUMBER;
  X_RETURN_STATUS_PARTY VARCHAR2(200);
  X_MSG_COUNT_PARTY NUMBER;
  X_MSG_DATA_PARTY VARCHAR2(200);
  X_RELATIONSHIP_ID NUMBER;
  X_PARTY_ID_RELATIONSHIP NUMBER;
  X_PARTY_NUMBER_RELATIONSHIP VARCHAR2(200);
  X_RETURN_STATUS_RELATIONSHIP VARCHAR2(200);
  X_MSG_COUNT_RELATIONSHIP NUMBER;
  X_MSG_DATA_RELATIONSHIP VARCHAR2(200);
  X_CONTACT_POINT_ID NUMBER;
  X_RETURN_STATUS_CONTACT_POINT VARCHAR2(200);
  X_MSG_COUNT_CONTACT_POINT NUMBER;
  X_MSG_DATA_CONTACT_POINT VARCHAR2(200);
  
  
BEGIN

 

 
   
   
   p_organization_rec_organization_type                   := 'ORGANIZATION';
   p_organization_rec_organization_name                   := 'MANUEL DE ARARIPE LOPES NETO';
   p_organization_rec_organization_name_phonetic          := 'MANUEL DE ARARIPE LOPES NETO'; 
   p_organization_rec_party_rec_orig_system_reference     := '61500992372';

   P_cust_account_rec_account_number                      := '61500992372';
   P_cust_account_rec_status                              := 'A';
   P_cust_account_rec_customer_type                       := 'R';
   p_cust_account_rec_attribute1                          := 'GRAD';
   p_cust_account_rec_orig_system_reference               := '2217142';
   
   p_location_rec_country                                := 'BR';
   p_location_rec_address1                               := 'Av. Beira Mar, 3400';
   p_location_rec_address2                               := '3400';
   p_location_rec_address3                               := 'Meireles';
   p_location_rec_address4                               := 'AP. 602';
   p_location_rec_state                                  := 'CE';
   p_location_rec_city                                   := 'FORTALEZA';
   p_location_rec_postal_code                            := '60.165-121';
   p_location_rec_orig_system_reference                  := '511262733681';

   p_party_site_rec_status                               := 'A'; 
   p_cust_acct_site_rec_org_id                           := '101'; 
   p_cust_acct_site_rec_global_attribute_category        := 'JL.BR.ARXCUDCI.Additional'; 
   p_cust_acct_site_rec_global_attribute2                := '1';
   p_cust_acct_site_rec_global_attribute3                := '511262733';
   p_cust_acct_site_rec_global_attribute4                := '0000';
   p_cust_acct_site_rec_global_attribute5                := '72';
   p_cust_acct_site_rec_global_attribute6                := null;
   p_cust_acct_site_rec_global_attribute7                := null;
   p_cust_acct_site_rec_global_attribute8                := 'NAO CONTRIBUINTE’';
   p_cust_acct_site_rec_global_attribute10               := null;
   p_cust_acct_site_rec_global_attribute13               := null;
   p_cust_acct_site_rec_attribute1                       := 'MANUEL DE ARARIPE LOPES NETO'; 
   p_cust_acct_site_rec_attribute2                       := '61500992372';
   p_cust_acct_site_rec_orig_system_reference            := '2217142';

   p_cust_site_use_rec_site_use_code                     := 'BILL_TO';
   p_cust_site_use_rec_location                          := '2217142';
   p_cust_site_use_rec_bill_to_site_use_id               := 'BILL_TO';
   p_cust_site_use_rec_territory_id                     :=  null;
   p_cust_site_use_rec_primary_salesrep_id              := '-3';
   p_cust_site_use_rec_orig_system_reference             := '2217142';
   
   p_customer_profile_rec_profile_class_id               := '0';
   P_TERM_NAME                                           := '30DD';
   P_PAYMENT_METHOD_NAME                                 := 'BRAD_1234_43000_CART';
   
   p_person_rec_person_last_name                         := null; 
   p_relationship_rec_subject_type                       := 'ORGANIZATION'; 
   p_relationship_rec_subject_table_name                 := 'HZ_PARTIES'; 
   p_relationship_rec_object_type                        := 'PERSON'; 
   p_relationship_rec_relationship_code                  := 'CONTACT'; 
   p_relationship_rec_object_table_name                  := 'HZ_PARTIES'; 
   p_contact_point_rec_owner_table_name                  := 'HZ_PARTIES'; 
   p_phone_rec_phone_line_type                           := 'GEN';  
   p_phone_rec_phone_country_code                        := 'BR'; 
   p_phone_rec_phone_area_code                           := '85'; 
   p_phone_rec_phone_number                              := '32347957'; 
   p_Contact_point_rec_status                            := 'A'; 
   p_email_rec_email_address                             := null; 

 
    XGEQ.ZZ_CUSTOMER.CREATE_CUSTOMER@EBSUNIFOR(
    P_ORGANIZATION_REC_ORGANIZATION_TYPE => P_ORGANIZATION_REC_ORGANIZATION_TYPE,
    P_ORGANIZATION_REC_ORGANIZATION_NAME => P_ORGANIZATION_REC_ORGANIZATION_NAME,
    P_ORGANIZATION_REC_ORGANIZATION_NAME_PHONETIC => P_ORGANIZATION_REC_ORGANIZATION_NAME_PHONETIC,
    P_ORGANIZATION_REC_PARTY_REC_ORIG_SYSTEM_REFERENCE => P_ORGANIZATION_REC_PARTY_REC_ORIG_SYSTEM_REFERENCE,
    P_CUST_ACCOUNT_REC_ACCOUNT_NUMBER => P_CUST_ACCOUNT_REC_ACCOUNT_NUMBER,
    P_CUST_ACCOUNT_REC_STATUS => P_CUST_ACCOUNT_REC_STATUS,
    P_CUST_ACCOUNT_REC_CUSTOMER_TYPE => P_CUST_ACCOUNT_REC_CUSTOMER_TYPE,
    P_CUST_ACCOUNT_REC_ATTRIBUTE1 => P_CUST_ACCOUNT_REC_ATTRIBUTE1,
    P_CUST_ACCOUNT_REC_ORIG_SYSTEM_REFERENCE => P_CUST_ACCOUNT_REC_ORIG_SYSTEM_REFERENCE,
    P_LOCATION_REC_COUNTRY => P_LOCATION_REC_COUNTRY,
    P_LOCATION_REC_ADDRESS1 => P_LOCATION_REC_ADDRESS1,
    P_LOCATION_REC_ADDRESS2 => P_LOCATION_REC_ADDRESS2,
    P_LOCATION_REC_ADDRESS3 => P_LOCATION_REC_ADDRESS3,
    P_LOCATION_REC_ADDRESS4 => P_LOCATION_REC_ADDRESS4,
    P_LOCATION_REC_STATE => P_LOCATION_REC_STATE,
    P_LOCATION_REC_CITY => P_LOCATION_REC_CITY,
    P_LOCATION_REC_POSTAL_CODE => P_LOCATION_REC_POSTAL_CODE,
    P_LOCATION_REC_ORIG_SYSTEM_REFERENCE => P_LOCATION_REC_ORIG_SYSTEM_REFERENCE,
    P_PARTY_SITE_REC_STATUS => P_PARTY_SITE_REC_STATUS,
    P_CUST_ACCT_SITE_REC_ORG_ID => P_CUST_ACCT_SITE_REC_ORG_ID,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE_CATEGORY => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE_CATEGORY,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE2 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE2,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE3 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE3,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE4 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE4,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE5 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE5,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE6 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE6,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE7 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE7,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE8 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE8,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE10 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE10,
    P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE13 => P_CUST_ACCT_SITE_REC_GLOBAL_ATTRIBUTE13,
    P_CUST_ACCT_SITE_REC_ATTRIBUTE1 => P_CUST_ACCT_SITE_REC_ATTRIBUTE1,
    P_CUST_ACCT_SITE_REC_ATTRIBUTE2 => P_CUST_ACCT_SITE_REC_ATTRIBUTE2,
    P_CUST_ACCT_SITE_REC_ORIG_SYSTEM_REFERENCE => P_CUST_ACCT_SITE_REC_ORIG_SYSTEM_REFERENCE,
    P_CUST_SITE_USE_REC_SITE_USE_CODE => P_CUST_SITE_USE_REC_SITE_USE_CODE,
    P_CUST_SITE_USE_REC_LOCATION => P_CUST_SITE_USE_REC_LOCATION,
    P_CUST_SITE_USE_REC_BILL_TO_SITE_USE_ID => P_CUST_SITE_USE_REC_BILL_TO_SITE_USE_ID,
    P_CUST_SITE_USE_REC_TERRITORY_ID => P_CUST_SITE_USE_REC_TERRITORY_ID,
    P_CUST_SITE_USE_REC_PRIMARY_SALESREP_ID => P_CUST_SITE_USE_REC_PRIMARY_SALESREP_ID,
    P_CUST_SITE_USE_REC_ORIG_SYSTEM_REFERENCE => P_CUST_SITE_USE_REC_ORIG_SYSTEM_REFERENCE,
    P_CUSTOMER_PROFILE_REC_PROFILE_CLASS_ID => P_CUSTOMER_PROFILE_REC_PROFILE_CLASS_ID,
    P_TERM_NAME => P_TERM_NAME,
    P_PAYMENT_METHOD_NAME => P_PAYMENT_METHOD_NAME,
    P_PERSON_REC_PERSON_LAST_NAME => P_PERSON_REC_PERSON_LAST_NAME,
    P_RELATIONSHIP_REC_SUBJECT_TYPE => P_RELATIONSHIP_REC_SUBJECT_TYPE,
    P_RELATIONSHIP_REC_SUBJECT_TABLE_NAME => P_RELATIONSHIP_REC_SUBJECT_TABLE_NAME,
    P_RELATIONSHIP_REC_OBJECT_TYPE => P_RELATIONSHIP_REC_OBJECT_TYPE,
    P_RELATIONSHIP_REC_RELATIONSHIP_CODE => P_RELATIONSHIP_REC_RELATIONSHIP_CODE,
    P_RELATIONSHIP_REC_OBJECT_TABLE_NAME => P_RELATIONSHIP_REC_OBJECT_TABLE_NAME,
    P_CONTACT_POINT_REC_OWNER_TABLE_NAME => P_CONTACT_POINT_REC_OWNER_TABLE_NAME,
    P_PHONE_REC_PHONE_LINE_TYPE => P_PHONE_REC_PHONE_LINE_TYPE,
    P_PHONE_REC_PHONE_COUNTRY_CODE => P_PHONE_REC_PHONE_COUNTRY_CODE,
    P_PHONE_REC_PHONE_AREA_CODE => P_PHONE_REC_PHONE_AREA_CODE,
    P_PHONE_REC_PHONE_NUMBER => P_PHONE_REC_PHONE_NUMBER,
    P_CONTACT_POINT_REC_STATUS => P_CONTACT_POINT_REC_STATUS,
    P_EMAIL_REC_EMAIL_ADDRESS => P_EMAIL_REC_EMAIL_ADDRESS,
    X_ACCOUNT_NUMBER => X_ACCOUNT_NUMBER,
    X_PARTY_ID_CUST_ACCOUNT => X_PARTY_ID_CUST_ACCOUNT,
    X_PARTY_NUMBER_CUST_ACCOUNT => X_PARTY_NUMBER_CUST_ACCOUNT,
    X_PROFILE_ID_CUST_ACCOUNT => X_PROFILE_ID_CUST_ACCOUNT,
    X_RETURN_STATUS_CUST_ACCOUNT => X_RETURN_STATUS_CUST_ACCOUNT,
    X_MSG_COUNT_CUST_ACCOUNT => X_MSG_COUNT_CUST_ACCOUNT,
    X_MSG_DATA_CUST_ACCOUNT => X_MSG_DATA_CUST_ACCOUNT,
    X_LOCATION_ID => X_LOCATION_ID,
    X_RETURN_STATUS_LOCATION => X_RETURN_STATUS_LOCATION,
    X_MSG_COUNT_LOCATION => X_MSG_COUNT_LOCATION,
    X_MSG_DATA_LOCATION => X_MSG_DATA_LOCATION,
    X_PARTY_SITE_ID => X_PARTY_SITE_ID,
    X_PARTY_SITE_NUMBER => X_PARTY_SITE_NUMBER,
    X_RETURN_STATUS_PARTY_SITE => X_RETURN_STATUS_PARTY_SITE,
    X_MSG_COUNT_PARTY_SITE => X_MSG_COUNT_PARTY_SITE,
    X_MSG_DATA_PARTY_SITE => X_MSG_DATA_PARTY_SITE,
    X_CUST_ACCT_SITE_ID => X_CUST_ACCT_SITE_ID,
    X_RETURN_STATUS_ACCT_SITE => X_RETURN_STATUS_ACCT_SITE,
    X_MSG_COUNT_ACCT_SITE => X_MSG_COUNT_ACCT_SITE,
    X_MSG_DATA_ACCT_SITE => X_MSG_DATA_ACCT_SITE,
    X_SITE_USE_ID => X_SITE_USE_ID,
    X_RETURN_STATUS_SITE_USE => X_RETURN_STATUS_SITE_USE,
    X_MSG_COUNT_SITE_USE => X_MSG_COUNT_SITE_USE,
    X_MSG_DATA_SITE_USE => X_MSG_DATA_SITE_USE,
    X_CUST_ACCOUNT_PROFILE_ID => X_CUST_ACCOUNT_PROFILE_ID,
    X_RETURN_STATUS_CUST_ACCOUNT_PROFILE => X_RETURN_STATUS_CUST_ACCOUNT_PROFILE,
    X_MSG_COUNT_CUST_ACCOUNT_PROFILE => X_MSG_COUNT_CUST_ACCOUNT_PROFILE,
    X_MSG_DATA_CUST_ACCOUNT_PROFILE => X_MSG_DATA_CUST_ACCOUNT_PROFILE,
    X_CUST_RECEIPT_METHOD_ID => X_CUST_RECEIPT_METHOD_ID,
    X_RETURN_STATUS_PAYMENT_METHOD => X_RETURN_STATUS_PAYMENT_METHOD,
    X_MSG_COUNT_PAYMENT_METHOD => X_MSG_COUNT_PAYMENT_METHOD,
    X_MSG_DATA_PAYMENT_METHOD => X_MSG_DATA_PAYMENT_METHOD,
    X_PARTY_ID => X_PARTY_ID,
    X_PARTY_NUMBER => X_PARTY_NUMBER,
    X_PROFILE_ID_PARTY => X_PROFILE_ID_PARTY,
    X_RETURN_STATUS_PARTY => X_RETURN_STATUS_PARTY,
    X_MSG_COUNT_PARTY => X_MSG_COUNT_PARTY,
    X_MSG_DATA_PARTY => X_MSG_DATA_PARTY,
    X_RELATIONSHIP_ID => X_RELATIONSHIP_ID,
    X_PARTY_ID_RELATIONSHIP => X_PARTY_ID_RELATIONSHIP,
    X_PARTY_NUMBER_RELATIONSHIP => X_PARTY_NUMBER_RELATIONSHIP,
    X_RETURN_STATUS_RELATIONSHIP => X_RETURN_STATUS_RELATIONSHIP,
    X_MSG_COUNT_RELATIONSHIP => X_MSG_COUNT_RELATIONSHIP,
    X_MSG_DATA_RELATIONSHIP => X_MSG_DATA_RELATIONSHIP,
    X_CONTACT_POINT_ID => X_CONTACT_POINT_ID,
    X_RETURN_STATUS_CONTACT_POINT => X_RETURN_STATUS_CONTACT_POINT,
    X_MSG_COUNT_CONTACT_POINT => X_MSG_COUNT_CONTACT_POINT,
    X_MSG_DATA_CONTACT_POINT => X_MSG_DATA_CONTACT_POINT

  );
  
	
	DBMS_OUTPUT.PUT_LINE('X_ACCOUNT_NUMBER = ' || X_ACCOUNT_NUMBER);
	DBMS_OUTPUT.PUT_LINE('X_PARTY_ID_CUST_ACCOUNT = ' || X_PARTY_ID_CUST_ACCOUNT);
	DBMS_OUTPUT.PUT_LINE('X_PARTY_NUMBER_CUST_ACCOUNT = ' || X_PARTY_NUMBER_CUST_ACCOUNT);
	DBMS_OUTPUT.PUT_LINE('X_PROFILE_ID_CUST_ACCOUNT = ' || X_PROFILE_ID_CUST_ACCOUNT);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_CUST_ACCOUNT = ' || X_RETURN_STATUS_CUST_ACCOUNT);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_CUST_ACCOUNT = ' || X_MSG_COUNT_CUST_ACCOUNT);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_CUST_ACCOUNT = ' || X_MSG_DATA_CUST_ACCOUNT);
	DBMS_OUTPUT.PUT_LINE('X_LOCATION_ID = ' || X_LOCATION_ID);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_LOCATION = ' || X_RETURN_STATUS_LOCATION);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_LOCATION = ' || X_MSG_COUNT_LOCATION);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_LOCATION = ' || X_MSG_DATA_LOCATION);
	DBMS_OUTPUT.PUT_LINE('X_PARTY_SITE_ID = ' || X_PARTY_SITE_ID);
	DBMS_OUTPUT.PUT_LINE('X_PARTY_SITE_NUMBER = ' || X_PARTY_SITE_NUMBER);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_PARTY_SITE = ' || X_RETURN_STATUS_PARTY_SITE);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_PARTY_SITE = ' || X_MSG_COUNT_PARTY_SITE);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_PARTY_SITE = ' || X_MSG_DATA_PARTY_SITE);
	DBMS_OUTPUT.PUT_LINE('X_CUST_ACCT_SITE_ID = ' || X_CUST_ACCT_SITE_ID);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_ACCT_SITE = ' || X_RETURN_STATUS_ACCT_SITE);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_ACCT_SITE = ' || X_MSG_COUNT_ACCT_SITE);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_ACCT_SITE = ' || X_MSG_DATA_ACCT_SITE);
	DBMS_OUTPUT.PUT_LINE('X_SITE_USE_ID = ' || X_SITE_USE_ID);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_SITE_USE = ' || X_RETURN_STATUS_SITE_USE);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_SITE_USE = ' || X_MSG_COUNT_SITE_USE);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_SITE_USE = ' || X_MSG_DATA_SITE_USE);
	DBMS_OUTPUT.PUT_LINE('X_CUST_ACCOUNT_PROFILE_ID = ' || X_CUST_ACCOUNT_PROFILE_ID);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_CUST_ACCOUNT_PROFILE = ' || X_RETURN_STATUS_CUST_ACCOUNT_PROFILE);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_CUST_ACCOUNT_PROFILE = ' || X_MSG_COUNT_CUST_ACCOUNT_PROFILE);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_CUST_ACCOUNT_PROFILE = ' || X_MSG_DATA_CUST_ACCOUNT_PROFILE);
	DBMS_OUTPUT.PUT_LINE('X_CUST_RECEIPT_METHOD_ID = ' || X_CUST_RECEIPT_METHOD_ID);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_PAYMENT_METHOD = ' || X_RETURN_STATUS_PAYMENT_METHOD);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_PAYMENT_METHOD = ' || X_MSG_COUNT_PAYMENT_METHOD);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_PAYMENT_METHOD = ' || X_MSG_DATA_PAYMENT_METHOD);
	DBMS_OUTPUT.PUT_LINE('X_PARTY_ID = ' || X_PARTY_ID);
	DBMS_OUTPUT.PUT_LINE('X_PARTY_NUMBER = ' || X_PARTY_NUMBER);
	DBMS_OUTPUT.PUT_LINE('X_PROFILE_ID_PARTY = ' || X_PROFILE_ID_PARTY);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_PARTY = ' || X_RETURN_STATUS_PARTY);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_PARTY = ' || X_MSG_COUNT_PARTY);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_PARTY = ' || X_MSG_DATA_PARTY);
	DBMS_OUTPUT.PUT_LINE('X_RELATIONSHIP_ID = ' || X_RELATIONSHIP_ID);
	DBMS_OUTPUT.PUT_LINE('X_PARTY_ID_RELATIONSHIP = ' || X_PARTY_ID_RELATIONSHIP);
	DBMS_OUTPUT.PUT_LINE('X_PARTY_NUMBER_RELATIONSHIP = ' || X_PARTY_NUMBER_RELATIONSHIP);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_RELATIONSHIP = ' || X_RETURN_STATUS_RELATIONSHIP);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_RELATIONSHIP = ' || X_MSG_COUNT_RELATIONSHIP);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_RELATIONSHIP = ' || X_MSG_DATA_RELATIONSHIP);
	DBMS_OUTPUT.PUT_LINE('X_CONTACT_POINT_ID = ' || X_CONTACT_POINT_ID);
	DBMS_OUTPUT.PUT_LINE('X_RETURN_STATUS_CONTACT_POINT = ' || X_RETURN_STATUS_CONTACT_POINT);
	DBMS_OUTPUT.PUT_LINE('X_MSG_COUNT_CONTACT_POINT = ' || X_MSG_COUNT_CONTACT_POINT);
	DBMS_OUTPUT.PUT_LINE('X_MSG_DATA_CONTACT_POINT = ' || X_MSG_DATA_CONTACT_POINT);


END;
