/**
* @File Name : HC_cls_accionesClientePotencial_cc.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : August 18, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 18, 2024 |   | Initial Version
**/

public without sharing class HC_cls_accionesClientePotencial_cc {
	@testVisible private static final String CLASS_NAME = 'HC_cls_accionesClientePotencial_cc';

	public with sharing class WrapperCliente {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String documentosNecesarios { get; set; }
		@AuraEnabled public String estado { get; set; }
    }
    public with sharing class WrapperFile {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Boolean showFileName { get; set; }
		@AuraEnabled public String fileName { get; set; }
        @AuraEnabled public String fileBase64 { get; set; }
    }

	@AuraEnabled
    public static WrapperCliente checkDNI(String dni) {
        String method = 'checkDNI';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        WrapperCliente resValidateDni = new WrapperCliente();   
        
        List<Lead> lstLead = new List<Lead>();
        
        try{
            
            lstLead = [SELECT Name, HC_fld_documentosNecesariosAdjuntar__c, Status FROM Lead 
						WHERE RecordTypeId = :Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HC_rt_cPotencialMbrSeguro').getRecordTypeId() 
						AND HC_fld_documentoIdentidad__c =: dni];
            
            if(!lstLead.isEmpty()){
                resValidateDni.name = lstLead[0].Name;
				resValidateDni.documentosNecesarios = lstLead[0].HC_fld_documentosNecesariosAdjuntar__c;
				resValidateDni.estado = lstLead[0].Status;
            }else{
				resValidateDni.name = 'No se ha encontrado nada con su Identificación';
			}
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
			resValidateDni.name = 'Ha habido un error durante su identifiación';
		}
        return resValidateDni;
    }

    @AuraEnabled
    public static String uploadFiles(String dni, List<WrapperFile> lstFiles) {
        String method = 'uploadFiles';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        String uploadFiles;   
        
        List<Lead> lstLead = new List<Lead>();
        
        try{
            
            lstLead = [SELECT Name, HC_fld_documentosNecesariosAdjuntar__c, Status FROM Lead 
						WHERE RecordTypeId = :Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('HC_rt_cPotencialMbrSeguro').getRecordTypeId() 
						AND HC_fld_documentoIdentidad__c =: dni];

            
            
                if(!lstLead.isEmpty()){
                    if(!lstFiles.isEmpty()){
                        for(WrapperFile file : lstFiles){
                            if(file.fileBase64!=null && file.fileBase64 != ''){
                                ContentVersion contentVersion = new ContentVersion();
                                contentVersion.ContentLocation = 'S';
                                String fileType = null;
                                if(file.fileBase64.startsWith('JVBERi0xLj')){
                                    fileType = '.pdf';
                                }else{
                                    fileType = '.png';
                                }
                                contentVersion.PathOnClient = file.label+fileType;
                                contentVersion.Title = file.label+'_'+file.fileName;
                                contentVersion.VersionData = EncodingUtil.base64Decode(file.fileBase64);

                                insert contentVersion;

                                List<ContentVersion> queryContentVersion = new List<ContentVersion> ();
                                
                                queryContentVersion =  [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Id = :contentVersion.id];
                                System.debug(queryContentVersion);
                                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                                contentDocumentLink.LinkedEntityId = lstLead[0].id;
                                contentDocumentLink.ShareType = 'V'; // Inferred permission
                                contentDocumentLink.Visibility = 'AllUsers';
                                contentDocumentLink.ContentDocumentId = queryContentVersion[0].ContentDocumentId;

                                insert contentDocumentLink;

                                lstLead[0].Status = 'Pendiente Generar Contrato';

                                update lstLead;

                                uploadFiles = 'OK';
                            }
                        }
                    }else{
                        uploadFiles = 'No se hay ningún archivo que cargar';
                    }
                    
                }else{
                    uploadFiles = 'No se ha encontrado nada con su Identificación';
                }
            
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
			uploadFiles = 'Ha habido un error durante la carga de los archivos';
		}
        return uploadFiles;
    }
}