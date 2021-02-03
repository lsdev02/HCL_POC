public with sharing class EinsteinLanguageService {
    private final String einsteinLanguageAPIEndpoint;
    private final String modelId;
    
    private EinsteinLanguageService(){
        
    }
    
    public EinsteinLanguageService(LanguageServiceType serviceType){
        if(serviceType == LanguageServiceType.Intent){
            //have to put this in custommeta data
            //and get here form metadata and then assign
            this.einsteinLanguageAPIEndpoint = 'https://api.einstein.ai/v2/language/intent';
            
            //have to put this in custommeta data with private-key encryption
            //and get here form metadata and then have to decrypt and then assign
            this.modelId = 'K3CSALDG4V2SY2ZCUYCDJSLXYY';
        }
        else if(serviceType == LanguageServiceType.Sentiment){
            //have to put this in custommeta data
            //and get here form metadata and then assign
            this.einsteinLanguageAPIEndpoint = 'https://api.einstein.ai/v2/language/sentiment';
            
            //have to put this in custommeta data with private-key encryption
            //and get here form metadata and then have to decrypt and then assign
            this.modelId = '';
        }   
    }
    
    public List<Prediction> predictTheTextType(String textToPredict, String accessToken){
        List<Prediction> predictions = null;
        
        if( String.isNotBlank(textToPredict) && String.isNotBlank(accessToken) 
           && String.isNotBlank(this.einsteinLanguageAPIEndpoint) && String.isNotBlank(this.modelId) ){
               
               predictions = apiCall(einsteinLanguageAPIEndpoint, textToPredict, accessToken, this.modelId); 
        }
        
        return predictions;
    }
    
    private List<Prediction> apiCall(String endPoint, String document, String accessToken, String modelId) {
        
        // String contentType = ATLVCSHttpFormBuilder.GetContentType();
        
        // //  Compose the form
        // String form64 = '';
        // form64 += ATLVCSHttpFormBuilder.WriteBoundary();
        // form64 += ATLVCSHttpFormBuilder.WriteBodyParameter('modelId', EncodingUtil.urlEncode(modelId, 'UTF-8'));
        // form64 += ATLVCSHttpFormBuilder.WriteBoundary();
        // form64 += ATLVCSHttpFormBuilder.WriteBodyParameter('document', document);
        // form64 += ATLVCSHttpFormBuilder.WriteBoundary(null);
        // Blob formBlob = EncodingUtil.base64Decode(form64);
        
        // String contentLength = string.valueOf(formBlob.size());
        
        // //  Compose the http request
        // HttpRequest httpRequest = new HttpRequest();
        
        // httpRequest.setBodyAsBlob(formBlob);
        // httpRequest.setHeader('Connection', 'keep-alive');
        // httpRequest.setHeader('Content-Length', contentLength);
        // httpRequest.setHeader('Content-Type', contentType);
        // httpRequest.setMethod('POST');
        // httpRequest.setTimeout(120000);
        // httpRequest.setHeader('Authorization','Bearer ' + accessToken);
        // httpRequest.setEndpoint(endPoint);
     
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('POST');
        httpRequest.setEndpoint(endPoint);
        httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
        httpRequest.setHeader('Content-type', 'application/json');        
        String body = '{\"modelId\":\"'+ modelId + '\",\"document\":\"' + document + '\"}';
        httpRequest.setBody(body);   
        
        Http http = new Http();
        List<Prediction> predictions = new List<Prediction>();
        try {
            HTTPResponse res = http.send(httpRequest);
            if (res.getStatusCode() == 200) {
                System.JSONParser parser = System.JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'probabilities')) {
                        parser.nextToken();
                        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                            while (parser.nextToken() != null) {
                                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                    Prediction probability = (Prediction)parser.readValueAs(Prediction.class);
                                    predictions.add(probability);
                                }
                            }
                        }
                        break;
                    }
                }
            }

        } catch(System.CalloutException e) {
            System.debug('ERROR:' + e);
        }
        return(predictions);
    }
    
    public class Prediction {
        public String label {get;set;}
        public Double probability {get;set;}
    }
    
    public enum LanguageServiceType {
        Intent,
        Sentiment
    }
}
