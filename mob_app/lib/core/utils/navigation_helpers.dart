import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

import '../constants/route_paths.dart';


extension SafeNavigation on BuildContext {


  void safePop() {
    if (canPop()) {
      pop();
    } else {
      go(RoutePaths.welcome);
    }
  }
}
