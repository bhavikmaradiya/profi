import './filter_model.dart';
import '../../profile/model/profile_info.dart';

class AppliedFilterInfo {
  List<FilterModel> sortByList;
  List<FilterModel> statusList;
  List<FilterModel> typeList;
  List<ProfileInfo> selectedPMList;
  List<ProfileInfo> selectedBDMList;

  AppliedFilterInfo({
    required this.sortByList,
    required this.statusList,
    required this.typeList,
    required this.selectedPMList,
    required this.selectedBDMList,
  });
}
