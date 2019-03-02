/*
@Amitabh January 21, 2019
I will be updating the POS source and POS Destination and POS products afer quering the POs order
checking if this can be updated from here
@modified to update POS Item transaction on January 27, 2019
*/
trigger POS_Order_Products_update1 on POS_Order_Products__c (after insert, before update,after update ){

//Step1 querying the details of POS product, POS source and destination

Set<ID> prodIds = new Set<ID>();

//to stop recursion we have to populate the values
for (POS_Order_Products__c pop:Trigger.new)
{
    //if(trigger.isBefore){ "did not return any value"
    if(pop.updated__c == false ){
        prodIds.add(pop.POS_Products__c);            
    }  
        //}               
}
Map <ID,POS_Inventory__c> mapInventory = new Map<ID,POS_Inventory__c> ();
List<POS_Inventory__c> posProdItems = new List<POS_Inventory__c>();
List <POS_Order_Products__c> posOrdProds = new List<POS_Order_Products__c>();
List <POS_Inventory_Transaction__c> PosInvTrsns = new List<POS_Inventory_Transaction__c>();
Integer qtyInHand = 0;
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
        qtyInHand = Integer.valueOf(posItem.Qty_on_Hand__c);
        posProdItems.add(pItm);
        mapInventory.put(posItem.POS_Location__c,posItem);
        System.debug('value of qtyInHand'+qtyInHand);
    }
    //adding POS items to update once POS transaction is created
    POS_Inventory__c posInv = new POS_Inventory__c();
    //Step3 fetch the relevent details from POS Order Producsts
    for(POS_Order_Products__c posOrdPrd:[SELECT Id, Name, POS_Orders__c,POS_Orders__r.pos__c,
                                            POS_Orders__r.destinationPOS_Id__c, POS_Products__c, 
                                            Destination_POS_Id__c, Source_POS_Id__c, updated__c,
                                            POS_Source_Location__c, POS_Source_Inventory__c,Units__c,
                                            POS_Inventory__c, POS_Location__c FROM POS_Order_Products__c 
                                            where POS_Products__c IN:prodIds])
    {
        
        //adding the ids of the POS inventory
        POS_Order_Products__c pop = new POS_Order_Products__c();
        pop.Id = posOrdPrd.Id;
        pop.POS_Source_Location__c = posOrdPrd.POS_Orders__r.pos__c;
        pop.POS_Location__c = posOrdPrd.POS_Orders__r.destinationPOS_Id__c;
        
        pop.POS_Source_Inventory__c = mapInventory.get(posOrdPrd.POS_Orders__r.pos__c).id;
        //Creating a first new POS Item Transaction here this will be used to update the TOtal items
        //this fixes #1 in issues for this project 
        //we can create a method and call this function from a Class
            POS_Inventory_Transaction__c posInvTr = new POS_Inventory_Transaction__c();
            posInvTr.POS_Order_Product__c = posOrdPrd.Id;
            posInvTr.POS_Inventory__c = mapInventory.get(posOrdPrd.POS_Orders__r.pos__c).id;
            posInvTr.POS_Product__c = posOrdPrd.POS_Products__c;
            posInvTr.POS_Order__c = posOrdPrd.POS_Orders__c;
            PosInvTr.Qty_Sold__c = 	-1*(posOrdPrd.Units__c);
            PosInvTrsns.add(posInvTr);
            //adding or reducing pos inventory product
            posInv.Qty_on_Hand__c = qtyInHand + (-1*(posOrdPrd.Units__c));
            posInv.id = mapInventory.get(posOrdPrd.POS_Orders__r.pos__c).id;
            posProdItems.add(posInv);
            System.debug('value of posProduct Item'+posProdItems);
        if(mapInventory.containsKey(posOrdPrd.POS_Orders__r.destinationPOS_Id__c) 
        && mapInventory.get(posOrdPrd.POS_Orders__r.destinationPOS_Id__c)!=null)
        {
        pop.POS_Inventory__c = mapInventory.get(posOrdPrd.POS_Orders__r.destinationPOS_Id__c).id;
        //Creating the 2nd POS order transaction recor d to show the double entry of the transaction
         //this fixes #1 in issues for this project
        POS_Inventory_Transaction__c posInvTr1 = new POS_Inventory_Transaction__c();
            posInvTr1.POS_Order_Product__c = posOrdPrd.Id;
            posInvTr1.POS_Inventory__c = mapInventory.get(posOrdPrd.POS_Orders__r.destinationPOS_Id__c).id;
            posInvTr1.POS_Product__c = posOrdPrd.POS_Products__c;
            posInvTr1.POS_Order__c = posOrdPrd.POS_Orders__c;
            PosInvTr1.Qty_Sold__c = posOrdPrd.Units__c;
            PosInvTrsns.add(posInvTr1);
        }
        //Creating a new Pos Intentor destination
        else {
            POS_Inventory__c newPosItem = new POS_Inventory__c();
            newPosItem.POS_Location__c = posOrdPrd.POS_Orders__r.destinationPOS_Id__c;
            newPosItem.POS_Product__c = mapInventory.get(posOrdPrd.POS_Orders__r.pos__c).POS_Product__c;
            newPosItem.name = 'to update later';
            System.debug('value of NewPOSItem :' + newPosItem);
           posProdItems.add(newPosItem);
        }
        pop.updated__c=true;
        
        System.debug(pop.Id +'==='+mapInventory.get(posOrdPrd.POS_Orders__r.destinationPOS_Id__c));
        posOrdProds.add(pop);
    }
    
}
System.debug('value of Map'+mapInventory);
System.debug('value of POSProduct Item'+posProdItems);
//upsert posProdItems;
upsert posOrdProds;
upsert PosInvTrsns;


}