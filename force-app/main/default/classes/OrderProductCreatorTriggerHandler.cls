public with sharing class OrderProductCreatorTriggerHandler {
    
    public static void createOrderProduct(Map<Id, Order> orderMap) {
        List<Order> orderList = [
            SELECT Id, hospitalid__c, AccountId, Discount__c, Recommends__c 
            FROM Order
            WHERE Id in :orderMap.keySet()
        ];

        try{         
            List<OrderItem> orderTestList = new List<OrderItem>();
            for(Order orderHere : orderList) {
                List<TestInfo> testList = (List<TestInfo>)JSON.deserialize(orderHere.Recommends__c, List<TestInfo>.class);

                for(TestInfo test : testList) {
                    OrderItem orderTest = new OrderItem();
                    orderTest.Product2Id = test.ProductId;
                    orderTest.PricebookEntryId = test.PricebookEntryId;
                    // if(orderHere.Discount__c != null && orderHere.Discount__c <= 100) {
                    //     orderTest.UnitPrice = test.UnitPrice - (test.UnitPrice * (test.UnitPrice / 100));
                    //     system.debug(orderTestList);
                    // }
                    // else orderTest.UnitPrice = test.UnitPrice;
                    orderTest.UnitPrice = test.UnitPrice;
                    orderTest.Quantity = 1;
                    orderTest.OrderId = orderHere.Id;
                    orderTest.Account__c = orderHere.AccountId;
                    orderTestList.add(orderTest);
                }

                if(orderTestList.size() > 0) insert orderTestList;
                sendOrder(orderHere.Id, orderHere.hospitalid__c, orderHere.AccountId);
            }

            //system.debug(orderTestList);

        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }

   @Future(callout=true)
    public static void sendOrder(Id orderId, Id hospitalId, Id patientId){
        JSONOrderData jsonOrder = new JSONOrderData();
        jsonOrder.order_id = orderId;
        jsonOrder.hospital_id = hospitalId;
        jsonOrder.patient_id = patientId;
        List<JSONOrderItemData> jsonOrderItemList = new List<JSONOrderItemData>();

        List<OrderItem> orderItemList = [
            SELECT Id, Product2.ProductCode 
            FROM OrderItem
            WHERE OrderId = :orderId
        ];

        JSONOrderItemData jsonOrderItem;
        for(OrderItem orderItemHere : orderItemList) {
            jsonOrderItem = new JSONOrderItemData();
            jsonOrderItem.order_test_id = orderItemHere.Id;
            jsonOrderItem.test_external_id = orderItemHere.Product2.ProductCode;
            jsonOrderItemList.add(jsonOrderItem);
        }
            
        jsonOrder.order = jsonOrderItemList;
        String jsonString = JSON.serialize(jsonOrder);
        //System.debug(jsonString);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://104.40.249.121:8000/api/create-order');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        request.setBody(jsonString); 
        HttpResponse response = http.send(request);
       
        //check the response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
        } 
        else {
            System.debug('reponse: ' + response);
        } 
  }


    public class JSONOrderData {
        public string order_id;
        public string hospital_id;
        public string patient_id;
        List<JSONOrderItemData> order;
    }

    public class JSONOrderItemData {
        public string order_test_id;
        public String test_external_id;
    }


    public class TestInfo {
        public string ProductId;
        public string ProductCode;
        public double UnitPrice;
        public String PricebookEntryId;
    }
}
