class DropDownModel {
  final int id;
  String? uniqueId;
  final String value;
  bool isSelected;

  DropDownModel({
    required this.id,
    required this.value,
    this.uniqueId,
    this.isSelected = false,
  });

  @override
  bool operator ==(Object other) {
    return other is DropDownModel &&
        (other.id == id ||
            (other.uniqueId != null &&
                uniqueId != null &&
                other.uniqueId == uniqueId));
  }
}
