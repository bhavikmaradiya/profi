class FireStoreConfig {
  // user collection
  static const userCollection = 'users';
  static const userIdField = 'userId';
  static const userNameField = 'name';
  static const userEmailField = 'email';
  static const userRoleField = 'role';
  static const userFcmTokenField = 'fcmToken';

  // project collection
  static const projectCollection = 'projects';
  static const projectIdField = 'projectId';
  static const projectCodeField = 'projectCode';
  static const projectCodeIntField = 'projectCodeInt';
  static const projectNameField = 'projectName';
  static const bdmUserIdField = 'bdmUserId';
  static const pmUserIdField = 'pmUserId';
  static const projectStatusField = 'status';
  static const projectTypeField = 'projectType';
  static const currencyField = 'currency';
  static const countryField = 'country';
  static const totalFixedAmountField = 'totalFixedAmount';
  static const receivedAmountField = 'receivedAmount';
  static const createdByField = 'createdBy';
  static const createdByNameField = 'createdByName';
  static const specialNotesField = 'specialNotes';
  static const paymentCycleField = 'paymentCycle';
  static const projectStartDateField = 'projectStartDate';
  static const hourlyRateField = 'hourlyRate';
  static const weeklyHoursField = 'weeklyHours';
  static const totalHoursField = 'totalHours';
  static const monthlyAmountField = 'monthlyAmount';
  static const projectMilestoneIdField = 'milestoneId';
  static const projectAvailableForField = 'projectAvailableFor';

  // Milestones collection
  static const milestonesCollection = 'milestones';
  static const milestoneInfoCollection = 'milestoneInfo';
  static const milestoneIdField = 'milestoneId';
  static const milestoneCollectionIdField = 'milestoneCollectionId';
  static const milestoneDateField = 'milestoneDate';
  static const milestoneAmountField = 'milestoneAmount';
  static const milestonePaymentStatusField = 'paymentStatus';
  static const milestoneSequenceField = 'milestoneSequence';
  static const milestoneNotesField = 'milestoneNotes';
  static const milestoneReceivedAmountField = 'receivedAmount';
  static const milestoneUpdatedField = 'isUpdated';
  static const milestoneInvoicedField = 'isInvoiced';
  static const milestoneInvoicedUpdatedAtField = 'invoicedUpdatedAt';
  static const milestoneUpdatedByUserIdField = 'updatedByUserId';
  static const milestoneUpdatedByUserNameField = 'updatedByUserName';

  // transactions collection
  static const transactionsCollection = 'transactions';
  static const transactionIdField = 'transactionId';
  static const transactionProjectIdField = 'projectId';
  static const transactionProjectNameField = 'projectName';
  static const transactionProjectCodeField = 'projectCode';
  static const transactionByUserIdField = 'transactionByUserId';
  static const transactionByNameField = 'transactionByName';
  static const transactionProjectTypeField = 'projectType';
  static const transactionMilestoneIdField = 'milestoneId';
  static const transactionPaidAmountField = 'paidAmount';
  static const transactionUnPaidAmountField = 'unPaidAmount';
  static const transactionNotesField = 'notes';
  static const transactionDateField = 'transactionDate';
  static const transactionAvailableForField = 'transactionAvailableFor';

  // log collection
  static const logsCollections = 'logs';
  static const logIdField = 'logId';
  static const logProjectIdField = 'projectId';
  static const logProjectMilestoneIdField = 'projectMilestoneId';
  static const logMilestoneInfoIdField = 'milestoneInfoId';
  static const logOnField = 'on';
  static const logOldAmountField = 'oldAmount';
  static const logNewAmountField = 'newAmount';
  static const logOldDateField = 'oldDate';
  static const logNewDateField = 'newDate';
  static const logNotesField = 'notes';
  static const logTransactionField = 'transaction';
  static const logInvoicedField = 'invoiced';
  static const logGeneratedByUserIdField = 'generatedByUserId';
  static const logGeneratedByUserNameField = 'generatedByUserName';

  // settings
  static const settingsCollections = 'settings';
  static const settingsCurrencyDoc = 'currency';
  static const settingsDollarToInrField = 'dollarToInr';

  // General
  static const createdAtField = 'createdAt';
  static const updatedAtField = 'updatedAt';
}
