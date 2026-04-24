trigger ContactTrigger on Contact (before insert, after update, after delete, after undelete) {
	if (Trigger.isBefore && Trigger.isInsert) {
        ContactTriggerHandler.handleBeforeInsert(Trigger.new);
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUndelete) {
            ContactTriggerHandler.handleAfterInsertUndelete(Trigger.new);
        } else if (Trigger.isUpdate) {
            ContactTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            ContactTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}