import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layout/layout.dart';

import 'firebase_options.dart';
import 'pages/home/home_page.dart';
// import 'utils/configure_web.dart';
import 'utils/routes.dart';
import 'utils/values/app_theme.dart';
import 'utils/values/values.dart';

// Text
// TODO: Fix Text Background Color
// TODO: Make Text properly Selectable

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // configureApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Website());
}

class Website extends StatelessWidget {
  const Website({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: StringConst.appTitle,
        theme: AppTheme.lightThemeData,
        initialRoute: HomePage.homePageRoute,
        onGenerateRoute: RouteConfiguration.onGenerateRoute,
        home: const HomePage(),
      ),
    );
  }
}
