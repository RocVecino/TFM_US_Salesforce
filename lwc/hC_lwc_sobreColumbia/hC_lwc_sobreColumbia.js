import { LightningElement } from 'lwc';
import HC_sr_headerColumbia from '@salesforce/resourceUrl/HC_sr_headerColumbia';
import HC_sr_expertosCuidarte from '@salesforce/resourceUrl/HC_sr_expertosCuidarte';
import HC_sr_granEquipoContigo from '@salesforce/resourceUrl/HC_sr_granEquipoContigo';
import HC_sr_cuidamosPersonas from '@salesforce/resourceUrl/HC_sr_cuidamosPersonas';
export default class HC_lwc_sobreColumbia extends LightningElement {
    HC_sr_headerColumbia = HC_sr_headerColumbia;
    HC_sr_expertosCuidarte = HC_sr_expertosCuidarte;
    HC_sr_granEquipoContigo = HC_sr_granEquipoContigo;
    HC_sr_cuidamosPersonas = HC_sr_cuidamosPersonas;
}