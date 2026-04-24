public class ContactTriggerHandler {
	public static void handleBeforeInsert(List<Contact> newContacts) {
        AutomationHelper.assignSortOrder(newContacts);
    }

    public static void handleAfterInsertUndelete(List<Contact> newContacts) {
        AutomationHelper.updateAccountContactCountAndOrder(newContacts, null);
    }

    public static void handleAfterUpdate(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        AutomationHelper.updateAccountContactCountAndOrder(newContacts, oldMap);
    }

    public static void handleAfterDelete(List<Contact> oldContacts) {
        AutomationHelper.updateAccountContactCountAndOrder(oldContacts, null);
    }
}