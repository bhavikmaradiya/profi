class MultipleMilestoneInfo {
  String? milestoneId;
  double? milestoneAmount;
  double? receivedAmount;
  double? pendingPaidUnPaidAmount;
  int? transactionDate;
  DateTime? milestoneDate;
  String? notes;

  MultipleMilestoneInfo({
    required this.milestoneId,
    required this.milestoneAmount,
    required this.receivedAmount,
    required this.pendingPaidUnPaidAmount,
    required this.transactionDate,
    required this.milestoneDate,
    required this.notes,
  });
}
