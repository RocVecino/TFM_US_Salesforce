/*
@name: HC_cls_LeadGenerateContract_cc
@version: 1.0
@creation date: 20/08/2024
@author: Rocío Vecino Torres
*/
public without sharing class HC_cls_LeadGenerateContract_cc {
    public Lead lead { get; private set; }
    public CareProgramEnrollee  careProgramEnrollee  { get; private set; }
    public String coverturas { get; private set; }
    public Decimal descFormaPago { get; private set; }    
    public String pdfUrl { get; private set; }    
    
    // Constructor del controlador de extensión
    public HC_cls_LeadGenerateContract_cc(ApexPages.StandardController stdController) {
        // Obtén el Lead desde el controlador estándar
        this.lead = (Lead)stdController.getRecord();
        
        // Obtener el ID del Lead desde el controlador estándar
        Id leadId = stdController.getId();
        
        // Realizar la consulta a la base de datos para obtener el Lead
        lead = [SELECT Id, Name, Street, City, PostalCode, Email, HC_fld_documentoIdentidad__c, Phone, HC_fld_frecuenciaPago__c, HC_fld_tipoPago__c, HC_fld_cuentaBancaria__c,HC_fld_identificacionBanco__c
                      FROM Lead 
                      WHERE Id = :leadId 
                      LIMIT 1];
        

        careProgramEnrollee = [select CareProgramId, CareProgram.name, CareProgram.BudgetAmount, CareProgram.Description, CareProgram.HC_fld_descFormPagoAnual__c, CareProgram.HC_fld_descFormPagoTrimestral__c, 
                               CareProgram.HC_fld_periodoCarenciaDiagAltaTec__c, CareProgram.HC_fld_periodoCarenciaPodologia__c, CareProgram.HC_fld_periodoCarenciaPrepAsistParto__c, 
                               CareProgram.HC_fld_periodoCarenciaTratEsp__c, CareProgram.HC_fld_periodoCarenciaTratInfertilidad__c, CareProgram.HC_fld_checkPeriodoCarencia__c 
                               FROM CareProgramEnrollee where  LeadId = :leadId LIMIT 1];
        
        if(lead.HC_fld_frecuenciaPago__c == 'Trimestral'){
            descFormaPago = careProgramEnrollee.CareProgram.HC_fld_descFormPagoTrimestral__c;
        }else if(lead.HC_fld_frecuenciaPago__c == 'Anual'){
            descFormaPago = careProgramEnrollee.CareProgram.HC_fld_descFormPagoAnual__c;
        }else{
            descFormaPago = 0;
        }
        
        for(CoverageBenefit cov : [select name from CoverageBenefit where HC_fld_careProgram__c = :careProgramEnrollee.CareProgramId]){
            if(String.isBlank(coverturas)){
                coverturas = cov.name;
            }else{
                coverturas = coverturas+'; '+cov.name;
            }
        }
    }
    // Método para generar el PDF
    public PageReference generateAndSavePdf() {
        // Generar el PDF
        PageReference pdfPage = Page.HC_vf_generarContrato;
        pdfPage.getParameters().put('id', lead.Id);
        Blob pdfBlob;
        try {
            pdfBlob = pdfPage.getContent();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error al generar el PDF: ' + e.getMessage()));
            return null;
        }

        // Guardar el PDF como un Attachment
        Attachment attachment = new Attachment();
        attachment.ParentId = lead.Id;
        attachment.Name = 'Contrato_Salud_' + lead.Name + '.pdf';
        attachment.Body = pdfBlob;
        attachment.ContentType = 'application/pdf';
        insert attachment;

        // Actualizar el URL del PDF
        pdfUrl = '/' + attachment.Id;
        
        return null;
    }
}