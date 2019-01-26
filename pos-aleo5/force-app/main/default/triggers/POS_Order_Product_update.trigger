/*
 * @amitabh on October 18, 2015, amitabhleo@gmail.com
 * updating the Order product details while fetching the POS Location and POS inventory
 * and also updating the briefs of all the pos order products to POS order
 * 
*/
trigger POS_Order_Product_update on POS_Order_Products__c (before insert) {
    //creating a set to populate all the ids of the Sales Order
    Set<ID> pos_ord_Ids = new Set<ID>();
    //iterating thru the for
    for(POS_Order_Products__c pop :Trigger.new){
        //populating the Set
        pos_ord_Ids.add(pop.POS_Orders__c);
    }
    //Step 2: Populate the POS Location in the POS order product from POS order
    List<POS_Order__c> posOrdrs = new List<POS_Order__c>();
    
}