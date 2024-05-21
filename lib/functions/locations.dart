import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
