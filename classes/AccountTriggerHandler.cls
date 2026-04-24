public class AccountTriggerHandler {
	public static void handleBeforeInsert(List<Account> newAccounts) {
        AutomationHelper.setDefaultDescription(newAccounts);
    }
    
    public static void handleAfterInsert(List<Account> newAccounts) {
        AutomationHelper.createDefaultContact(newAccounts);
    }
}