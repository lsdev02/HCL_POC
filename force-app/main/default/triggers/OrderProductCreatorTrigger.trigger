trigger OrderProductCreatorTrigger on Order (after insert) {
    if (Trigger.isInsert && Trigger.isAfter) {
        OrderProductCreatorTriggerHandler.createOrderProduct(Trigger.newMap);
    }
}