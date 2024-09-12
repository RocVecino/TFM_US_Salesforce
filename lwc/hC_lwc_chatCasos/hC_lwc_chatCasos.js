import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkCliente from '@salesforce/apex/HC_cls_chatCasos_cc.checkCliente';
export default class HC_lwc_chatCasos extends LightningElement {

    openChat = false;
    inputUserMessage = '';
    checkInput = false;
    lstMensajesUsuario = [];
    checkSelectReasonCase = false;
    checkDisabledReasonCase = false;
    mensajeClienteChatBot = '';
    textCaseRazon = '';
    showMostrarSegRazon = false;
    disabledSelectReason = false;
    mostrarMensajeViaje = false;
    mensajeViaje = '';


    mostrarMensajeCaso= false;
    mensajeCaso = '';

    get lstOptionsReasonCase() {
        return [
            { label: 'Solicitud de Información', value: 'Solicitud de Información' },
            { label: 'Quejas y Reclamaciones', value: 'Quejas y Reclamaciones' },
            { label: 'Problemas de Facturación', value: 'Problemas de Facturación' },
            { label: 'Modificación de Póliza', value: 'Modificación de Póliza' },
            { label: 'Asistencia Técnica', value: 'Asistencia Técnica' },
            { label: 'Consultas de Renovación', value: 'Consultas de Renovación' },
            { label: 'Asistencia en Viaje', value: 'Asistencia en Viaje' },
            { label: 'Consultas Generales', value: 'Consultas Generales' },
            { label: 'Otras Razones', value: 'Otras Razones' }
        ];
    }

    get lstOptiosSegReason(){
        if(this.textCaseRazon == 'Solicitud de Información'){
            return [
                { label: 'Información sobre pólizas', value: 'Información sobre pólizas' },
                { label: 'Información sobre cobertura', value: 'Información sobre cobertura' },
                { label: 'Información sobre primas', value: 'Información sobre primas' }
            ];
        }else if(this.textCaseRazon == 'Problemas de Facturación'){
            return [
                { label: 'Factura incorrecta', value: 'Factura incorrecta' },
                { label: 'Pago no procesado', value: 'Pago no procesado' },
                { label: 'Disputa de prima', value: 'Disputa de prima' }
            ];
        }else if(this.textCaseRazon == 'Modificación de Póliza'){
            return [
                { label: 'Cambio de beneficiario', value: 'Cambio de beneficiario' },
                { label: 'Cambio de dirección', value: 'Cambio de dirección' },
                { label: 'Ajuste de cobertura', value: 'Ajuste de cobertura' },
                { label: 'Cancelación de póliza', value: 'Cancelación de póliza' }
            ];
        }else if(this.textCaseRazon == 'Asistencia Técnica'){
            return [
                { label: 'Problemas con el portal del cliente', value: 'Problemas con el portal del cliente' },
                { label: 'Ayuda con la documentación en línea', value: 'Ayuda con la documentación en línea' }
            ];
        }else if(this.textCaseRazon == 'Consultas de Renovación'){
            return [
                { label: 'Detalles de la renovación', value: 'Detalles de la renovación' },
                { label: 'Cambio de términos de la póliza', value: 'Cambio de términos de la póliza' },
                { label: 'Descuentos por renovación', value: 'Descuentos por renovación' }
            ];
        }else if(this.textCaseRazon == 'Consultas Generales'){
            return [
                { label: 'Preguntas generales sobre seguros', value: 'Preguntas generales sobre seguros' },
                { label: 'Sugerencias y feedback', value: 'Sugerencias y feedback' }
            ];
        }
    }

    handleChatClick(){
        this.openChat = true;
    }
    closeChatModal() {
        this.openChat = false;
    }

    sendMessage(){
        let userMessage = this.template.querySelector('[data-id="inputMensaje"]').value;
        this.lstMensajesUsuario.push(userMessage);
        if(userMessage==null || userMessage == ''){
            const evt = new ShowToastEvent({
                title: "Warning",
                message: "No ha introducido el número de teléfono.",
                variant: "warning",
            });
            this.dispatchEvent(evt);
        }else{
            if(userMessage.length!=9){
                const evt = new ShowToastEvent({
                    title: "Warning",
                    message: "El número de teléfono no contiene 9 dígitos.",
                    variant: "warning",
                });
                this.dispatchEvent(evt);
            }else{
                checkCliente({ 
                    phone: userMessage
                })
                .then(result => {
                    console.log('Resultado: ' + result);
                    
                    if(result.name!=null && result.name != '' && result.name != undefined){
                        this.mensajeClienteChatBot = 'Sí, '+result.name+'! Te tenemos actualmente en el sistema como '+result.objName;
                    }else{
                        this.mensajeClienteChatBot = 'No te tenemos actualmente en el sistema.';
                    }
                })
                .catch(error => {
                    console.error('Error al crear Lead: ' + error);
                });
                this.inputUserMessage = userMessage;
                this.checkInput = true;
                this.checkSelectReasonCase = true;
            }
        }
    }
    handleChange(event){
        this.textCaseRazon = event.target.value;
        this.disabledSelectReason = true;

        if(this.textCaseRazon == 'Solicitud de Información'){
            this.showMostrarSegRazon = true;
        }else if(this.textCaseRazon == 'Problemas de Facturación'){
            this.showMostrarSegRazon = true;
        }else if(this.textCaseRazon == 'Modificación de Póliza'){
            this.showMostrarSegRazon = true;
        }else if(this.textCaseRazon == 'Asistencia Técnica'){
            this.showMostrarSegRazon = true;
        }else if(this.textCaseRazon == 'Consultas de Renovación'){
            this.showMostrarSegRazon = true;
        }else if(this.textCaseRazon == 'Consultas Generales'){
            this.showMostrarSegRazon = true;
        }else{
            this.mostrarMensajeViaje = true;
            this.mensajeViaje = 'Para asistencia en Viaje contacte con: 91 722 1777 o 91 564 1212';
        }
        
    }
    disabledSelectSegReason = false;
    handleChangeSegReason(){
        this.mostrarMensajeCaso= true;
        this.mensajeCaso = 'Se ha abierto un caso a su corredor de Seguros, Pedro Espada, se pondra en contacto con usted. Si desea una asistencia más rápida llame a este número: 900 159 000';
        this.disabledSelectSegReason = true;
    }
}