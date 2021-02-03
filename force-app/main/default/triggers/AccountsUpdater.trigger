trigger AccountsUpdater on Account (after insert)  {
   System.debug('Making future call to update account');
   for (Account acc : Trigger.New) {
   // AccountUpdater.updateAccount(acc.Id);
  }
}