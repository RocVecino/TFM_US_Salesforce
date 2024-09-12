/**
* @File Name : HC_cls_queueableEnfermedadesInfec.cls
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
public class HC_cls_queueableEnfermedadesInfec implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        List<String> days = new List<String>();
        List<HC_obj_enfermedadesInfecciosas__c> lstEnfermedadesLst = new List<HC_obj_enfermedadesInfecciosas__c>();
        List<HC_obj_ciudades__c> lstCiudades = new List<HC_obj_ciudades__c>();
        Map<String, HC_obj_enfermedadesInfecciosas__c> mapWpEnfInfecciosas = new Map<String,HC_obj_enfermedadesInfecciosas__c>();//fecha_name_province
        Map<String, HC_obj_ciudades__c> mapCity = new Map<String,HC_obj_ciudades__c>();//provincia_cityname
        
        for (Integer i = 1; i <=30; i++) {
            String day = i < 10 ? '0' + String.valueOf(i) : String.valueOf(i);
            days.add(day);
        }
        for(String dia : days){
            HttpRequest req = new HttpRequest();
            req.setEndPoint('https://covid-19-statistics.p.rapidapi.com/reports?region_name=Spain&date=2022-09-'+dia);
            req.setHeader('x-rapidapi-key', 'ef08404a40mshc033f1db7a2e0a4p137357jsn20125fb99658');
            req.setHeader('x-rapidapi-host', 'covid-19-statistics.p.rapidapi.com');
            req.setMethod('GET');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            HC_cls_JSON2Apex myJSONInstance = (HC_cls_JSON2Apex) JSON.deserialize(res.getBody(), HC_cls_JSON2Apex.class);
            
            if(!myJSONInstance.data.isEmpty()){
                for(HC_cls_JSON2Apex.Data dt : myJSONInstance.data){
                    String key = String.valueOf(Date.valueOf(dt.last_update))+'_'+dt.region.name+'_'+dt.region.province;
                    
                    if(!mapWpEnfInfecciosas.containsKey(key)){
                        HC_obj_enfermedadesInfecciosas__c wei = new HC_obj_enfermedadesInfecciosas__c();
                        wei.HC_fld_casosActivos__c = dt.active;
                        wei.HC_fld_confirmados__c = dt.confirmed; 
                        wei.HC_fld_fallecidos__c = dt.deaths;
                        wei.HC_fld_fecha__c =Date.valueOf(dt.last_update);
                        wei.HC_fld_recuperados__c = dt.recovered;
                        wei.HC_fld_regionIso__c = dt.region.iso;
                        wei.HC_fld_regionName__c = dt.region.name;
                        wei.HC_fld_provincia__c = dt.region.province;
                        wei.RecordTypeId = Schema.SObjectType.HC_obj_enfermedadesInfecciosas__c.getRecordTypeInfosByDeveloperName().get('COVID_19').getRecordTypeId();
                        mapWpEnfInfecciosas.put(key,wei);
                    }
                    
                    if(!dt.region.cities.isEmpty()){
                        for(HC_cls_JSON2Apex.Cities ct : dt.region.cities){
                            String keyCity = dt.region.province+'_'+ct.name;
                            if(!mapCity.containsKey(keyCity)){
                                HC_obj_ciudades__c newCity = new HC_obj_ciudades__c();
                                newCity.HC_fld_confirmados__c = ct.confirmed;
                                newCity.HC_fld_muertes__c = ct.deaths;
                                newCity.HC_fld_nombre__c = ct.name;
                                newCity.Name = dt.region.province;
                                
                                mapCity.put(keycity, newCity);
                            }
                        }
                    }
                }
            }
        }
        if(mapWpEnfInfecciosas.size()>0){
            for( HC_obj_enfermedadesInfecciosas__c ei : mapWpEnfInfecciosas.values()){
                lstEnfermedadesLst.add(ei);
            }
        }
        if(mapCity.size()>0){
            for( HC_obj_ciudades__c city : mapCity.values()){
                lstCiudades.add(city);
            }
        }
        Database.SaveResult[] srList = Database.insert(lstEnfermedadesLst, false);
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                for(HC_obj_enfermedadesInfecciosas__c ei : lstEnfermedadesLst){
                    if(ei.id == sr.getId()){
                        if(!lstCiudades.isEmpty()){
                            for(HC_obj_ciudades__c c : lstCiudades){
                                if(c.Name == ei.HC_fld_provincia__c){
                                    c.HC_fld_enfermedadInfecciosa__c = ei.id;
                                }
                            }
                        }
                    }
                }
            }
        }
        insert lstCiudades;
    }
}