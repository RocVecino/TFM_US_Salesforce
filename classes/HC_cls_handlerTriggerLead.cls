public without sharing class HC_cls_handlerTriggerLead {
    
    public static void afterUpdateContratoFirmado(List<Lead> listNew, Map<Id, Lead> newMap, List<Lead> oldList, Map<Id,Lead> oldMap) {
        
        if(!listNew.isEmpty()){
            for(Lead lead : listNew){
                Lead oldLead = oldMap.get(lead.id);
                if(lead.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HC_rt_cPotencialMbrSeguro').getRecordTypeId() && lead.Status == 'Contrato Firmado' && oldLead.Status != 'Contrato Firmado' ){
                    Account newAccount = new Account();
                    newAccount.ShippingCity = lead.City;
                    newAccount.AnnualRevenue = lead.AnnualRevenue;
                    newAccount.ShippingCountry = lead.Country;
                    newAccount.Description = lead.Description;
                    //newAccount.PersonEmail = lead.Email;
                    newAccount.HC_fld_cuentaBancaria__c = lead.HC_fld_cuentaBancaria__c;
                    newAccount.HC_fld_documentoIdentidad__c = lead.HC_fld_documentoIdentidad__c;
                    newAccount.HC_fld_estadoCivil__c = lead.HC_fld_estadoCivil__c;
                    newAccount.HC_fld_frecuenciaPago__c = lead.HC_fld_frecuenciaPago__c;
                    newAccount.HC_fld_identificacionBanco__c = lead.HC_fld_identificacionBanco__c;
                    newAccount.HC_fld_preferenciasComunicacion__c = lead.HC_fld_preferenciasComunicacion__c;
                    newAccount.HC_fld_tipoPago__c = lead.HC_fld_tipoPago__c;
                    //newAccount.PersonBirthdate = lead.HealthCloudGA__BirthDate__c;
                    //newAccount.PersonGenderIdentity = lead.HealthCloudGA__Gender__c;
                    newAccount.ParentId = lead.HealthCloudGA__RelatedAccount__c;
                    //newAccount.OwnerId = lead.OwnerId;
                    newAccount.Phone = lead.Phone;
                    newAccount.ShippingPostalCode = lead.PostalCode;
                    newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HC_rt_miembroCompania').getRecordTypeId();
                    newAccount.ShippingState = lead.State;
                    newAccount.ShippingStreet = lead.Street;
                    newAccount.Name = lead.FirstName+' '+lead.LastName;
                    insert newAccount;
                    
                    //Creamos los contactos de emergencias relacionados con el usuario
                    Contact newContact = new Contact();
                    newContact.FirstName = lead.HealthCloudGA__EmergencyContactFirstName__c;
                    newContact.LastName = lead.HealthCloudGA__EmergencyContactLastName__c;
                    newContact.Phone = lead.HealthCloudGA__EmergencyContactPhone__c;
                    newContact.AccountId = lead.HealthCloudGA__RelatedAccount__c;
                    newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('HC_rt_contactmiembroCompania').getRecordTypeId();
                    
                    insert newContact;
                    
                    AccountContactRelation newAccountContactRelation = new AccountContactRelation();
                    newAccountContactRelation.AccountId = newAccount.Id;
                    newAccountContactRelation.ContactId = newContact.Id;
                    newAccountContactRelation.HC_fld_tipoContacto__c = 'Contacto de emergencia';
                    
                    insert newAccountContactRelation;
                    
                    //Creamos El contacto para el usuario de portal user
                    Contact newContactPortal = new Contact();
                    newContactPortal.AccountId = newAccount.Id;
                    newContactPortal.Email = lead.Email;
                    newContactPortal.FirstName = lead.FirstName;
                    newContactPortal.LastName = lead.LastName;
                    newContactPortal.Phone = lead.Phone;
                    newContactPortal.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('HC_rt_portalUser').getRecordTypeId();
                    
                    insert newContactPortal;
                    
                    Id profileId = [Select Id From Profile Where Name = 'Customer Community Plus Login User' LIMIT 1].Id;
                    
                    //Creamos User comunidad
                    User communityUser = new User(FirstName = lead.FirstName, LastName = lead.LastName,
                                                  Email = lead.Email,
                                                  ContactId = newContactPortal.Id,
                                                  ProfileId = profileId, 
                                                  UserName = lead.Email+lead.FirstName,
                                                  Alias = lead.FirstName, 
                                                  TimeZoneSidKey = 'America/New_York',
                                                  LocaleSidKey = 'en_US', 
                                                  EmailEncodingKey = 'ISO-8859-1', 
                                                  LanguageLocaleKey = 'en_US',
                                                  Department = 'Miembro de la Compañía');
                    
                    insert communityUser;
                    
                    List<CareProgramEnrollee> lstCareProgramEnrolle = [select CareProgramId, CareProgram.BudgetAmount, AccountId from CareProgramEnrollee where LeadId = :lead.id ];
                    if(!lstCareProgramEnrolle.isEmpty()){
                        for(CareProgramEnrollee cpe : lstCareProgramEnrolle){
                            cpe.AccountId = newAccount.Id;
                        }
                    }
                    update lstCareProgramEnrolle;
                    
                    List<HealthCondition> lstHcondition = [select PatientId from HealthCondition where HC_fld_lead__c = :lead.id];
                    
                    if(!lstHcondition.isEmpty()){
                        for(HealthCondition hc : lstHcondition){
                            hc.RecordCreatorId = newAccount.Id;
                        }
                    }
                    
                    update lstHcondition;
                    
                    Contract newContrato = new Contract(); 
                    newContrato.AccountId =  newAccount.Id;
                    newContrato.BillingCity =  lead.City;
                    newContrato.BillingCountry =  lead.Country;
                    newContrato.BillingPostalCode =  lead.PostalCode;
                    newContrato.BillingState =  lead.State;
                    newContrato.BillingStreet =  lead.Street;
                    newContrato.CompanySignedId =  lead.OwnerId;
                    newContrato.CompanySignedDate =  Date.today();
                    newContrato.Name =  newAccount.Name;
                    newContrato.StartDate =  Date.Today();
                    newContrato.CustomerSignedId =  newContactPortal.Id;
                    newContrato.Description =  lead.Description;
                    newContrato.Status =  'Activo';
                    newContrato.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('HC_rt_contratoSeguroCliente').getRecordTypeId();
                    
                    insert newContrato;
                    
                    ContractGroupPlan newContractGroupPlan = new ContractGroupPlan();
                    newContractGroupPlan.Name = newAccount.Name;  
                    newContractGroupPlan.AccountId = newAccount.Id;  
                    newContractGroupPlan.ContractId = newContrato.Id;           
                    newContractGroupPlan.RecordTypeId = Schema.SObjectType.ContractGroupPlan.getRecordTypeInfosByDeveloperName().get('HC_rt_contratoSeguroCliente').getRecordTypeId();
                    
                    insert newContractGroupPlan;
                    
                    InsurancePolicy newInsurancePolicy = new InsurancePolicy();
                    newInsurancePolicy.RecordTypeId = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('HC_rt_polizaSeguros').getRecordTypeId();   
                    newInsurancePolicy.ContractGroupPlanId = newContractGroupPlan.id;   
                    newInsurancePolicy.HC_fld_renovacionAutomatica__c = true;   
                    newInsurancePolicy.DateRenewed = date.today().addYears(1);
                    newInsurancePolicy.OwnerId = lead.OwnerId;   
                    newInsurancePolicy.PremiumAmount = lstCareProgramEnrolle[0].CareProgram.BudgetAmount;   
                    newInsurancePolicy.PremiumFrequency = lead.HC_fld_frecuenciaPago__c;   
                    newInsurancePolicy.NameInsuredId = lead.HealthCloudGA__RelatedAccount__c;   
                    newInsurancePolicy.PolicyName = newAccount.Name;   
                    newInsurancePolicy.Name = newAccount.Name;  
                    
                    insert newInsurancePolicy;
                    
                    List<CoverageBenefit> lstCoverageBenefit = [SELECT name, BenefitNotes FROM CoverageBenefit where HC_fld_careProgram__c  = :lstCareProgramEnrolle[0].CareProgramId];
                    
                    List<InsurancePolicyCoverage> lstInsurancePolicyCoverage = new List<InsurancePolicyCoverage>();
                    if(!lstCoverageBenefit.isEmpty()){
                        for( CoverageBenefit cb : lstCoverageBenefit){
                            InsurancePolicyCoverage newInsurancePolicyCoverage = new InsurancePolicyCoverage();
                            newInsurancePolicyCoverage.CoverageName = cb.Name;
                            newInsurancePolicyCoverage.InsurancePolicyId = newInsurancePolicy.ID;
                            newInsurancePolicyCoverage.RecordTypeId = Schema.SObjectType.InsurancePolicyCoverage.getRecordTypeInfosByDeveloperName().get('HC_rt_coverturaPolizaSeguros').getRecordTypeId();   
                            lstInsurancePolicyCoverage.add(newInsurancePolicyCoverage);
                        }
                    }
                    
                    insert lstInsurancePolicyCoverage;
                    
                    List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
                    for(ContentDocumentLink cdl : [select LinkedEntityId,ContentDocumentId, Visibility,  ShareType from ContentDocumentLink where LinkedEntityId = :lead.id]){
                        ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
                        newContentDocumentLink.LinkedEntityId = newContrato.id;
                        newContentDocumentLink.ContentDocumentId = cdl.ContentDocumentId;
                        newContentDocumentLink.Visibility = cdl.Visibility;
                        newContentDocumentLink.ShareType = cdl.ShareType;
                        lstContentDocumentLink.add(newContentDocumentLink);
                    }
                    
                    insert lstContentDocumentLink;
                }
            }
        }
        
    }
    
}