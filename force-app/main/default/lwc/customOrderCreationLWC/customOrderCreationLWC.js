import { LightningElement, api, track , wire} from 'lwc';
import getInitialInformation from '@salesforce/apex/CustomOrderCreationController.getInitialInformation';
import getPrediction from '@salesforce/apex/CustomOrderCreationController.getPrediction';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomOrderCreationLWC extends LightningElement {
    @api accountId;
    @track accountType;
    @track productList;
    @track priceList;
    @track pricebookId;
    @track orderStartDate;
    @track orderStatus;
    @track productPriceMap = {};
    @track productPricebookEntryMap = {};
    @track productIdMap = {};
    @track testValues = [];
    @track testList;
    @track petId;
    @track hospitalId;
    @track vetId;
    @track weight;
    @track concern;
    @track recommends;
    @track visitId;
    @track labAccessionId;
    @track orderCode;
    @track totalValue;
    @track discountValue;

    get selectedTestValues() {
        return this.testValues.join(',');
    }

    // get totalValue() {
    //     let selectedList = this.testValues
    //     let total = 0.00;
    //     this.priceList.forEach(function(record) {
    //         if (selectedList.includes(record["ProductCode"])) {
    //             total += record["UnitPrice"];
    //         }
    //     });
    //     return total;
    // }

    connectedCallback() {
        //this.petId = this.accountId;
        
        let timestamp = "";
        let now = new Date();
        timestamp = now.getUTCFullYear().toString();
        timestamp += now.getUTCMonth().toString();
        timestamp += now.getUTCDate().toString();
        timestamp += now.getUTCHours().toString();
        timestamp += now.getUTCMinutes().toString();
        timestamp += now.getUTCSeconds().toString();
        timestamp += now.getUTCMilliseconds().toString();

        this.visitId = "VI-" + timestamp;
        this.labAccessionId = "LA-" + timestamp;
        this.orderCode = "OC-" + timestamp;
        this.orderStatus = 'Draft';
        this.orderStartDate =  new Date().toISOString();
    }

    @wire(getInitialInformation, {
        accountId: '$accountId'
    })
    getInitialInformationResult({ error, data }) {
        if (data) {
            console.log(data);
            this.productList = data.productList;
            this.priceList = data.priceList;
            this.accountType = data.accountType;

            if(this.accountType == 'Hospital') this.hospitalId = this.accountId;
            else if(this.accountType == 'Vet') this.vetId = this.accountId;
            else if(this.accountType == 'Pet') this.petId = this.accountId;
            
            let pricebook;
            let list = []; 
            let priceMap = {};
            let priceBookEntryMap = {};
            let productMap = {};
            data.priceList.forEach(function(record) {
                //list.push({ label: product["Name"], value: product["ProductCode"] });
                list.push({ label: record["Product2"].Name + " ($" + record["UnitPrice"] + ")", value: record["ProductCode"] });
                pricebook = record["Pricebook2"].Id;
                priceMap[record["ProductCode"]] = record["UnitPrice"];
                priceBookEntryMap[record["ProductCode"]] = record["Id"];
                productMap[record["ProductCode"]] = record["Product2Id"];
                
            });
            this.testList = list;
            this.pricebookId = pricebook;
            this.productPriceMap = priceMap;
            this.productPricebookEntryMap = priceBookEntryMap;
            this.productIdMap = productMap;
        }
    }

    @wire(getPrediction, {
        petId: '$petId',
        weight: '$weight',
        concern: '$concern'
    })
    getPredictionResult({ error, data }) {
        if (data) {
            this.testValues = [];
            this.calcualtetotalValue();

            let list = []; 
            this.testValues.forEach(function(product) {
                list.push(product);
            });

            data.forEach(function(test) {
                if(!list.includes(test))list.push(test);
            });
           
            this.testValues = list;
            this.calcualtetotalValue();
        }
        else if(error){
            alert("error");
            console.log(error);
        }
    }

    calcualtetotalValue() {
        let priceMap = this.productPriceMap;
        let total = 0.00;
        this.testValues.forEach(function(record) {
            total += priceMap[record];
        });

        if( this.discountValue && this.discountValue > 0)  {
            total = total - (total * (this.discountValue/100));
        }
        this.totalValue = total;
    }

    handleTestChange(event) {
        this.testValues = event.detail.value;
        console.log(this.testValues.join(','));
        this.calcualtetotalValue();
    }

    handlePetChange(event) {
        if(event.detail.value != null) {
            this.petId = String(event.detail.value);
            //this.handlePrediction();
        }else{
            this.testValues = [];
        }
    }

    handleWeightChange(event) {
        if(event.detail.value != null) {
            this.weight = String(event.detail.value);
            //this.handlePrediction();
        }else{
            this.testValues = [];
        }
    }

    handleConcernChange(event) {
        if(event.detail.value != null && event.detail.value.length > 4) {
            this.concern = String(event.detail.value);
            //this.handlePrediction();
        }else{
            this.testValues = [];
        }
    }

    handleDiscountChange(event) {
        this.discountValue = event.detail.value > 100 ? 100 : event.detail.value;
        if(this.totalValue >= 0 || this.testValues.length > 0) {
            this.calcualtetotalValue();
        }
    }

    handleVisitDateChange(event) {
        this.orderStartDate = event.detail.value;
    }

    // handlePrediction() {
    //     alert("pred");
    //     getPrediction({
    //         concern: this.concern,
    //         petId: this.petId,
    //         weight: this.weight
    //     })
    //     .then(result => {
    //         console.log(result);
    //         let list = []; 
    //         this.testValues.forEach(function(product) {
    //             list.push(product);
    //         });

    //         this.result.forEach(function(test) {
    //             if(!list.includes(test))list.push(test);
    //         });
           
    //         this.testValues = list;
    //     })
    //     .catch(error => {
    //         console.log("error", JSON.stringify(this.error));
    //     });
    // }

    handleSubmit(event){
        event.preventDefault();  

        // const inputFields = this.template.querySelectorAll(
        //     'lightning-input-field'
        // );

        // if (inputFields) {
        //     inputFields.forEach(field => {
        //         if(field.fieldName == 'Name') {

        //         }
        //     });
        // }
        //alert(this.recommends );

        let pricebookEntryMap = this.productPricebookEntryMap;
        let priceMap = this.productPriceMap;
        let productMap = this.productIdMap;

        let selectedTests = '[';
        this.testValues.forEach(function(record) {
            selectedTests += '{"ProductId":' + '"' + productMap[record] + '",' 
                            +'"ProductCode":' + '"' + record + '",'
                            +'"UnitPrice":' + '"' + priceMap[record] + '",'
                            +'"PricebookEntryId":' + '"' + pricebookEntryMap[record] + '"},';
        });

        const fields = event.detail.fields;
        fields.Recommends__c = selectedTests.slice(0, -1) + ']';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
     }

     handleSuccess(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'New Order Created Successfully',
                variant: 'success',
            }),
        );

        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
     }

}