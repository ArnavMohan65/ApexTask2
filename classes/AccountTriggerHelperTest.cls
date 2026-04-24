@isTest
public class AccountTriggerHelperTest {
    
    @isTest
    static void testBulkAccountInsert() {
        // 1. Create a list of 100 Account records to test bulkified code
        List<Account> testAccs = new List<Account>();
        for (Integer i = 0; i < 100; i++) {
            // We leave Description blank to test the setDefaultValues logic
            testAccs.add(new Account(Name = 'Test Account Bulk ' + i));
        }
		
        // 2. Perform the insert (This fires the associated trigger)
        Test.startTest();
        insert testAccs;
        Test.stopTest();

        // 3. Verify Before Insert Logic: Check if Account Descriptions were set to 'Prospect'
        // We must re-query the database because memory records are not updated with trigger changes
        List<Account> insertedAccs = [SELECT Id, Description FROM Account WHERE Id IN :testAccs];
        for (Account acc : insertedAccs) {
            Assert.areEqual('Prospect', acc.Description, 'Account description should have been defaulted to Prospect.');
        }
        
        // 4. Verify After Insert Logic: Check if 100 Contacts with LastName 'Default' were created
        List<Contact> createdContacts = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId IN :testAccs];
        
        // Assert that exactly one contact was created for each of the 100 accounts
        Assert.areEqual(100, createdContacts.size(), 'Total of 100 default contacts should have been created.');
        
        // Ensure every contact is actually linked to one of our test accounts
        for (Contact con : createdContacts) {
            Assert.areEqual('Default', con.LastName, 'Contact last name should be Default.');
        }
    }
}