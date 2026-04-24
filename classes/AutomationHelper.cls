public class AutomationHelper {
	public static Boolean isFirstRun = true;
    
    //Set Description as Prospect 
    public static void setDefaultDescription(List<Account> accounts) {
        for (Account acc : accounts) {
            acc.Description = 'Prospect';
            acc.Total_Contacts__c = 1;
        }
    }

    // Default Contact
    public static void createDefaultContact(List<Account> accounts) {
        List<Contact> defaultContacts = new List<Contact>();
        for (Account acc : accounts) {
            defaultContacts.add(new Contact(
                FirstName = 'Mohit', 
                LastName = 'Default Contact',
                AccountId = acc.Id,
                SortOrder__c = 0 // The Default 0
            ));
        }
        if(!defaultContacts.isEmpty()) insert defaultContacts;
    }

    // Assign Sort Order 
    public static void assignSortOrder(List<Contact> newContacts) {
        Set<Id> accIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null) accIds.add(con.AccountId);
        }

        // Query current Max Sort Order
        Map<Id, Decimal> maxOrderMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [SELECT AccountId, MAX(SortOrder__c) maxOrder 
                                   FROM Contact WHERE AccountId IN :accIds GROUP BY AccountId]) {
            maxOrderMap.put((Id)ar.get('AccountId'), (Decimal)ar.get('maxOrder'));
        }

        for (Contact con : newContacts) {
            if (con.AccountId != null) {
                
                if (con.SortOrder__c != null) continue;

                Decimal currentMax = maxOrderMap.containsKey(con.AccountId) ? maxOrderMap.get(con.AccountId) : 0;
                
                // If max is 0 (Default Contact exists), manual contacts start at 1.
                // If max is NULL (No contacts exist), this logic handles that via the map check.
                con.SortOrder__c = currentMax + 1;
                maxOrderMap.put(con.AccountId, con.SortOrder__c);
            }
        }
    }

    //Maintain Order and Count after Update
    public static void updateAccountContactCountAndOrder(List<Contact> contacts, Map<Id, Contact> oldMap) {
        
        if (!isFirstRun) return; 
        isFirstRun = false; 

        Set<Id> accIds = new Set<Id>();
        for (Contact con : contacts) {
            if (con.AccountId != null) accIds.add(con.AccountId);
            if (oldMap != null && oldMap.get(con.Id).AccountId != con.AccountId) {
                accIds.add(oldMap.get(con.Id).AccountId);
            }
        }

        if (accIds.isEmpty()) return;

        //List<Contact> contactsToUpdate = new List<Contact>();
        //List<Account> accountsToUpdate = new List<Account>();
        
        List<Contact> allContacts = [SELECT Id, AccountId, SortOrder__c 
                                 FROM Contact 
                                 WHERE AccountId IN :accIds 
                                 ORDER BY AccountId, SortOrder__c ASC, CreatedDate ASC];
        
        Map<Id, Integer> accountIndexMap = new Map<Id, Integer>();
        List<Contact> contactsToUpdate = new List<Contact>();

        /*for (Account acc : [SELECT Id, Total_Contacts__c, (SELECT Id, SortOrder__c FROM Contacts ORDER BY SortOrder__c ASC, CreatedDate ASC) 
                            FROM Account WHERE Id IN :accIds]) {
            Integer index = 0;
            for (Contact con : acc.Contacts) {
                if (con.SortOrder__c != index) {
                    con.SortOrder__c = index;
                    contactsToUpdate.add(con);
                }
                index++;
            }
            
            if (acc.Total_Contacts__c != acc.Contacts.size()) {
                acc.Total_Contacts__c = acc.Contacts.size();
                accountsToUpdate.add(acc);
            }
        }*/
        
        //update sortOrder of the contacts
        for (Contact con : allContacts) {
            Integer currIndex = accountIndexMap.containsKey(con.AccountId) ? accountIndexMap.get(con.AccountId) : 0;
            
                if (con.SortOrder__c != currIndex) {
                    con.SortOrder__c = currIndex;
                    contactsToUpdate.add(con);
                }
                //index++;
                accountIndexMap.put(con.AccountId,currIndex + 1);
            }
            
            /*if (acc.Total_Contacts__c != acc.Contacts.size()) {
                acc.Total_Contacts__c = acc.Contacts.size();
                accountsToUpdate.add(acc);
            }*/
        
       	//update Accounts
       	List<Account> AccountsToUpdate = new List<Account>();
		for(Account acc : [SELECT Id,Total_Contacts__c 
                           FROM Account 
                           WHERE Id in :accIds]){
                               Integer newCt = accountIndexMap.containsKey(acc.Id) ? accountIndexMap.get(acc.Id) : 0;
                               if(acc.Total_Contacts__c != newCt){
                                   acc.Total_Contacts__c = newCt;
                                   AccountsToUpdate.add(acc);
                               }
                           }

        if (!contactsToUpdate.isEmpty()) update contactsToUpdate;
        if (!accountsToUpdate.isEmpty()) update accountsToUpdate;
    }
}