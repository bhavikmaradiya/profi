import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './add_project/add_project.dart';
import './add_project/add_project_field_bloc/add_project_field_bloc.dart';
import './add_project/firebase_add_project_bloc/firebase_add_project_bloc.dart';
import './add_user/add_user.dart';
import './add_user/bloc/add_user_bloc.dart';
import './authentication/authentication.dart';
import './dashboard/bloc/dashboard_bloc.dart';
import './dashboard/dashboard.dart';
import './filter/bloc/filter_bloc.dart';
import './filter/filter_projects.dart';
import './inward_transactions/inward_transactions.dart';
import './manage_user/bloc/manage_user_bloc.dart';
import './manage_user/manage_user.dart';
import './profile/profile.dart';
import './project_list/milestone_operations_bloc/milestone_operations_bloc.dart';
import './project_list/project_operations_bloc/project_operations_bloc.dart';
import './settings/settings.dart';

class Routes {
  static const String authentication = '/authentication';
  static const String profile = '/profile';
  static const String dashboard = '/dashboard';
  static const String addEditProject = '/addEditProject';
  static const String filter = '/filter';
  static const String inwardTransactions = '/inwardTransactions';
  static const String settings = '/settings';
  static const String addUser = '/addUser';
  static const String manageUsers = '/manageUsers';

  static Map<String, WidgetBuilder> get routeList => {
        authentication: (_) => Authentication(),
        profile: (_) => Profile(),
        dashboard: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => DashboardBloc(),
                ),
                BlocProvider(
                  create: (_) => ProjectOperationsBloc(),
                ),
                BlocProvider(
                  create: (_) => MilestoneOperationsBloc(),
                ),
              ],
              child: const Dashboard(),
            ),
        addEditProject: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => AddProjectFieldBloc(),
                ),
                BlocProvider(
                  create: (_) => FirebaseAddProjectBloc(),
                ),
              ],
              child: const AddProject(),
            ),
        filter: (_) => BlocProvider(
              create: (_) => FilterBloc(),
              child: const FilterProjects(),
            ),
        inwardTransactions: (_) => const InwardTransactions(),
        settings: (_) => Settings(),
        addUser: (_) => BlocProvider(
              create: (_) => AddUserBloc(),
              child: AddUser(),
            ),
        manageUsers: (_) => BlocProvider(
              create: (_) => ManageUserBloc(),
              child: const ManageUser(),
            ),
      };
}
