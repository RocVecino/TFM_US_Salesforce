trigger HC_trg_triggerLead on Lead (after update) {
    
    HC_cls_handlerTriggerLead.afterUpdateContratoFirmado(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

}