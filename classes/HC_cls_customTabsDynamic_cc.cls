/**
* @File Name : HC_cls_customTabsDynamic_cc.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : August 12, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 12, 2024 |   | Initial Version
**/

public without sharing class HC_cls_customTabsDynamic_cc {
	@testVisible private static final String CLASS_NAME = 'HC_cls_customTabsDynamic_cc';
	@AuraEnabled
	public static String checkUserProfile(){
		String method = 'checkCliente';
        System.debug(CLASS_NAME + ' - ' + method + ': INICIO');
        
        List<Profile> lstProfile = new List<Profile>();
        List<User> lstUser = new List<User>();

		String profile;

        try{
            
            lstProfile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
            
			if(!lstProfile.isEmpty()){
				if(lstProfile[0].Name == 'Guest License User'){
					profile = lstProfile[0].Name;
				}else{
					lstUser = [SELECT Department FROM User WHERE Id =: UserInfo.getUserId()];
					if(!lstUser.isEmpty()){
						if(lstUser[0].Department == 'Corredor de Seguros'){
							profile  = 'Corredor de Seguros';
						}else if(lstUser[0].Department == 'Miembro de la Compañía'){
							profile  = 'Miembro de la Compañía';
						}else{
							profile = 'Guest License User';
						}
					}
				}
			}
            
        }catch(Exception ex){
            System.debug('Usuario: '+UserInfo.getName()+' Clase: '+CLASS_NAME+' Método: '+method+' mensaje error: '+ex.getMessage()+' trazaExcepción:  '+ex.getStackTraceString());
        }
        return profile;
	}
}