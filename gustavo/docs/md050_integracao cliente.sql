--set SERVEROUTPUT ON
DECLARE
  P_NR_MATRICULA NUMBER;
  P_ID_PESSOA NUMBER;
  P_ORGANIZATION_REC CA.PK_CAD_CLIENTE_EBS_PLT.ORGANIZATION_REC;
  P_CUST_ACCOUNT_REC CA.PK_CAD_CLIENTE_EBS_PLT.CUST_ACCOUNT_REC;
  P_LOCATION_REC CA.PK_CAD_CLIENTE_EBS_PLT.LOCATION_REC;
  P_CUST_ACCT_SITE_REC CA.PK_CAD_CLIENTE_EBS_PLT.CUST_ACCT_SITE_REC;
  P_CUST_SITE_USE_REC CA.PK_CAD_CLIENTE_EBS_PLT.CUST_SITE_USE_REC;
  P_CUSTOMER_PROFILE_REC CA.PK_CAD_CLIENTE_EBS_PLT.CUSTOMER_PROFILE_REC;
  P_PAYMENT_METHOD_REC CA.PK_CAD_CLIENTE_EBS_PLT.PAYMENT_METHOD_REC;
  P_PERSON_REC CA.PK_CAD_CLIENTE_EBS_PLT.PERSON_REC;
  P_RELATIONSHIP_REC CA.PK_CAD_CLIENTE_EBS_PLT.RELATIONSHIP_REC;
  P_CONTACT_POINT_REC CA.PK_CAD_CLIENTE_EBS_PLT.CONTACT_POINT_REC;
  P_PHONE_REC CA.PK_CAD_CLIENTE_EBS_PLT.PHONE_REC;
  P_EMAIL_REC CA.PK_CAD_CLIENTE_EBS_PLT.EMAIL_REC;
  P_FG_RETORNO VARCHAR2(200);
  P_DS_RETORNO VARCHAR2(200);
BEGIN
  P_NR_MATRICULA := 63100112; --1823429;
  P_ID_PESSOA := 378147; --209880;
  -- Modify the code to initialize the variable
  -- P_ORGANIZATION_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_CUST_ACCOUNT_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_LOCATION_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_CUST_ACCT_SITE_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_CUST_SITE_USE_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_CUSTOMER_PROFILE_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_PAYMENT_METHOD_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_PERSON_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_RELATIONSHIP_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_CONTACT_POINT_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_PHONE_REC := NULL;
  -- Modify the code to initialize the variable
  -- P_EMAIL_REC := NULL;

  PK_CAD_CLIENTE_EBS_CLC.P_INTEGRA_CLIENTE_EBS(
    P_NR_MATRICULA => P_NR_MATRICULA,
    P_ID_PESSOA => P_ID_PESSOA,
    P_ORGANIZATION_REC => P_ORGANIZATION_REC,
    P_CUST_ACCOUNT_REC => P_CUST_ACCOUNT_REC,
    P_LOCATION_REC => P_LOCATION_REC,
    P_CUST_ACCT_SITE_REC => P_CUST_ACCT_SITE_REC,
    P_CUST_SITE_USE_REC => P_CUST_SITE_USE_REC,
    P_CUSTOMER_PROFILE_REC => P_CUSTOMER_PROFILE_REC,
    P_PAYMENT_METHOD_REC => P_PAYMENT_METHOD_REC,
    P_PERSON_REC => P_PERSON_REC,
    P_RELATIONSHIP_REC => P_RELATIONSHIP_REC,
    P_CONTACT_POINT_REC => P_CONTACT_POINT_REC,
    P_PHONE_REC => P_PHONE_REC,
    P_EMAIL_REC => P_EMAIL_REC,
    P_FG_RETORNO => P_FG_RETORNO,
    P_DS_RETORNO => P_DS_RETORNO
  );

---------------------------------------------------------------------------------------------------
--p_organization_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_organization_rec 4 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_organization_rec.organization_type          );
DBMS_OUTPUT.PUT_LINE(p_organization_rec.organizaton_name           );
DBMS_OUTPUT.PUT_LINE(p_organization_rec.organization_name_phonetic );
DBMS_OUTPUT.PUT_LINE(p_organization_rec.orig_system_reference      );

---------------------------------------------------------------------------------------------------
--p_cust_account_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_cust_account_rec 5 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_cust_account_rec.account_number          );
DBMS_OUTPUT.PUT_LINE(p_cust_account_rec.status                  );
DBMS_OUTPUT.PUT_LINE(p_cust_account_rec.customer_type           );
DBMS_OUTPUT.PUT_LINE(p_cust_account_rec.attribute1              );
DBMS_OUTPUT.PUT_LINE(p_cust_account_rec.orig_system_reference   );

---------------------------------------------------------------------------------------------------
--p_location_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_location_rec 9 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_location_rec.country  	           );
DBMS_OUTPUT.PUT_LINE(p_location_rec.ADDRESS1 			   );
DBMS_OUTPUT.PUT_LINE(p_location_rec.ADDRESS2 			   );
DBMS_OUTPUT.PUT_LINE(p_location_rec.ADDRESS3 			   );
DBMS_OUTPUT.PUT_LINE(p_location_rec.ADDRESS4 			   );
DBMS_OUTPUT.PUT_LINE(p_location_rec.STATE    			   );
DBMS_OUTPUT.PUT_LINE(p_location_rec.CITY                   );
DBMS_OUTPUT.PUT_LINE(p_location_rec.POSTAL_CODE            );
DBMS_OUTPUT.PUT_LINE(p_location_rec.orig_system_reference  );

---------------------------------------------------------------------------------------------------
--p_cust_acct_site_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_cust_acct_site_rec 15 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.status                    );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.org_id                    );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute_category );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute2         );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute3         );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute4         );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute5         );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute6         );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute7         );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute8         );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute10        );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.global_attribute13        );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.ATTRIBUTE1                );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.ATTRIBUTE2                );
DBMS_OUTPUT.PUT_LINE(p_cust_acct_site_rec.ORIG_SYSTEM_REFERENCE     );

---------------------------------------------------------------------------------------------------
--p_cust_site_use_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_cust_site_use_rec 6 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_cust_site_use_rec.site_use_code         );
DBMS_OUTPUT.PUT_LINE(p_cust_site_use_rec.location              );
DBMS_OUTPUT.PUT_LINE(p_cust_site_use_rec.bill_to_site_use_id   );
DBMS_OUTPUT.PUT_LINE(p_cust_site_use_rec.territory_id          );
DBMS_OUTPUT.PUT_LINE(p_cust_site_use_rec.primary_salesrep_id   );
DBMS_OUTPUT.PUT_LINE(p_cust_site_use_rec.orig_system_reference );

---------------------------------------------------------------------------------------------------
--p_customer_profile_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_customer_profile_rec 2 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_customer_profile_rec.profile_class_id );
DBMS_OUTPUT.PUT_LINE(p_customer_profile_rec.standard_terms   );

---------------------------------------------------------------------------------------------------
--p_payment_method_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_payment_method_rec 1 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_payment_method_rec.receipt_method_id );

---------------------------------------------------------------------------------------------------
--p_person_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_person_rec 1 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_person_rec.PERSON_LAST_NAME );

---------------------------------------------------------------------------------------------------
--p_relationship_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_relationship_rec 5 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_relationship_rec.subject_type       );
DBMS_OUTPUT.PUT_LINE(p_relationship_rec.subject_table_name );
DBMS_OUTPUT.PUT_LINE(p_relationship_rec.object_type        );
DBMS_OUTPUT.PUT_LINE(p_relationship_rec.relationship_code  );
DBMS_OUTPUT.PUT_LINE(p_relationship_rec.object_table_name  );

---------------------------------------------------------------------------------------------------
--p_contact_point_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_contact_point_rec 2 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_contact_point_rec.owner_table_name );
DBMS_OUTPUT.PUT_LINE(p_Contact_point_rec.status           );

---------------------------------------------------------------------------------------------------
--phone_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('phone_rec 4 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_phone_rec.phone_line_type     );
DBMS_OUTPUT.PUT_LINE(p_phone_rec.phone_country_code  );
DBMS_OUTPUT.PUT_LINE(p_phone_rec.phone_area_code     );
DBMS_OUTPUT.PUT_LINE(p_phone_rec.phone_country_code  );

---------------------------------------------------------------------------------------------------
--p_email_rec
---------------------------------------------------------------------------------------------------
DBMS_OUTPUT.PUT_LINE('p_email_rec 1 ###########################'         );
DBMS_OUTPUT.PUT_LINE(p_email_rec.email_address  );

END;