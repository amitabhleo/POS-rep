/*
  	@Amitabh January 21, 2019
	I will be updating the POS source and POS Destination and POS products afer quering the POs order
    checking if this can be updated from here just connected the github need to test how this will work.

*/
trigger POS_Order_Products_update1 on POS_Order_Products__c (after insert, before update,after update ){

//Step1 querying the details of POS product, POS source and destination
    
    Set<ID> prodIds = new Set<ID>();
    
    //to stop recursion we have to populate the values
    for (POS_Order_Products__c pop:Trigger.new)
    {
        //if(trigger.isBefore){
        if(pop.updated__c == false ){
            prodIds.add(pop.POS_Products__c);            
        }  
        //}               
    }
    Map <ID,POS_Inventory__c> mapInventory = new Map<ID,POS_Inventory__c> ();
    List<POS_Inventory__c> posProdItems = new List<POS_Inventory__c>();
    List <POS_Order_Products__c> posOrdProds = new List<POS_Order_Products__c>();
    if(trigger.isAfter){
   
        //Step2 Iterating thru the product items and search for 
        //Map <ID,POS_Inventory__c> mapInventory = new Map<ID,POS_Inventory__c> ();
        for (POS_Inventory__c posItem:[SELECT Id, Name, POS_Location__c, POS_Product__c, 
                                       Qty_on_Hand__c, POS__c, Qty_Available__c FROM POS_Inventory__c
                                       WHERE POS_Product__c IN: prodIds])
        {
            POS_Inventory__c pItm = new POS_Inventory__c();
            pItm.Id = posItem.Id;
            pItm.POS_Location__c =posItem.POS_Location__c;
            //pItm.POS_Product__c = posItem.POS_Product__c;
            pItm.Qty_on_Hand__c = posItem.Qty_on_Hand__c;
            posProdItems.add(pItm);
            mapInventory.put(posItem.POS_Location__c,posItem);
        }
        //Step3 fetch the relevent details from POS Order Producsts
        for(POS_Order_Products__c posOrdPrd:[SELECT Id, Name, POS_Orders__c,POS_Orders__r.pos__c,
                                             POS_Orders__r.destinationPOS_Id__c, POS_Products__c, 
                                             Destination_POS_Id__c, Source_POS_Id__c, updated__c,
                                             POS_Source_Location__c, POS_Source_Inventory__c, 
                                             POS_Inventory__c, POS_Location__c FROM POS_Order_Products__c 
                                             where POS_Products__c IN:prodIds])
        {
            
            //adding the ids of the POS inventory
            POS_Order_Products__c pop = new POS_Order_Products__c();
            pop.Id = posOrdPrd.Id;
            pop.POS_Source_Location__c = posOrdPrd.POS_Orders__r.pos__c;
            pop.POS_Location__c = posOrdPrd.POS_Orders__r.destinationPOS_Id__c;
            
            pop.POS_Source_Inventory__c = mapInventory.get(posOrdPrd.POS_Orders__r.pos__c).id;
            //reducing the inventory with the item ordered
            if(mapInventory.containsKey(posOrdPrd.POS_Orders__r.destinationPOS_Id__c) && 
                mapInventory.get(posOrdPrd.POS_Orders__r.destinationPOS_Id__c)!=null)
            pop.POS_Inventory__c = mapInventory.get(posOrdPrd.POS_Orders__r.destinationPOS_Id__c).id;
            pop.updated__c=true;
            
            System.debug(pop.Id +'==='+mapInventory.get(posOrdPrd.POS_Orders__r.destinationPOS_Id__c));
            posOrdProds.add(pop);
        }
        
    }
    System.debug('value of Map'+mapInventory);
    System.debug('value of POSProduct Item'+posProdItems);
    System.debug('value of POSOrdProds'+posOrdProds);
    upsert posOrdProds;
   
    
}