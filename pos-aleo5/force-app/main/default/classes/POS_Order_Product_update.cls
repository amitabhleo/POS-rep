public class POS_Order_Product_update {
    
    //calling the method
    
    public static void updatePOSprod(List<POS_Order_Products__c> poplist){
        //We have got the POS order list now we have to query the
        //corresponding POS Order and update the POS Order Product with POS location
        Set<ID> pos_ord_ids = new Set<Id>();
        //Step 1: fetch the POS order IDs 
        for(POS_Order_Products__c pop:poplist){
            pos_ord_ids.add(pop.POS_Orders__c);
            
        }
        //Step 2: Query the POS order using a Map and update POS location in Pos order product
        List<POS_Order_Products__c> poprods = new List<POS_Order_Products__c>();
        System.debug('checking apex'+poprods.size());
        for(POS_Order_Products__c pop:[SELECT Id, Name, POS_Orders__c, POS_Products__c, POS_Location__c,
                                       POS_Orders__r.pos__c FROM POS_Order_Products__c 
                                       where POS_Orders__c IN : pos_ord_ids]){
                                           //Create a new POP instancce
                                           POS_Order_Products__c posprod = new POS_Order_Products__c();
                                           //passing values
                                           posprod.Id = pop.Id;
                                           posprod.POS_Location__c = pop.POS_Orders__r.pos__c;
                                           posprod.updated__c = true;
                                           poprods.add(posprod);    
                                           System.debug('POS location'+posprod.POS_Location__c);
                                       }
        upsert poprods;
    }
    
    
}