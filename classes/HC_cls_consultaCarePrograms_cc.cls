/*
@name: HC_cls_consultaCarePrograms_cc
@version: 1.0
@creation date: 03/08/2024
@author: Rocío Vecino Torres
*/
public without sharing class HC_cls_consultaCarePrograms_cc {
    @testVisible private static final String CLASS_NAME = 'HC_cls_consultaCarePrograms_cc';
    
    public with sharing class WrapperClassList {
        @AuraEnabled public List<WrapperClass> wrapperClass { get; set; }
    }
    
    public with sharing class WrapperClass {
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String descripcion { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Boolean checkEdadLimite { get; set; }
        @AuraEnabled public Decimal edadLimite { get; set; }
        @AuraEnabled public Boolean checkEdadMaxPermanencia { get; set; }
        @AuraEnabled public Decimal descFormPagoTrim { get; set; }
        @AuraEnabled public Decimal descFormPagoAnual { get; set; }
        @AuraEnabled public Boolean checkPeriodoCarencia { get; set; }
        @AuraEnabled public String periodoCalenciaPodologia { get; set; }
        @AuraEnabled public String periodoCarenciaDiagAltaTec { get; set; }
        @AuraEnabled public String periodoCarenciaTratEspec { get; set; }
        @AuraEnabled public String periodoCarenciaPrepAsistParto { get; set; }
        @AuraEnabled public String periodoCarenciaTratInfertilidad { get; set; }
        @AuraEnabled public Boolean tieneCovertura { get; set; }
        @AuraEnabled public String imagen { get; set; }
        @AuraEnabled public List<WrapperClassCoverage> listaCoverturas { get; set; }
    }
    
    public with sharing class WrapperClassCoverage {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String descripcion { get; set; }
    }
    
    @AuraEnabled
    public static WrapperClassList getCarePrograms() {
        String method = 'getCarePrograms';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        WrapperClassList resultWrapper = new WrapperClassList();   
        List<WrapperClass> listWrapperClass = new List<WrapperClass>();
        
        List<CareProgram> lstCareProgram = new List<CareProgram>();
        List<CoverageBenefit> lstCoverageBenefit = new List<CoverageBenefit>();
        
        Map<Id, List<CoverageBenefit>> mapCareProgramCoverage = new Map<Id, List<CoverageBenefit>>();
        List<CoverageBenefit> listCoverageMap = new  List<CoverageBenefit>();
        
        try{
            
            lstCareProgram = [SELECT  Name, RecordTypeId, StartDate, EndDate, Description, BudgetAmount, HC_fld_checkEdadLimiteContract__c, HC_fld_edadLimiteContratacion__c, HC_fld_checkEdadMaxPerm__c, 
                              HC_fld_descFormPagoTrimestral__c, HC_fld_descFormPagoAnual__c, HC_fld_checkPeriodoCarencia__c, HC_fld_periodoCarenciaPodologia__c, HC_fld_periodoCarenciaDiagAltaTec__c, 
                              HC_fld_periodoCarenciaTratEsp__c, HC_fld_periodoCarenciaPrepAsistParto__c, HC_fld_periodoCarenciaTratInfertilidad__c 
                              FROM CareProgram 
                              WHERE EndDate >= :Date.today() and RecordTypeId = :Schema.SObjectType.CareProgram.getRecordTypeInfosByDeveloperName().get('HC_rt_seguroSalud').getRecordTypeId()];
            
            lstCoverageBenefit = [SELECT name, BenefitNotes, HC_fld_careProgram__c FROM CoverageBenefit WHERE RecordTypeId = :Schema.SObjectType.CoverageBenefit.getRecordTypeInfosByDeveloperName().get('HC_rt_coverturaSeguroSalud').getRecordTypeId()];
            
            if(!lstCoverageBenefit.isEmpty()){
                for(CoverageBenefit coverage : lstCoverageBenefit){
                    if (mapCareProgramCoverage.containsKey(coverage.HC_fld_careProgram__c)) {
                        listCoverageMap = mapCareProgramCoverage.get(coverage.HC_fld_careProgram__c);
                        listCoverageMap.add(coverage);
                        mapCareProgramCoverage.put(coverage.HC_fld_careProgram__c, listCoverageMap);
                    } else {
                        listCoverageMap = new List<CoverageBenefit>();
                        listCoverageMap.add(coverage);
                        mapCareProgramCoverage.put(coverage.HC_fld_careProgram__c, listCoverageMap);
                    }
                }
            }
            
            if(!lstCareProgram.isEmpty()){
                for(CareProgram cprogram : lstCareProgram){
                    WrapperClass newWrapperClass = new WrapperClass();
                    newWrapperClass.amount = cprogram.BudgetAmount;
                    newWrapperClass.descripcion = cprogram.Description;
                    newWrapperClass.name = cprogram.Name;
                    newWrapperClass.checkEdadLimite = cprogram.HC_fld_checkEdadLimiteContract__c;
                    newWrapperClass.edadLimite = cprogram.HC_fld_edadLimiteContratacion__c;
                    newWrapperClass.checkEdadMaxPermanencia = cprogram.HC_fld_checkEdadMaxPerm__c;
                    newWrapperClass.descFormPagoTrim = cprogram.HC_fld_descFormPagoTrimestral__c;
                    newWrapperClass.descFormPagoAnual = cprogram.HC_fld_descFormPagoAnual__c;
                    newWrapperClass.checkPeriodoCarencia = cprogram.HC_fld_checkPeriodoCarencia__c;
                    newWrapperClass.periodoCalenciaPodologia = cprogram.HC_fld_periodoCarenciaPodologia__c;
                    newWrapperClass.periodoCarenciaDiagAltaTec = cprogram.HC_fld_periodoCarenciaDiagAltaTec__c;
                    newWrapperClass.periodoCarenciaTratEspec = cprogram.HC_fld_periodoCarenciaTratEsp__c;
                    newWrapperClass.periodoCarenciaPrepAsistParto = cprogram.HC_fld_periodoCarenciaPrepAsistParto__c;
                    newWrapperClass.periodoCarenciaTratInfertilidad = cprogram.HC_fld_periodoCarenciaTratInfertilidad__c;
                    newWrapperClass.tieneCovertura = mapCareProgramCoverage.containsKey(cprogram.id) ? true : false;
                    if(cprogram.Name.contains('Dental')){
                        newWrapperClass.imagen = 'HC_sr_imagenSeguroDental';
                    }else if(cprogram.Name.contains('Familiar')){
                        newWrapperClass.imagen = 'HC_sr_imagenSeguroFamiliar';
                    }else{
                        newWrapperClass.imagen = 'HC_sr_imagenSeguroIndividual';
                    }
                    
                    if(mapCareProgramCoverage.containsKey(cprogram.id)){
                        List<WrapperClassCoverage> listWrapperClassCoverage = new List<WrapperClassCoverage>();
                        for(CoverageBenefit coverage : mapCareProgramCoverage.get(cprogram.id)){
                            WrapperClassCoverage newWrapperClassCoverage = new WrapperClassCoverage();
                            newWrapperClassCoverage.name = coverage.Name;
                            newWrapperClassCoverage.descripcion =  coverage.BenefitNotes;
                            listWrapperClassCoverage.add(newWrapperClassCoverage);
                        }
                        newWrapperClass.listaCoverturas = listWrapperClassCoverage;
                    }
                    listWrapperClass.add(newWrapperClass);
                }
            }
            resultWrapper.wrapperClass = listWrapperClass;
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
        }
        return resultWrapper;
    }
    @AuraEnabled
    public static void createLead(String name, String apellidos, String email, String phone, Boolean wantsInfo, String careProgramName) {
        String method = 'createLead';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        List<Lead> listLeadCreate = new List<Lead>();
        List<CareProgramEnrollee> listRelCareProgramLead = new List<CareProgramEnrollee>();
        List<CareProgram> careProgram = new List<CareProgram>();
        List<User> corredorSeguroList = new List<User>();
        Map<Id, Account> mapAccountCorredorSeguros = new Map<Id, Account>();
        List<Case> lstCase = new List<Case>();
        
        try{
            
            careProgram = [SELECT Id, Name FROM CareProgram WHERE Name = :careProgramName];
            mapAccountCorredorSeguros = new Map<Id, Account>([SELECT ID FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HC_rt_corredorSeguros').getRecordTypeId()]);
            
            for(Lead cp : [SELECT HealthCloudGA__RelatedAccount__c FROM Lead WHERE RecordTypeId = :Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HC_rt_cPotencialMbrSeguro').getRecordTypeId()]){
                if(mapAccountCorredorSeguros.containsKey(cp.HealthCloudGA__RelatedAccount__c)){
                    mapAccountCorredorSeguros.remove(cp.HealthCloudGA__RelatedAccount__c);
                }
            }
            
            if(mapAccountCorredorSeguros.size()==0){
                mapAccountCorredorSeguros = new Map<Id, Account>([SELECT ID FROM Account WHERE RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HC_rt_corredorSeguros').getRecordTypeId()]);
            }
            
            Id accCorredorSegurosAleatoria = mapAccountCorredorSeguros.values()[0].id;
            
            corredorSeguroList = [SELECT  Contact.AccountId, Id FROM User WHERE Id = '005Qy000006kQvJIAU'];
            
            listLeadCreate = [SELECT Name, FirstName, LastName, Phone, Email, OwnerId, HealthCloudGA__RelatedAccount__c, HC_fld_quieroInfo__c FROM Lead 
                              WHERE   RecordTypeId = :Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HC_rt_cPotencialMbrSeguro').getRecordTypeId() AND 
                              (Phone = :phone)];
            
            if(!listLeadCreate.isEmpty()){
                
                listLeadCreate[0].Phone = phone;
                listLeadCreate[0].Email = email;
                listLeadCreate[0].OwnerId = corredorSeguroList[0].id;
                listLeadCreate[0].HealthCloudGA__RelatedAccount__c = accCorredorSegurosAleatoria;
                listLeadCreate[0].HC_fld_quieroInfo__c = wantsInfo;
                listLeadCreate[0].Status = 'Solicitud de Llamada';
                listLeadCreate[0].RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HC_rt_cPotencialMbrSeguro').getRecordTypeId();
                update listLeadCreate;
                
            }else{
                Lead newLead = new Lead();
                newLead.FirstName = name;
                newLead.LastName = apellidos;
                newLead.Phone = phone;
                newLead.Email = email;
                newLead.OwnerId = corredorSeguroList[0].id;
                newLead.HealthCloudGA__RelatedAccount__c = accCorredorSegurosAleatoria;
                newLead.HC_fld_quieroInfo__c = wantsInfo;
                newLead.Status = 'Solicitud de Llamada';
                newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HC_rt_cPotencialMbrSeguro').getRecordTypeId();
                
                listLeadCreate.add(newLead);
                
                insert listLeadCreate;
                
                CareProgramEnrollee newCareProgramEnrollee = new CareProgramEnrollee();
                newCareProgramEnrollee.CareProgramId = careProgram[0].id;
                newCareProgramEnrollee.LeadId = listLeadCreate[0].id;
                newCareProgramEnrollee.Name = listLeadCreate[0].Name+' - '+careProgram[0].Name;  
                newCareProgramEnrollee.RecordTypeId = Schema.SObjectType.CareProgramEnrollee.getRecordTypeInfosByDeveloperName().get('HC_rt_seguroSaludRltship').getRecordTypeId();
                listRelCareProgramLead.add(newCareProgramEnrollee);
                
                insert listRelCareProgramLead;
                
            }
            
            Case newCase = new Case();
            newCase.AccountId = accCorredorSegurosAleatoria;
            newCase.Origin = 'Web';
            newCase.Reason = 'Solicitud de Información';
            newCase.Priority = 'Medium';
            newCase.Status = 'New';
            newCase.Subject = 'Nuevo Cliente Potencial';
            newCase.HC_fld_lead__c = listLeadCreate[0].id;
            newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HC_rt_casosCompaniaSeguros').getRecordTypeId();
            
            lstCase.add(newCase);
            
            insert lstCase;
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
        }
    }
}