import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Providers/accept_order_provider.dart';
import 'package:bill_desk/Providers/app_language_provider.dart';
import 'package:bill_desk/Providers/category_provider.dart';
import 'package:bill_desk/Providers/edit_order_provider.dart';
import 'package:bill_desk/Providers/home_provider.dart';
import 'package:bill_desk/Providers/image_upload_provider.dart';
import 'package:bill_desk/Providers/product_detail_provider.dart';
import 'package:bill_desk/Providers/report_provider.dart';
import 'package:bill_desk/Providers/view_report_provider.dart';
import 'package:bill_desk/Views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? appLocale;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String language = prefs.getString("language_code") ?? "en";
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp(
    locale: language,
  ));
}

class MyApp extends StatelessWidget {
  final String locale;
  const MyApp({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguage()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => AcceptOrderProvider()),
        ChangeNotifierProvider(create: (_) => EditOrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailProvider()),
        ChangeNotifierProvider(create: (_) => ViewReportProvider()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<AppLanguage>(builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: provider.languageCode ?? Locale(locale),
          theme: ThemeData(
            fontFamily: "Roboto",
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: purpleColor,
              foregroundColor: whiteColor,
            ),
          ),
          home: const SplashScreen(),
        );
      }),
    );
  }
}
