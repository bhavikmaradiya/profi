import '../../enums/drawer_menu_enum.dart';

class DashboardDrawerMenu {
  final DrawerMenuEnum menuEnum;
  final String iconPath;
  final String name;

  const DashboardDrawerMenu({
    required this.menuEnum,
    required this.iconPath,
    required this.name,
  });
}
