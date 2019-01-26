trigger UserHirerachy on User (before insert, before update) {
//printing the user hierachy in a list
	Set<Id> uId = new Set<Id>();
    for(User subUser:trigger.new){
        if(subUser.Hirarchy_field__c <> null){
            uId.add(subUser.hirarchy_field__c);
            subUser.id =subUser.Hirarchy_field__c;
        }
    }
    //Let is go to the Managers's Manager
    List<User> userList = new List<user>();
    for(User mgr:[Select Id,userName,hirarchy_field__c from user where Id IN:uid ]){
        System.debug('User Name of Manager :'+mgr.userName);
            
    }
}