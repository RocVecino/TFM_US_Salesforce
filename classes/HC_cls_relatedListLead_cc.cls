/**
* @File Name : HC_cls_relatedListLead_cc.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : August 15, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 15, 2024 |   | Initial Version
**/

public without sharing class HC_cls_relatedListLead_cc {
	@testVisible private static final String CLASS_NAME = 'HC_cls_relatedListLead_cc';

	public with sharing class WrapperCasos {
        @AuraEnabled public String caseNumber { get; set; }
        @AuraEnabled public String subjectCase { get; set; }
        @AuraEnabled public String typeCase { get; set; }
        @AuraEnabled public Date dateOpened { get; set; }
		@AuraEnabled public String priority { get; set; }
		@AuraEnabled public String idCase { get; set; }
		@AuraEnabled public String estado { get; set; }
	}

	public with sharing class WrapperCondiciones {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String descripcion { get; set; }
        @AuraEnabled public String estado { get; set; }
		@AuraEnabled public String severidad { get; set; }
	}

	@AuraEnabled
	public static List<WrapperCasos> getCasos(String recordId){
		String method = 'checkCliente';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        List<Case> lstCase= new List<Case>();

		List<WrapperCasos> lstResultWrapper = new List<WrapperCasos>();

        try{
            
            lstCase = [select CaseNumber, Subject, Type, CreatedDate, Priority, Status
						from case 
						where HC_fld_lead__c =: recordId];

			if(!lstCase.isEmpty()){
				for (Case caseL : lstCase){
					WrapperCasos newWrapperCasos = new WrapperCasos();
					newWrapperCasos.caseNumber = caseL.CaseNumber;
					newWrapperCasos.subjectCase = caseL.Subject;
					newWrapperCasos.typeCase = caseL.Type;
					newWrapperCasos.dateOpened = Date.valueOf(caseL.CreatedDate);
					newWrapperCasos.priority = caseL.Priority;
					newWrapperCasos.idCase = '/case/'+caseL.Id;
					newWrapperCasos.estado = caseL.Status;
					lstResultWrapper.add(newWrapperCasos);
				}
			}
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
        }
        return lstResultWrapper;
	}
	@AuraEnabled
	public static String newCaso(String recordId, String origin, String reason, String description, String subject, String priority){
		String method = 'newCaso';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        List<Case> lstCase= new List<Case>();
		String idCase = null;

        try{
            
			List<User> lstUser = [select Contact.AccountId, Account.name, Account.RecordType.name from user where id = :UserInfo.getUserId()];

			Case newCase = new Case();
			newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HC_rt_casosCompaniaSeguros').getRecordTypeId();
			newCase.Origin = origin;
			newCase.Reason = reason;
			newCase.Description = description;
			newCase.Subject = subject;
			newCase.HC_fld_lead__c = recordId;
			newCase.AccountId = lstUser[0].Contact.AccountId;

			lstCase.add(newCase);
			insert lstCase;
			idCase = lstCase[0].id;
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
        }
        return idCase;
	}

	@AuraEnabled
	public static List<WrapperCondiciones> getCondiciones(String recordId){
		String method = 'checkCliente';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        List<HealthCondition> lstHealthCondition= new List<HealthCondition>();

		List<WrapperCondiciones> lstResultWrapper = new List<WrapperCondiciones>();

        try{
            
            lstHealthCondition = [select ProblemName, ProblemDescription, Severity, ConditionStatus, HC_fld_lead__c 
									from HealthCondition 
									where HC_fld_lead__c =: recordId];

			if(!lstHealthCondition.isEmpty()){
				for (HealthCondition caseL : lstHealthCondition){
					WrapperCondiciones newWrapperCasos = new WrapperCondiciones();
					newWrapperCasos.name = caseL.ProblemName;
					newWrapperCasos.descripcion = caseL.ProblemDescription;
					newWrapperCasos.estado = caseL.Severity;
					newWrapperCasos.severidad = caseL.ConditionStatus;
					lstResultWrapper.add(newWrapperCasos);
				}
			}
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
        }
        return lstResultWrapper;
	}

	@AuraEnabled
	public static String newHCondition(String recordId, String severity, String problemDescription, String problemName, String conditionStatus){
		String method = 'newHCondition';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        List<HealthCondition> lstHealthCondition= new List<HealthCondition>();
		String idCase = null;

        try{
            
			List<User> lstUser = [select Contact.AccountId, Account.name, Account.RecordType.name from user where id = :UserInfo.getUserId()];

			HealthCondition newCHealthCondition = new HealthCondition();
			newCHealthCondition.RecordTypeId = Schema.SObjectType.HealthCondition.getRecordTypeInfosByDeveloperName().get('HC_rt_condicionSaludCliente').getRecordTypeId();
			newCHealthCondition.ConditionStatus = conditionStatus;
			newCHealthCondition.ProblemName = problemName;
			newCHealthCondition.ProblemDescription = problemDescription;
			newCHealthCondition.Severity = severity;
			newCHealthCondition.HC_fld_lead__c = recordId;
			newCHealthCondition.PatientId = lstUser[0].Contact.AccountId;

			lstHealthCondition.add(newCHealthCondition);
			insert lstHealthCondition;
			idCase = lstHealthCondition[0].id;
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
        }
        return idCase;
	}
}