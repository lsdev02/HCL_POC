public with sharing class CustomOrderCreationController {
    
    @AuraEnabled(cacheable=true)
    public static InitialInformation getInitialInformation(string accountId){
        InitialInformation initInfo = new InitialInformation();
        List<Product2> productList = [
            SELECT Id, Name, ProductCode
            FROM Product2
            WHERE IsActive = TRUE
            AND Description like '%Antech%'
        ];

        List<PricebookEntry> priceList = [
            SELECT Id, Product2Id, Product2.Name, ProductCode, UnitPrice, Pricebook2.Id
            FROM PricebookEntry
            WHERE IsActive = TRUE
            AND Pricebook2.Name = 'Standard Price Book'
            AND Product2.Description like '%Antech%'
        ];

        List<Account> accoutList = [
            SELECT RecordType.DeveloperName
            FROM Account
            WHERE Id = :accountId
        ];

        string accountType = '';
        if (accoutList.size() > 0) {
            if( accoutList[0].RecordType.DeveloperName == 'Hospital') accountType = 'Hospital';
            else if( accoutList[0].RecordType.DeveloperName == 'Vet') accountType = 'Vet';
            else if( accoutList[0].RecordType.DeveloperName == 'Pet_Owner') accountType = 'Pet';
        }

        initInfo.productList = productList;
        initInfo.priceList = priceList;
        initInfo.accountType = accountType;

        return initInfo;
    }

    @AuraEnabled(cacheable=true)
    public static List<string> getPrediction(string concern, string petId, string weight){
        List<string> predictions = new List<string>();
        //system.debug('getPrediction: ' + concern + ', ' + petId + ', ' +weight);
        string text = 'Pet with ';
        if(petId != null && string.isNotBlank(concern) && concern.length() > 4){
            List<Account> petAccount = [
                SELECT Species__r.Name, Breed__r.Name 
                FROM Account
                WHERE Id = :petId LIMIT 1
            ] ;
            
            if (petAccount.size() > 0) {
                text += string.isNotBlank(petAccount[0].Species__r.Name) ? petAccount[0].Species__r.Name + ' species' : '';
                text += string.isNotBlank(petAccount[0].Breed__r.Name) ? ', ' + petAccount[0].Breed__r.Name + ' breed' : '';
            }

            text += string.isNotBlank(weight) && weight != '0' ? ', ' + weight + ' kg weight' : '';
            text += ' and these conserns:' + concern;

            List<EinsteinLanguageService.Prediction> predictionList = getEinsteinTestPrediction(text);
            for(EinsteinLanguageService.Prediction prediction : predictionList){
                if ( (prediction.probability * 100) > 20 ) {
                    if (prediction.label == 'Complete Blood Count') predictions.add('T1060'); //Blood Test	
                    else if (prediction.label == 'CHEMISTRIES') predictions.add('T1065'); //Serology
                    else if (prediction.label == 'Renal Tech Index') predictions.add('T1061'); //Urine Test
                    else if (prediction.label == 'Adult Wellness Chemistry') predictions.add('T1062'); //Fluid Analysis	
                    else if (prediction.label == 'CellaVision Inhouse Use Only') predictions.add('T1066'); //Toxicology
                }
            }
        }

        return predictions;
    }

    public static List<EinsteinLanguageService.Prediction> getEinsteinTestPrediction(string test) {
        EinsteinUtilityToken einsteinUtilityToken = new EinsteinUtilityToken();
        String accessToken = einsteinUtilityToken.getAccessToken();

        EinsteinLanguageService einsteinLanguageService = new EinsteinLanguageService(EinsteinLanguageService.LanguageServiceType.Intent);
        List<EinsteinLanguageService.Prediction> predictionList = einsteinLanguageService.predictTheTextType(test, accessToken);
        return predictionList;
    }

    public class InitialInformation {
        @AuraEnabled public List<Product2> productList {get; set;}
        @AuraEnabled public List<PricebookEntry> priceList {get; set;}
        @AuraEnabled public string accountType {get; set;}
    }


}
