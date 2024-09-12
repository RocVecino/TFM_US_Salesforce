import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkDNI from '@salesforce/apex/HC_cls_accionesClientePotencial_cc.checkDNI';
import uploadFiles from '@salesforce/apex/HC_cls_accionesClientePotencial_cc.uploadFiles';
export default class HC_lwc_accionesClientePotencial extends LightningElement {

    showSelecDocumentosNecesarios = false;
    optionsDocumentosNecesarios = [];
    mensaje;

    handleConsultarDNI(){
        let dni = this.template.querySelector('[data-id="docIndentificador"]').value;
        this.checkDNI(dni);
    }

    checkDNI(dni){
        console.log(dni);
        checkDNI({ dni : dni})
        .then(resValidateDni => {
        
            console.log('RESPUESTA CHECK DNI :: '+resValidateDni)
            if(resValidateDni.name!='No se ha encontrado nada con su Identificación' 
                && resValidateDni.name !='Ha habido un error durante su identifiación'){
                if(resValidateDni.estado === 'Pendiente Documentación'){
                    this.showSelecDocumentosNecesarios = true;
                    this.mensaje = 'Hola!, '+resValidateDni.name+' su solicitud se encuentra pendiente de documentación, adjunte los siguientes archivos: ';
                    console.log(resValidateDni.documentosNecesarios)
                    if(resValidateDni.documentosNecesarios.includes(';')){
                        let array = resValidateDni.documentosNecesarios.split(';');
                        console.log(array[0])
                        for(let doc in array){
                            this.optionsDocumentosNecesarios.push({label: array[doc], showFileName : false, fileName: '', fileBase64: '' });
                        }
                    }else{
                        this.optionsDocumentosNecesarios.push({label: resValidateDni.documentosNecesarios, showFileName : false, fileName: '', fileBase64: '' });
                    }
                }
            }else{
                this.toastEvent("error",resValidateDni.name);
            }
        })
        .catch(error => {
            this.toastEvent("error",error.message);
            
        });
    }

    changeDocumento(event){
        console.log('1')
        let nameDoc = event.target.name;
        const file = event.target.files[0];
        //leer el archivo y convertirlo en base64
        const reader = new FileReader();
        console.log('2')
        reader.onload = () => {
            console.log('3')
            const base64 = reader.result.split(',')[1];
            console.log('4')
            this.optionsDocumentosNecesarios = this.optionsDocumentosNecesarios.map(input =>{
                console.log('5')
                if(input.label === nameDoc){
                    console.log('6')
                    return {...input, showFileName : true, fileName: file.name, fileBase64 : base64};
                }
                return input;
            });
        };
        reader.readAsDataURL(file);
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

    handleGuardarFiles(){
        let dni = this.template.querySelector('[data-id="docIndentificador"]').value;
        console.log('ARCHIVOS A CARGAR:: '+this.optionsDocumentosNecesarios)
        uploadFiles({ dni : dni, lstFiles: this.optionsDocumentosNecesarios})
        .then(uploadFiles => {
        
            console.log('RESPUESTA CHECK DNI :: '+uploadFiles)
            if(uploadFiles==='OK'){
                this.toastEvent("success",'Se ha cargado bien los archivos');
            }else{
                this.toastEvent("error",uploadFiles);
            }
        })
        .catch(error => {
            this.toastEvent("error",error.message);
            
        });
    }

}