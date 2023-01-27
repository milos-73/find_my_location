import 'package:find_me/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'category_provider.dart';
import 'live_location.dart';
import 'location_provider.dart';
import 'marker_provider.dart';
import 'markers_category_model.dart';
import 'markers_model.dart';
import 'network_tile_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

late Box box;
late Box box_category;

Future<void> main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MyMarkersAdapter());
  Hive.registerAdapter(MyMarkersCategoryAdapter());
  box = await Hive.openBox<MyMarkers>('myMarkersBox');
  box_category = await Hive.openBox<MyMarkersCategory>('myMarkersCategoryBox');

  MobileAds.instance.initialize();
  final RequestConfiguration requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
  maxAdContentRating: MaxAdContentRating.ma);
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);


  await SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<MarkerProvider>(create:(context) => MarkerProvider()),
      ChangeNotifierProvider<LocationProvider>(create:(context) => LocationProvider()),
      ChangeNotifierProvider<CategoryProvider>(create:(context) => CategoryProvider()),
    ],

     child: FindMeApp()));
}

class FindMeApp extends StatelessWidget {
  const FindMeApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Find my location',
      theme: ThemeData(
        primarySwatch: mapBoxBlue,
      ),
      home: const LiveLocationPage(),
      routes: <String, WidgetBuilder>{
        NetworkTileProviderPage.route: (context) => const NetworkTileProviderPage(),
        LiveLocationPage.route: (context) => const LiveLocationPage(),
        WidgetsPage.route: (context) => const WidgetsPage(),

      }
    );
  }
}

// Generated using Material Design Palette/Theme Generator
// http://mcg.mbitson.com/
// https://github.com/mbitson/mcg
const int _bluePrimary = 0xFF395afa;
const MaterialColor mapBoxBlue = MaterialColor(
  _bluePrimary,
  <int, Color>{
    50: Color(0xFFE7EBFE),
    100: Color(0xFFC4CEFE),
    200: Color(0xFF9CADFD),
    300: Color(0xFF748CFC),
    400: Color(0xFF5773FB),
    500: Color(_bluePrimary),
    600: Color(0xFF3352F9),
    700: Color(0xFF2C48F9),
    800: Color(0xFF243FF8),
    900: Color(0xFF172EF6),
  },
);
