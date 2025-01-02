import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:sensor/components/consts.dart';
import 'package:sensor/main.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final LatLng _kigaliCenter = const LatLng(-1.9441, 30.0619);
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static const LatLng _pApplePark = LatLng(37.3346, -122.0090);
  LatLng? _currentP;
  Map<PolylineId, Polyline> polylines = {};
  final Map<PolygonId, Polygon> _polygons = {};
  StreamSubscription<LocationData>? _locationSubscription;
  bool _notificationSentOutSide = false;
  bool _notificationSentInSide = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _createGeofence();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _initializeMap() async {
    await getLocationUpdates();
    final coordinates = await getPolylinePoints();
    generatePolyLineFromPoints(coordinates);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.hintColor,
        title: Text(
          'Your Location',
          style: TextStyle(color: theme.primaryColor),
        ),
        iconTheme: IconThemeData(
          color: theme.primaryColor,
        ),
      ),
      body: _currentP == null
          ? const Center(child: Text("Loading..."))
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: _kigaliCenter,
                zoom: 13,
              ),
              polygons: Set<Polygon>.of(_polygons.values),
              markers: {
                Marker(
                  markerId: const MarkerId("_currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentP!,
                ),
                const Marker(
                  markerId: MarkerId("_sourceLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pGooglePlex,
                ),
                const Marker(
                  markerId: MarkerId("_destionationLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pApplePark,
                ),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  // Trigger notification for inside geofence
  void _triggerInSideNotification() async {
    if (!_notificationSentInSide) {
      await _sendNotification(
        'Inside Geographical Boundaries of Kigali',
      );
      _notificationSentInSide = true;
      _notificationSentOutSide = false;
    }
  }

  // Trigger notification for outside geofence
  void _triggerOutSideNotification() async {
    if (!_notificationSentOutSide) {
      await _sendNotification(
        'Outside Geographical Boundaries of Kigali',
      );
      _notificationSentOutSide = true;
      _notificationSentInSide = false;
    }
  }

  Future<void> _sendNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Map_channel',
      'Map Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Hello!',
      message,
      platformChannelSpecifics,
    );
  }

  // Create geofence with boundary points
  void _createGeofence() {
    List<LatLng> kigaliBoundaries = [
      const LatLng(-1.9740, 30.0274), // Northwest corner
      const LatLng(-1.9740, 30.1300), // Northeast corner
      const LatLng(-1.8980, 30.1300), // Southeast corner
      const LatLng(-1.8980, 30.0274), // Southwest corner
    ];

    PolygonId polygonId = const PolygonId('kigali');
    Polygon polygon = Polygon(
      polygonId: polygonId,
      points: kigaliBoundaries,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.3),
    );
    setState(() {
      _polygons[polygonId] = polygon;
    });

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationSubscription = _locationController.onLocationChanged.listen(
      (LocationData currentLocation) {
        bool insideGeofence = _isLocationInsideGeofence(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        if (insideGeofence) {
          _triggerInSideNotification();
        } else {
          _triggerOutSideNotification();
        }
      },
    );
  }

  // Geofence check
  bool _isLocationInsideGeofence(double latitude, double longitude) {
    List<LatLng> kigaliBoundaries = [
      const LatLng(-1.9740, 30.0274),
      const LatLng(-1.9740, 30.1300),
      const LatLng(-1.8980, 30.1300),
      const LatLng(-1.8980, 30.0274),
    ];

    bool isInside = false;
    int i, j = kigaliBoundaries.length - 1;
    for (i = 0; i < kigaliBoundaries.length; i++) {
      if ((kigaliBoundaries[i].latitude < latitude &&
              kigaliBoundaries[j].latitude >= latitude) ||
          (kigaliBoundaries[j].latitude < latitude &&
              kigaliBoundaries[i].latitude >= latitude)) {
        if (kigaliBoundaries[i].longitude +
                (latitude - kigaliBoundaries[i].latitude) /
                    (kigaliBoundaries[j].latitude -
                        kigaliBoundaries[i].latitude) *
                    (kigaliBoundaries[j].longitude -
                        kigaliBoundaries[i].longitude) <
            longitude) {
          isInside = !isInside;
        }
      }
      j = i;
    }
    return isInside;
  }

  // Fetch live location and update map
  Future<void> getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted =
        await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationSubscription = _locationController.onLocationChanged.listen(
      (LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          LatLng newLocation =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);

          updateMarkerAndCircle(newLocation);
          addLocationToPolyline(newLocation);
          _cameraToPosition(newLocation);
        }
      },
    );
  }

  void updateMarkerAndCircle(LatLng newLocation) {
    setState(() {
      _currentP = newLocation;
    });
  }

  void addLocationToPolyline(LatLng newLocation) {
    setState(() {
      if (polylines.containsKey(const PolylineId("path"))) {
        final polyline = polylines[const PolylineId("path")]!;
        final updatedPoints = List<LatLng>.from(polyline.points)
          ..add(newLocation);
        polylines[const PolylineId("path")] =
            polyline.copyWith(pointsParam: updatedPoints);
      } else {
        polylines[const PolylineId("path")] = Polyline(
          polylineId: const PolylineId("path"),
          color: Colors.blue,
          points: [newLocation],
          width: 5,
        );
      }
    });
  }

  // Get Polyline Points
  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineRequest polylineRequest = PolylineRequest(
      origin: PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
      destination: PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
      mode: TravelMode.driving, // Add the travel mode here
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: polylineRequest, // Use named argument
      googleApiKey: GOOGLE_MAPS_API_KEY, // Add your API Key
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print('Failed to fetch polyline points: ${result.errorMessage}');
    }
    return polylineCoordinates;
  }

  // Move Camera
  Future<void> _cameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 17.0,
        ),
      ),
    );
  }

  // Generate Polylines on the map
  void generatePolyLineFromPoints(List<LatLng> points) {
    PolylineId id = const PolylineId("path");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: points,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
}
