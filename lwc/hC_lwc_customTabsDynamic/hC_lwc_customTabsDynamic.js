import { LightningElement } from 'lwc';
import checkUserProfile from '@salesforce/apex/HC_cls_customTabsDynamic_cc.checkUserProfile';
export default class HC_lwc_customTabsDynamic extends LightningElement {

    showTabProgramaSalud = false;
    showSobreColumbia = false;
    showTabPortalGestor = false;
    showTabPortalTareasPendientes = false;

    connectedCallback() {
        checkUserProfile().then(profile => {
            console.log('Perfil:: '+profile);
            this.showTabProgramaSalud = true;
            this.showSobreColumbia = true;
            if(profile === 'Corredor de Seguros'){
                this.showTabPortalGestor = true;
            }
            if(profile === 'Guest License User' || (profile === null && profile === undefined && profile === '')){
                this.showTabPortalTareasPendientes = true;
            }
        }).catch(error => {
            console.log(error);
        });
    }
}