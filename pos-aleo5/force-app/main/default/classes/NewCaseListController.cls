public class NewCaseListController {
    List<Case> results = new List<Case>();
    public List<Case> getNewCases(){
        
        results = [SELECT Id, CaseNumber, Status FROM Case where status = 'New'];
      return results;      
    }
    

}