import { LightningElement } from 'lwc';
import getLeads from '@salesforce/apex/HC_cls_tablaLeads_cc.getLeads';
export default class HC_lwc_tablaLeads extends LightningElement {

    valueEstadoDefault = 'Todays Leads';

    data = [];
    dataBuscador = [];

    columns = [
        {
            label: 'Name',
            fieldName: 'idLead',
            type: 'url',
            typeAttributes: { 
                label: { fieldName: 'name' }, 
                target: '_self'
            }
        },
        { label: 'Estado', fieldName: 'estado', type: 'text' },
        { label: 'Email', fieldName: 'email', type: 'email' },
        { label: 'Teléfono', fieldName: 'phone', type: 'phone' },
        { label: 'D.N.I', fieldName: 'dni', type: 'text' },
        { label: 'Pref. Comunicación', fieldName: 'preferenciaCom', type: 'text' }
    ];

    get optionsEstado() {
        return [
            { label: 'Solicitud de Llamada', value: 'Solicitud de Llamada' },
            { label: 'En proceso de Contratación', value: 'En proceso de Contratación' },
            { label: 'Pendiente Documentación', value: 'Pendiente Documentación' },
            { label: 'Rechazada', value: 'Rechazada' },
            { label: 'Esperando Firma', value: 'Esperando Firma' },
            { label: 'Contrato Generado', value: 'Contrato Generado' },
            { label: 'Pendiente Generar Contrato', value: 'Pendiente Generar Contrato' },
            { label: 'Todays Leads', value: 'Todays Leads' }
        ];
    }
    connectedCallback() {
        getLeads({estado : this.valueEstadoDefault}).then(lstResultWrapper => {
            this.data = lstResultWrapper;
            this.dataBuscador = this.data;
            console.log('Result:: '+this.data);
        }).catch(error => {
            console.log(error);
        });
    }

    handleChange(event){
        getLeads({estado : event.target.value}).then(lstResultWrapper => {
            this.data = lstResultWrapper;
            this.dataBuscador = this.data;
            console.log('Result:: '+this.data);
        }).catch(error => {
            console.log(error);
        });
    }

    changeFiterBuscador(){
    
        let buscador = this.template.querySelector('lightning-input[data-name="inputBuscador"]').value;
        console.log(buscador)
        
        if(buscador!=""){
            if(this.data){
                let recs = [];
                for(let rec of this.data){
                    console.log('esto que es1'+rec);
                    // Filtra las claves de rec para excluir el campo no deseado
                    let filteredKeys = Object.keys(rec).filter(key => key !== 'idLead');
                    let valuesArray = filteredKeys.map(key => rec[key]);
                    console.log('esto que es2'+valuesArray)
                    for (let val of valuesArray){
                        console.log('esto que es3'+val)
                        let strVal = String(val);
                        console.log('esto que es4'+strVal)
                        if(strVal){
                            if(strVal.toLowerCase().includes(buscador.toLowerCase())){
                                console.log('esto que es5'+strVal)
                                recs.push(rec);
                                break;
                            }
                        }
                    }
                }
                console.log(recs);
                this.dataBuscador=recs;
            }
        }else{
            this.dataBuscador=this.data;
        }
    }

}