import 'package:cinema/screens/auth/signin.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final orange = Color.fromARGB(255, 240, 89, 41);
    final blue = Color.fromARGB(255, 33, 153, 227);
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) =>
            ThemeData(
              primaryColor: blue,
              scaffoldBackgroundColor: brightness == Brightness.light
                  ? Colors.grey[100]
                  : Colors.grey[850],
              accentColor: orange,
              toggleableActiveColor: orange,
              dividerColor:
              brightness == Brightness.light ? Colors.white : Colors.white54,
              brightness: brightness,
              fontFamily: 'PTSans',
              bottomAppBarTheme: Theme
                  .of(context)
                  .bottomAppBarTheme
                  .copyWith(
                elevation: 0,
              ),
              iconTheme: Theme
                  .of(context)
                  .iconTheme
                  .copyWith(color: orange),
            ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: title,
            theme: theme,
            navigatorKey: navigatorKey,
            home: SignIn(),
          );
        });
  }
}


final navigatorKey = GlobalKey<NavigatorState>();

