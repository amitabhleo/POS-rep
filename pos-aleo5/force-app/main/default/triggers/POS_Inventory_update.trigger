/*
Updating the Inventory on transfer from one location to another
reducing inventory from and adding to the to
I will be quering POS Inventory Transaction and update the location
@amitabh December 15, 2018 I will have to take the Location from and to from the 
POS Trasnfer Header, as this has to work in a single screen where i create the header and 
the child items from a selection
*/

trigger POS_Inventory_update on POS_Inventory_Transaction__c (after insert) {
    //Creating a set of Id to get the 
    Set<ID> pInvIdsTo = new Set<ID>();
    Set<ID> pInvIdsFrom = new Set<ID>();
    Double qty_transfered = 0;
        
    for(POS_Inventory_Transaction__c pit: Trigger.new){
        //passing this trigger only when not an order
        if(pit.sold__c <> true){
            //passing the ids into the set
            pInvIdsTo.add(pit.POS_Inventory__c);
            pInvIdsFrom.add(pit.POS_Inventory_From__c);
            qty_transfered = pit.Qty_Sold__c;
            
        }
        
    }
    System.debug('qty transferred '+qty_transfered);
    //Step 1: Query both the table and upate the qty field in the respective POS Inventory table
    List<POS_Inventory__c> pInvTos = new List <POS_Inventory__c>();
    List<POS_Inventory__c> pInvFroms = new List <POS_Inventory__c>();
    //quering the field
    for (POS_Inventory__c pInvto :[SELECT Id, Name, POS_Location__c, 
                                   POS_Product__c, Qty_on_Hand__c, Qty_Allocated__c, 
                                   Qty_Available__c FROM POS_Inventory__c where ID IN:pInvIdsTo]){
                                       //updatng the To
                                       System.debug('pInvto Id :'+pInvto);
                                       
                                       POS_Inventory__c p = new POS_Inventory__c();
                                       p.Id = pInvto.Id;
                                       p.Qty_on_Hand__c = pInvto.Qty_on_Hand__c + qty_transfered; 
                                       p.Name =  pInvto.Name;
                                       // p.POS_Product__c = pinvto.POS_Product__c; 
                                       pInvTos.add(p);
                                   }
    for (POS_Inventory__c pInvFrom :[SELECT Id, Name, POS_Location__c, 
                                     POS_Product__c, Qty_on_Hand__c, Qty_Allocated__c, 
                                     Qty_Available__c FROM POS_Inventory__c where ID IN:pInvIdsFrom]){
                                         //updatng the From
                                         System.debug('pInvfrom Id :'+pInvFrom);
                                         //pInvFrom.Qty_on_Hand__c = pInvFrom.Qty_on_Hand__c - qty_transfered;
                                         POS_Inventory__c p2 = new POS_Inventory__c();
                                         p2.Id = pInvFrom.Id;
                                         p2.Qty_on_Hand__c = pInvFrom.Qty_on_Hand__c - qty_transfered; 
                                         p2.Name =  pInvFrom.Name;
                                         //p2.POS_Product__c = pInvFrom.POS_Product__c;   
                                         pInvFroms.add(p2);    
                                     }
    
    update pInvTos;
    update pInvFroms;
    
}