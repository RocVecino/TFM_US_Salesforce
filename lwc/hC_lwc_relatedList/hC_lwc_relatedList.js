import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCasos from '@salesforce/apex/HC_cls_relatedListLead_cc.getCasos';
import newCaso from '@salesforce/apex/HC_cls_relatedListLead_cc.newCaso';
import getCondiciones from '@salesforce/apex/HC_cls_relatedListLead_cc.getCondiciones';
import newHCondition from '@salesforce/apex/HC_cls_relatedListLead_cc.newHCondition';
import Origin from '@salesforce/schema/Case.Origin';
import Reason from '@salesforce/schema/Case.Reason';
import Description from '@salesforce/schema/Case.Description';
import Subject from '@salesforce/schema/Case.Subject';
import Type from '@salesforce/schema/Case.Type';
import Priority  from '@salesforce/schema/Case.Priority';

export default class HC_lwc_relatedList extends LightningElement {

    Origin = Origin;
    Reason = Reason;
    Description = Description;
    Subject = Subject;
    Type = Type;
    Priority = Priority;

    @api recordId;
    
    columns = [
        {
            label: 'Nº Caso',
            fieldName: 'idCase',
            type: 'url',
            typeAttributes: { 
                label: { fieldName: 'caseNumber' }, 
                target: '_self'
            }
        },
        { label: 'Estado', fieldName: 'estado',iconName: 'utility:asset_audit', hideDefaultActions: true},
        { label: 'Asunto', fieldName: 'subjectCase',iconName: 'utility:event', wrapText: true, hideDefaultActions: true},
        { label: 'Fecha Apertura', fieldName: 'dateOpened',iconName: 'utility:asset_audit', hideDefaultActions: true},
        { label: 'Prioridad', fieldName: 'priority',iconName: 'utility:company', hideDefaultActions: true}
    ];

    listaCasos = [];
    showSectionNewCasos = false;
    numCasos;

    columnsHCondition = [
        { label: 'Nombre', fieldName: 'name',iconName: 'utility:asset_audit', hideDefaultActions: true},
        { label: 'Descripción', fieldName: 'descripcion',iconName: 'utility:event', wrapText: true, hideDefaultActions: true},
        { label: 'Severidad', fieldName: 'severidad',iconName: 'utility:asset_audit', hideDefaultActions: true},
        { label: 'Estado', fieldName: 'estado',iconName: 'utility:company', hideDefaultActions: true}
    ];

    listaHCondition = [];
    showSectionNewHCondition = false;
    numHCondition;

    get optionsConditionStatus(){
        return [
            { label: '--', value: '' },
            { label: 'Active', value: 'Active' },
            { label: 'Inactive', value: 'Inactive' },
            { label: 'Resolved', value: 'Resolved' },
        ];
    }

    get optionsSeveridad(){
        return [
            { label: '--', value: '' },
            { label: 'Severe', value: 'Severe' },
            { label: 'Moderate', value: 'Moderate' },
            { label: 'Mild', value: 'Mild' },
        ];
    }

    connectedCallback(){
        this.getCasos();
        this.getCondiciones();
    }
    closeModal(){
		this.showSectionNewCasos = false;
        this.showSectionNewHCondition = false;
	}
    handleNewRecordClickCase(){
        this.showSectionNewCasos = true;
    }

    handleNewRecordClickHCondition(){
        this.showSectionNewHCondition = true;
    }

    getCasos(){
        getCasos({recordId : this.recordId})
            .then(lstResultWrapper => {
            
            console.log('RESPUESTA CASOS :: '+lstResultWrapper)
            this.numHorarios = lstResultWrapper.length;
            if(lstResultWrapper!=null){
                this.listaCasos = lstResultWrapper;
                this.numCasos = this.listaCasos.length;
            }
        })
        .catch(error => {
            console.log(error)
        });
    }

    getCondiciones(){
        getCondiciones({recordId : this.recordId})
            .then(lstResultWrapper => {
            
            console.log('RESPUESTA CASOS :: '+lstResultWrapper)
            this.numHorarios = lstResultWrapper.length;
            if(lstResultWrapper!=null){
                this.listaHCondition = lstResultWrapper;
                this.numHCondition = this.listaHCondition.length;
            }
        })
        .catch(error => {
            console.log(error)
        });
    }

    crearCaso(){
        console.log('crearCaso')
        let Origin = this.template.querySelector('[data-id="Origin"]').value;
        let Reason = this.template.querySelector('[data-id="Reason"]').value;
        let Description = this.template.querySelector('[data-id="Description"]').value;
        let Subject = this.template.querySelector('[data-id="Subject"]').value;
        let Priority = this.template.querySelector('[data-id="Priority"]').value;
        console.log('crearCasoAntesNewCaso')
        this.newCaso(Origin, Reason, Description, Subject, Priority);
    }

    crearHCondition(){
        let Severity = this.template.querySelector('[data-id="Severity"]').value;
        let ProblemDescription = this.template.querySelector('[data-id="ProblemDescription"]').value;
        let ProblemName = this.template.querySelector('[data-id="ProblemName"]').value;
        let ConditionStatus = this.template.querySelector('[data-id="ConditionStatus"]').value;
        this.newHCondition(Severity, ProblemDescription, ProblemName, ConditionStatus);
    }

    newCaso(Origin, Reason, Description, Subject, Priority){
        newCaso({ recordId : this.recordId, origin : Origin, reason : Reason, description : Description, 
                subject : Subject, priority : Priority})
        .then(idCase => {
        
            console.log('RESPUESTA CREAR CASO :: '+idCase)
            if(idCase!=null && idCase != undefined && idCase != ''){
                this.showSectionNewCasos = false;
                this.getCasos();
            }else{
                this.toastEvent("error","Ha ocurrido un error al añadir el nuevo caso");
            }
        })
        .catch(error => {
            this.toastEvent("error","Ha ocurrido un error al añadir el nuevo caso");
            
        });
    }

    newHCondition(Severity, ProblemDescription, ProblemName, ConditionStatus){
        newHCondition({ recordId : this.recordId, severity : Severity, problemDescription : ProblemDescription, 
                        problemName : ProblemName, conditionStatus : ConditionStatus})
        .then(idCase => {
        
            console.log('RESPUESTA CREAR CASO :: '+idCase)
            if(idCase!=null && idCase != undefined && idCase != ''){
                this.showSectionNewHCondition = false;
                this.getCondiciones();
            }else{
                this.toastEvent("error","Ha ocurrido un error al añadir la nueva condición");
            }
        })
        .catch(error => {
            this.toastEvent("error","Ha ocurrido un error al añadir la nueva condición");
            
        });
    }

    toastEvent(variant, message){
        const evt = new ShowToastEvent({
        title: "",
        message: message,
        variant: variant,
        mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}