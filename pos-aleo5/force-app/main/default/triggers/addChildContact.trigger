trigger addChildContact on Account (after insert, after update) {
    //@amitabh 19 April 2016
    //I want to show all the contacts of the Child and Grand child account with the parent account
    //The intent is that We can manage contact using the account hirerchy but would like to show all 
    //together at the HeadQuarter in a UI, so that we are able to create a VF page
   //passing all contacts Id to a list 
   //this is not a completed code will check later
   
   Set<ID> ContactId ;
    For (Account acc:Trigger.new){
        //where the Parent Account Id is blank
        if(acc.ParentId <> NULL){
          //  ContactId = acc.c
        }
    }

}