public class AccountUpdater {

  @Future(callout=true)
  public static void updateAccount(String id){
    
      	Account result  = [Select Id ,Name,BillingCity,BillingPostalCode,BillingState,Phone from Account where id=:id ] ;
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        //gen.writeStringField('Id', result.Id);
        
        /*gen.writeStringField('Origem_Contrato__c',result.Origem_Contrato__c);
        gen.writeStringField('Cotacao__r.Contact.FirstName',result.Cotacao__r.Contact.FirstName);
        gen.writeStringField('Cotacao__r.Contact.LastName',result.Cotacao__r.Contact.LastName);    */    
        gen.writeStringField('name',result.Name);
      	gen.writeStringField('city',result.BillingCity);
      	gen.writeStringField('zip',result.BillingPostalCode);
        gen.writeStringField('state',result.BillingState);
        gen.writeStringField('phone',result.Phone);
        gen.writeEndObject();    
        String jsonS = gen.getAsString();
        System.debug('jsonMaterials'+jsonS);
        
        // Sening the http body with JSON 
        // 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://104.40.249.121:8000/api/create');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        //request.setBody('{"name":"mighty moose"}');
        //
        request.setBody(jsonS); 
       HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    	
    //check the response
    if (response.getStatusCode() == 200) {

      //update account
    
    } else {
      System.debug('Callout failed: ' + response);
    } 
  }

}