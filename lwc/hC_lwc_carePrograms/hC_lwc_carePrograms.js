import { LightningElement } from 'lwc';
import HC_sr_imagenSeguroDental from '@salesforce/resourceUrl/HC_sr_imagenSeguroDental';
import HC_sr_imagenSeguroFamiliar from '@salesforce/resourceUrl/HC_sr_imagenSeguroFamiliar';
import HC_sr_imagenSeguroIndividual from '@salesforce/resourceUrl/HC_sr_imagenSeguroIndividual';
import getCarePrograms from '@salesforce/apex/HC_cls_consultaCarePrograms_cc.getCarePrograms';
import createLead from '@salesforce/apex/HC_cls_consultaCarePrograms_cc.createLead';
export default class HC_lwc_carePrograms extends LightningElement {

    resultWrapperLst; 
    isModalOpen = false;

    userName = '';
    userEmail = '';
    userPhone = '';
    wantsInfo = false;
    apellidos = '';

    careProgramTabSelected = '';

    connectedCallback() {

        getCarePrograms().then(resultWrapper => {
        
            if(resultWrapper.wrapperClass!=null){
                for(let i in resultWrapper.wrapperClass){
                    if(resultWrapper.wrapperClass[i].imagen == 'HC_sr_imagenSeguroDental'){
                        resultWrapper.wrapperClass[i].imagen = HC_sr_imagenSeguroDental;
                    }else if(resultWrapper.wrapperClass[i].imagen == 'HC_sr_imagenSeguroFamiliar'){
                        resultWrapper.wrapperClass[i].imagen = HC_sr_imagenSeguroFamiliar;
                    }else{
                        resultWrapper.wrapperClass[i].imagen = HC_sr_imagenSeguroIndividual;
                    }
                    if(resultWrapper.wrapperClass[i].checkEdadLimite == true || 
                    resultWrapper.wrapperClass[i].checkEdadMaxPermanencia == true || 
                    resultWrapper.wrapperClass[i].descFormPagoTrim != null || 
                    resultWrapper.wrapperClass[i].descFormPagoAnual != null || 
                    resultWrapper.wrapperClass[i].checkPeriodoCarencia == true ){
                        resultWrapper.wrapperClass[i].mostrarSeccion = true;
                    }else{
                        resultWrapper.wrapperClass[i].mostrarSeccion = false;
                    }
                }
                
            }
            this.resultWrapperLst = resultWrapper.wrapperClass;

            console.log('resultWrapper :: '+this.resultWrapperLst);
            }).catch(error => {
                console.log(error)
            });
    } 

    handleActive(event){
        this.careProgramTabSelected = event.target.label;
    }

    handleLlamar(){
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'name') {
            this.userName = event.target.value;
        } else if (field === 'email') {
            this.userEmail = event.target.value;
        } else if (field === 'phone') {
            this.userPhone = event.target.value;
        } else if (field === 'wantsInfo') {
            this.wantsInfo = event.target.checked;
        }else if (field === 'apellidos'){
            this.apellidos = event.target.value;
        }
    }

    handleSave() {
        createLead({ 
            name: this.userName, 
            apellidos: this.apellidos,
            email: this.userEmail, 
            phone: this.userPhone, 
            wantsInfo: this.wantsInfo,
            careProgramName: this.careProgramTabSelected
        })
        .then(result => {
            console.log('Lead creado con ID: ' + result);
            this.closeModal();
        })
        .catch(error => {
            console.error('Error al crear Lead: ' + error);
        });
    }
}