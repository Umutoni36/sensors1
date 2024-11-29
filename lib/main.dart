import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sensormobileapplication_main/components/ThemeProvider.dart';
import 'package:sensormobileapplication_main/screens/StepCounter.dart';
import 'package:sensormobileapplication_main/screens/compass.dart';
import 'package:sensormobileapplication_main/screens/lightsensor.dart';
import 'package:sensormobileapplication_main/screens/maps.dart';
import 'package:sensormobileapplication_main/screens/proximitysensor.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
  await initNotifications();
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      const InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {},
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeNotifier.currentTheme,
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({required this.title, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isExpanded = false;
  String _expandedCardTitle = '';
  String _expandedCardDescription = '';
  String _expandedCardAnimationPath = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.hintColor,
        title: Text(
          widget.title,
          style: TextStyle(color: theme.primaryColor),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_isExpanded) {
            setState(() {
              _isExpanded = false;
              _expandedCardTitle = '';
              _expandedCardDescription = '';
              _expandedCardAnimationPath = '';
            });
          }
        },
        child: Stack(
          children: [
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCard(
                  theme,
                  'Geofence',
                  'Geofence sensor detects when a device enters or exits a designated geographical area.',
                  'lib/assets/Animation - 1715439026773.json',
                ),
                _buildCard(
                  theme,
                  'LightSensor',
                  'Light sensor measures ambient light levels and provides data on the brightness of the surroundings.',
                  'lib/assets/Animation - 1715610777778.json',
                ),
                _buildCard(
                  theme,
                  'StepCounter',
                  'Step counter sensor tracks the number of steps taken by a person throughout the day.',
                  'lib/assets/Animation - 1712341175314.json',
                ),
                _buildCard(
                  theme,
                  'Compass',
                  'Compass sensor determines the direction in which a device is pointing relative to the Earth\'s magnetic North Pole.',
                  'lib/assets/Animation - 1715611200689.json',
                ),
                _buildCard(
                  theme,
                  'Proximity',
                  'Proximity sensor detects the presence of nearby objects without any physical contact.',
                  'lib/assets/Animation - 1712058538433.json',
                ),
              ],
            ),
            if (_isExpanded)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: SizedBox(
                      width: 350, // Set the width of the container
                      height: 500, // Set the height of the container
                      child: Card(
                        color: theme.hintColor,
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _expandedCardTitle,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Add the Lottie animation for the expanded card
                              Lottie.asset(
                                _expandedCardAnimationPath,
                                width: 160,
                                height: 160,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _expandedCardDescription,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'This is the content of $_expandedCardTitle.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(context, themeNotifier, theme),
    );
  }

  Widget _buildCard(
    ThemeData theme,
    String title,
    String description,
    String animationPath,
  ) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = true;
            _expandedCardTitle = title;
            _expandedCardDescription = description;
            _expandedCardAnimationPath = animationPath;
          });
        },
        child: Card(
          color: theme.hintColor,
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: SizedBox(
            width: 200, // Set the desired width
            height: 600, // Set the desired height
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),

                  // Add the Lottie animation
                  Lottie.asset(
                    animationPath,
                    width: 99,
                    height: 98,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

Widget _buildSpeedDial(
    BuildContext context, ThemeNotifier themeNotifier, ThemeData theme) {
  return SpeedDial(
    icon: Icons.menu,
    activeIcon: Icons.close,
    backgroundColor: theme.hintColor,
    foregroundColor: theme.primaryColor,
    overlayColor: Colors.transparent,
    children: [
      SpeedDialChild(
        child: Icon(Icons.palette, color: theme.primaryColor),
        backgroundColor: theme.hintColor,
        label: 'Toggle Theme',
        onTap: () => themeNotifier.toggleTheme(),
      ),
      SpeedDialChild(
        child: Icon(Icons.map, color: theme.primaryColor),
        backgroundColor: theme.hintColor,
        label: 'Maps',
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const MapPage())),
      ),
      SpeedDialChild(
        child: Icon(Icons.sensor_door, color: theme.primaryColor),
        backgroundColor: theme.hintColor,
        label: 'Proximity Sensor',
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ProximityPage())),
      ),
      SpeedDialChild(
        child: Icon(Icons.run_circle_outlined, color: theme.primaryColor),
        backgroundColor: theme.hintColor,
        label: 'Step Counter',
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => StepCounterPage())),
      ),
      SpeedDialChild(
        child:
            Icon(Icons.compass_calibration_outlined, color: theme.primaryColor),
        backgroundColor: theme.hintColor,
        label: 'Compass',
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => CompassPage())),
      ),
      SpeedDialChild(
        child: Icon(Icons.lightbulb_rounded, color: theme.primaryColor),
        backgroundColor: theme.hintColor,
        label: 'Light Sensor',
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LightSensorPage())),
      ),
    ],
  );
}
