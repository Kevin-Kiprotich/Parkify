import "dart:async";

import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:parkify/Components/layers_modal.dart";
import "package:parkify/functions/locations.dart";
import "package:geolocator/geolocator.dart";

class ParkingMap extends StatefulWidget {
  const ParkingMap({super.key});

  @override
  State<ParkingMap> createState() => _ParkingMapState();
}

class _ParkingMapState extends State<ParkingMap> {
  // initialize location streaming service variables
  final StreamController<Position> _locStream = StreamController();
  late StreamSubscription<Position> locationSubscription;
  final LocationSettings lSettings = const LocationSettings(
      distanceFilter: 1, accuracy: LocationAccuracy.high);

  // initialize map variables
  late GoogleMapController _mapController;
  bool _mapCreated = false;
  double _currentZoom = 0;
  Position? _currentPosition;
  LatLng _center = const LatLng(0, 0);
  double _positionAccuracy = 0;
  MapType _mapType = MapType.normal;

  // this initializes the map controller
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapCreated = true;
    });
  }

  // This hides or shows the default location marker
  void _toggleUserLocationMarker() {
    setState(() {
      _showMyLocationMarker
          ? _showMyLocationMarker = false
          : _showMyLocationMarker = true;
    });
  }

  // this starts the geolocation service
  startLocation() {
    final positionStream =
        Geolocator.getPositionStream(locationSettings: lSettings)
            .handleError((error) {});
    locationSubscription = positionStream.listen((Position position) {
      _locStream.sink.add(position);
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _positionAccuracy = position.accuracy;
          _center = LatLng(_currentPosition?.latitude ?? 0,
              _currentPosition?.longitude ?? 0);
          // print(_center);
          if (_mapCreated) {
            _mapController.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(_currentPosition?.latitude ?? 0,
                    _currentPosition?.longitude ?? 0),
              ),
            );
          }
        });
      }
    });
  }

  //this changes the map type/basemap
  void _changeMapType(String type) {
    setState(() {
      if (type == 'def') {
        _mapType = MapType.normal;
      } else if (type == 'sat') {
        _mapType = MapType.hybrid;
      } else if (type == 'ter') {
        _mapType = MapType.terrain;
      }
    });
  }

  void _showLayersModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return LayersModal(
          changeLayersFunction: _changeMapType,
          toggleLocationMarker: _toggleUserLocationMarker,
          locationMarker: _showMyLocationMarker,
          activeMapType: _mapType,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getLocationpermission();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
