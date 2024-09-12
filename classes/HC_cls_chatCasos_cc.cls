/*
@name: HC_cls_chatCasos_cc
@version: 1.0
@creation date: 09/08/2024
@author: Rocío Vecino Torres
*/
public without sharing class HC_cls_chatCasos_cc {
    @testVisible private static final String CLASS_NAME = 'HC_cls_chatCasos_cc';
    
    public with sharing class WrapperCliente {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String clienteId { get; set; }
        @AuraEnabled public String objName { get; set; }
    }
    
    @AuraEnabled
    public static WrapperCliente checkCliente(String phone) {
        String method = 'checkCliente';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        WrapperCliente resultWrapper = new WrapperCliente();   
        
        List<Lead> lstLead = new List<Lead>();
        List<Account> lstAccount = new List<Account>();
        
        try{
            
            lstLead = [SELECT Name FROM Lead WHERE RecordTypeId = :Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HC_rt_cPotencialMbrSeguro').getRecordTypeId() AND Phone =: phone];
            lstAccount = [SELECT Name FROM Account WHERE RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HC_rt_miembroCompania').getRecordTypeId() AND Phone =: phone];
            
            if(!lstAccount.isEmpty()){
                resultWrapper.name = lstAccount[0].Name;
                resultWrapper.clienteId = lstAccount[0].id;
                resultWrapper.objName = 'Cliente';
            }else{
                if(!lstLead.isEmpty()){
                    resultWrapper.name = lstLead[0].Name;
                    resultWrapper.clienteId = lstLead[0].id;
                    resultWrapper.objName = 'Cliente Potencial';
                }
            }
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
        }
        return resultWrapper;
    }

}