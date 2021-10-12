// import 'package:admob_flutter/admob_flutter.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pick_photos_by_month/make_up_images_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Admob.initialize();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        locale: Get.deviceLocale,
        // 다국어 셋팅 start
        // localizationsDelegates: context.localizationDelegates,
        // supportedLocales: context.supportedLocales,
        // locale: context.locale,
        // 다국어 셋팅 end
        // 디버그 표시 없애기 위한 용도
        debugShowCheckedModeBanner: false,
        title: '우리아이 사진정리',
        theme: ThemeData(
          primaryColor: Colors.black,
          accentColor: Colors.black,
          fontFamily: 'Raleway',
          // scaffoldBackgroundColor: Colors.white,
        ),
        // darkTheme: ThemeData.dark(),
        home: MakeUpImagesPage() // LoginPage(), // MakeUpImagesPage()
    );
  }
}
