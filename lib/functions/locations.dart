import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin, sin, atan2, pi;

getLocationpermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.denied) {
    return Future.error('Location permissions are denied');
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
}

void zoomIn(GoogleMapController mapController, double currentZoom,
    LatLng currentCenter) {
  // _mapController.animateCamera(CameraUpdate.zoomIn());
  mapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentCenter,
        bearing: 0,
        zoom: currentZoom + 1,
      ),
    ),
  );
}

void zoomOut(GoogleMapController mapController, double currentZoom,
    LatLng currentCenter) {
  // _mapController.animateCamera(CameraUpdate.zoomOut());
  mapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentCenter,
        bearing: 0,
        zoom: currentZoom - 1,
      ),
    ),
  );
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  int intersectCount = 0;
  for (int i = 0; i < polygon.length; i++) {
    LatLng vertex1 = polygon[i];
    LatLng vertex2 = polygon[(i + 1) % polygon.length];

    // Check if the point is on a vertex
    if ((vertex1.latitude == point.latitude &&
            vertex1.longitude == point.longitude) ||
        (vertex2.latitude == point.latitude &&
            vertex2.longitude == point.longitude)) {
      return true;
    }

    if ((point.longitude > vertex1.longitude) !=
        (point.longitude > vertex2.longitude)) {
      double atX = (point.longitude - vertex1.longitude) *
              (vertex2.latitude - vertex1.latitude) /
              (vertex2.longitude - vertex1.longitude) +
          vertex1.latitude;
      if (point.latitude < atX) {
        intersectCount++;
      }
    }
  }
  return intersectCount % 2 != 0;
}

Duration estimateTravelTime(double distance, double averageSpeed) {
  // distance in kilometers, averageSpeed in kilometers per hour
  final timeInHours = distance / averageSpeed;
  final timeInMinutes = timeInHours * 3600;
  return Duration(seconds: timeInMinutes.round());
}

// Function to calculate distance between two LatLng points using Haversine formula
double calculateDistanceFromList(LatLng point1, LatLng point2) {
  const earthRadiusKm = 6371.0;

  double dLat = _degreesToRadians(point2.latitude - point1.latitude);
  double dLon = _degreesToRadians(point2.longitude - point1.longitude);

  double lat1 = _degreesToRadians(point1.latitude);
  double lat2 = _degreesToRadians(point2.latitude);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

// Function to convert degrees to radians
double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}
