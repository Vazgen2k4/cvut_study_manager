import 'package:cvut_study_manager/ui/pages/home/home_page.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';


abstract class AppRoutes {
  const AppRoutes._();
  
  static const String home = '/';

  static List<AppRoute> get routes {
    const routesList = <AppRoute>[
      AppRoute(page: HomePage(), path: home)
    ];

    return routesList.toSet().toList();
  }
}

class AppRoute extends Equatable {
  final Widget page;
  final String path;
  const AppRoute({
    required this.page,
    required this.path,
  });

  @override
  List<Object> get props => [path];
}
