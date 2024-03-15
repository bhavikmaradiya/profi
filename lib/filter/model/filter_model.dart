class FilterModel {
  final dynamic filterEnum;
  final String value;
  bool isSelected;

  FilterModel({
    required this.filterEnum,
    required this.value,
    this.isSelected = false,
  });
}
