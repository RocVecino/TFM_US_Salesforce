/**
* @File Name : HC_cls_tablaLeads_cc.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 8, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 8, 2024 |   | Initial Version
**/

public without sharing class HC_cls_tablaLeads_cc {


	public with sharing class WrapperLeads {
        @AuraEnabled public String idLead { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String estado { get; set; }
		@AuraEnabled public String email { get; set; }
		@AuraEnabled public String phone { get; set; }
		@AuraEnabled public String dni { get; set; }
		@AuraEnabled public String preferenciaCom { get; set; }
	}


	@AuraEnabled
	Public static List<WrapperLeads> getLeads(String estado){
		List<WrapperLeads> lstResultWrapper = new List<WrapperLeads>();

		List<Lead> lstLead = new List<Lead>();

		if(estado == 'Todays Leads'){
			lstLead = [SELECT Name, HC_fld_documentoIdentidad__c, HC_fld_preferenciasComunicacion__c, Email, Phone, Status, OwnerId, CreatedDate 
					FROM Lead WHERE CreatedDate >= :Date.today()-1 AND OwnerId = :UserInfo.getUserId()];
		}else{
			lstLead = [SELECT Name, HC_fld_documentoIdentidad__c, HC_fld_preferenciasComunicacion__c, Email, Phone, Status, OwnerId, CreatedDate 
					FROM Lead WHERE Status = :estado AND OwnerId = :UserInfo.getUserId()];
		}
		if(!lstLead.isEmpty()){
			for(Lead ld : lstLead){
				WrapperLeads newWrapperLeads = new WrapperLeads();
				newWrapperLeads.idLead = '/lead/'+ld.id;
				newWrapperLeads.name = ld.Name;
				newWrapperLeads.estado = ld.Status;
				newWrapperLeads.email = ld.Email;
				newWrapperLeads.phone = ld.Phone;
				newWrapperLeads.dni = ld.HC_fld_documentoIdentidad__c;
				newWrapperLeads.preferenciaCom = ld.HC_fld_preferenciasComunicacion__c;

				lstResultWrapper.add(newWrapperLeads);
			}
		}
		return lstResultWrapper;
		
	}

	@AuraEnabled
	Public static List<WrapperLeads> getAccounts(){
		List<WrapperLeads> lstResultWrapper = new List<WrapperLeads>();

		List<Account> lstLead = new List<Account>();

		
		lstLead = [SELECT Name, HC_fld_documentoIdentidad__c, HC_fld_preferenciasComunicacion__c, Phone 
					FROM Account WHERE RecordType.DeveloperName = 'HC_rt_miembroCompania'];
		
		if(!lstLead.isEmpty()){
			for(Account ld : lstLead){
				WrapperLeads newWrapperLeads = new WrapperLeads();
				newWrapperLeads.idLead = '/account/'+ld.id;
				newWrapperLeads.name = ld.Name;
				newWrapperLeads.phone = ld.Phone;
				newWrapperLeads.dni = ld.HC_fld_documentoIdentidad__c;
				newWrapperLeads.preferenciaCom = ld.HC_fld_preferenciasComunicacion__c;

				lstResultWrapper.add(newWrapperLeads);
			}
		}
		return lstResultWrapper;
		
	}
}