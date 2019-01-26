/*
* I have to create a Pos Inventory Transaction on every POS Order Product creation,
* reducing the POS Inventory by the units sold and add the inventory to the second location
* should also work on inventory transfer from one location to another to keep the Inventory
* Transaction log upto date.
*/
trigger POS_Inv_Transaction on POS_Order_Products__c (before insert, before update, after insert) {
    //Step1: Query the POS_order_products and fetch POS Inventory
    Set<ID> pos_Inv_Id = new Set<ID>();
    Set<ID> pos_ord_Ids = new Set<ID>();
    Integer units_sold;
    
    for(POS_Order_Products__c pop1 : trigger.new){  
        if(trigger.isbefore){
            if(pop1.Units__c > 0 ){//&& pop1.updated__c == False){
                //updating the POS Inv Id
                pos_Inv_Id.add(pop1.POS_Inventory__c);
                
                units_sold = Integer.valueOf(pop1.Units__c);
                
                System.debug('Units Sold'+units_sold);
            }
        }
        if(Trigger.isafter){
            pos_ord_Ids.add(pop1.POS_Orders__c); 
        }      
        //Step0: populating the POS order details
        List<POS_Order_Products__c> poprods = new List<POS_Order_Products__c>();
        POS_Order_Products__c posprod;
        System.debug('checking size before'+poprods.size());
        for(POS_Order_Products__c pop:[SELECT Id, Name, POS_Orders__c, POS_Products__c, POS_Location__c,
                                       POS_Orders__r.pos__c FROM POS_Order_Products__c 
                                       where POS_Orders__c IN : pos_ord_Ids]){
                                           //Create a new POP instance
                                           posprod = new POS_Order_Products__c();
                                           //passing values
                                           posprod.Id = pop.Id;
                                           posprod.POS_Location__c = pop.POS_Orders__r.pos__c;
                                           posprod.updated__c = true;
                                           System.debug('checking pop size '+poprods.size());
                                           System.debug('POS location : '+posprod.POS_Location__c); 
                                           System.debug('POS id : '+posprod.Id);
                                           //System.debug('POS prods : '+posprod.POS_Products__c);
                                           //System.debug('POS order : '+posprod.POS_Orders__c);
                                           System.debug('POS value : '+pop);
                                           
                                           //Step0.1: populating the POS INventory details
                                           for(POS_Inventory__c pinv :[SELECT Id, Name, POS_Location__c, POS_Product__c 
                                                                       FROM POS_Inventory__c where POS_Location__c = :pop.POS_Orders__r.pos__c
                                                                       and POS_Product__c =: pop1.POS_Products__c]) {
                                                                           posprod.POS_Inventory__c = pinv.Id;   
                                                                       } 
                                           poprods.add(posprod);
                                       }
        
        //upsert poprods;  
        
        
    }
    //Step2: query the POS Inventory Products 
    List<POS_Inventory__c> PinvList = new List<POS_Inventory__c>();
    List<POS_Inventory_Transaction__c> pinvTransacts = new List <POS_Inventory_Transaction__c>();
    for(POS_Inventory__c pinv : [SELECT Id, POS_Location__c, POS_Product__c, Qty_on_Hand__c, 
                                 Qty_Allocated__c FROM POS_Inventory__c where Id IN: pos_Inv_Id]){
                                     
                                     System.debug('pInv details'+pinv.Id); 
                                     //Updating the Inventory Product
                                     POS_Inventory__c pinvent = new POS_Inventory__c();
                                     pinvent.Id = pinv.Id;
                                     pinvent.Qty_on_Hand__c = pinv.Qty_on_Hand__c - units_sold;  
                                     PinvList.add(pinvent);
                                     
                                     //Step3: Create a new POS Inventory Transaction record 
                                     POS_Inventory_Transaction__c pit = new POS_Inventory_Transaction__c();
                                     pit.message__c = 'updated from POS Order Product';
                                     pit.Inv_Qty__c = pinv.Qty_on_Hand__c - units_sold;
                                     pit.Qty_Sold__c = units_sold;                             
                                     pit.POS_Product__c = pinv.POS_Product__c;
                                     pit.POS_Location__c = pinv.POS_Location__c;
                                     pit.sold__c = true;
                                     pit.POS_Inventory__c = pinv.id;
                                     pinvTransacts.add(pit);
                                 }
    
    update PinvList;
    upsert pinvTransacts;
    
    
    
}