import './filter_model.dart';

class AppliedFilterInfo {
  List<FilterModel> sortByList;
  List<FilterModel> statusList;
  List<FilterModel> typeList;

  AppliedFilterInfo({
    required this.sortByList,
    required this.statusList,
    required this.typeList,
  });
}