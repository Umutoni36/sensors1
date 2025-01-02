import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:sensor/main.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

class StepCounterPage extends StatefulWidget {
  @override
  _StepCounterPageState createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  int _stepCount = 0;
  bool _motionDetected = false;
  bool _notificationShown = false;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  int _selectedNumber = 100;

  List<TimeSeriesStepCount> _stepData = [];

  @override
  void initState() {
    super.initState();
    _startListeningToAccelerometer();
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  void _startListeningToAccelerometer() {
    Timer? motionTimer;

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.z.abs() > 10.0) {
        setState(() {
          _stepCount++;
          _motionDetected = true;
          _triggerNotification();
          _notificationShown = true;
          _triggerGoalNotification();
          _stepData.add(TimeSeriesStepCount(DateTime.now(), _stepCount));

          motionTimer?.cancel();
          motionTimer = Timer(const Duration(seconds: 10), () {
            if (mounted) {
              setState(() {
                _motionDetected = false;
                _notificationShown = false;
              });
            }
          });
        });
      }
    });
  }

  void _triggerNotification() async {
    if (!_notificationShown) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'StepCounter_channel',
        'StepCounter Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Hello!',
        'Motion detected! Keep It Up',
        platformChannelSpecifics,
      );
      print('Motion detected! Alerting user...');
      _notificationShown = true;
    }
  }

  void _triggerGoalNotification() async {
    if (_stepCount >= _selectedNumber) {
      // Calculate the next goal
      int nextGoal = (_selectedNumber ~/ 100 + 1) * 100;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'StepCounter_channel',
        'StepCounter Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Hello!',
        'You have reached $_selectedNumber steps! Next goal: $nextGoal steps!',
        platformChannelSpecifics,
      );
      print(
          '$_selectedNumber steps reached! Alerting user... Next goal: $nextGoal');

      // Automatically select the next goal
      setState(() {
        _selectedNumber = nextGoal;
      });

      _notificationShown = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.hintColor,
        title: Text(
          'Step Counter',
          style: TextStyle(color: theme.primaryColor),
        ),
        iconTheme: IconThemeData(
          color: theme.primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'lib/assets/Animation - 1712341175314.json',
                width: 400,
                height: 400,
              ),
              Text(
                'Step Count:',
                style: TextStyle(fontSize: 20, color: theme.hintColor),
              ),
              Text(
                '$_stepCount',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
              SizedBox(height: 20),
              _motionDetected
                  ? Text(
                      'Motion Detected!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    )
                  : Text(
                      'At rest',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
              SizedBox(height: 20),
              Text(
                'Select Step Goal:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(8), // Add padding for spacing
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.hintColor, // Set border color
                    width: 2, // Set border width
                  ),
                  borderRadius: BorderRadius.circular(10), // Set border radius
                ),
                child: Container(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final number = (index + 1) * 100;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedNumber = number;
                          });
                        },
                        child: Container(
                          width: 60,
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: _selectedNumber == number
                                ? Colors.purple
                                : theme.hintColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$number',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4,
                margin: EdgeInsets.all(8),
                color: theme.hintColor, // Choose your desired color
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Progress',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Here you can view your step count progress over time.',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.primaryColor,
                        ),
                      ),
                      // Add additional content here if needed
                      SizedBox(height: 10),
                      Container(
                        height: 200, // Adjust the height as needed
                        child: _buildLineChart(_stepData),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildLineChart(List<TimeSeriesStepCount> stepData) {
  List<charts.Series<TimeSeriesStepCount, DateTime>> series = [
    charts.Series(
      id: "StepCount",
      data: stepData,
      domainFn: (TimeSeriesStepCount series, _) => series.time,
      measureFn: (TimeSeriesStepCount series, _) => series.stepCount,
    )
  ];

  return charts.TimeSeriesChart(
    series,
    animate: true,
    primaryMeasureAxis: charts.NumericAxisSpec(
      tickProviderSpec:
          charts.BasicNumericTickProviderSpec(desiredTickCount: 5),
      renderSpec: charts.GridlineRendererSpec(
        labelStyle: charts.TextStyleSpec(
          color: charts.MaterialPalette.white, // Set number color
        ),
        lineStyle: charts.LineStyleSpec(
          color: charts.MaterialPalette.white, // Set line color
        ),
      ),
    ),
    domainAxis: charts.DateTimeAxisSpec(
      tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
        day: charts.TimeFormatterSpec(
          format: 'MM/dd', // Format the date as per your requirement
          transitionFormat: 'MM/dd', // Same as format
        ),
      ),
      renderSpec: charts.SmallTickRendererSpec(
        labelStyle: charts.TextStyleSpec(
          color: charts.MaterialPalette.white, // Set number color
        ),
        lineStyle: charts.LineStyleSpec(
          color: charts.MaterialPalette.white, // Set line color
        ),
      ),
    ),
  );
}

class TimeSeriesStepCount {
  final DateTime time;
  final int stepCount;

  TimeSeriesStepCount(this.time, this.stepCount);
}
