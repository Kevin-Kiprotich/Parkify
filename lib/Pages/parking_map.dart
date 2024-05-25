import "dart:async";
import 'dart:math' as math;

import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:parkify/Components/layers_modal.dart";
import "package:parkify/Components/map_icon_button.dart";
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
  LatLng _currentCenter = const LatLng(0, 0);
  double _positionAccuracy = 0;
  double _currentBearing = 0;
  MapType _mapType = MapType.normal;
  bool _showMyLocationMarker = true;
  bool _isDragging = false;

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
          print(_currentPosition);
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

  //this shows the layer switch settings
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
    startLocation();
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
                myLocationEnabled: true,
                onCameraMove: (CameraPosition position) {
                  setState(() {
                    _currentZoom = position.zoom;
                    _currentCenter = position.target;
                    _currentBearing = position.bearing;
                  });
                },
                markers: {
                  if (_showMyLocationMarker)
                    Marker(
                      markerId: const MarkerId('User position'),
                      position: _center,
                      draggable: true,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                      onDrag: (latlng) {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onDragStart: (latlng) {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onDragEnd: (latlng) {
                        setState(() {
                          _center = latlng;
                        });
                      },
                    ),
                }),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 45,
                margin: const EdgeInsets.fromLTRB(0, 60, 10, 0),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(10),
                // ),
                child: Column(
                  children: <Widget>[
                    MapIconButton(
                      // position: Pos.top,
                      onPressed: () {
                        zoomIn(_mapController, _currentZoom, _currentCenter);
                      },
                      icon: const Icon(Icons.add, size: 22),
                    ),
                    const SizedBox(height: 10),
                    MapIconButton(
                      position: Pos.center,
                      onPressed: () {
                        zoomOut(_mapController, _currentZoom, _currentCenter);
                      },
                      icon: const Icon(Icons.remove, size: 22),
                    ),
                    const SizedBox(height: 10),
                    MapIconButton(
                      // position: Pos.center,
                      onPressed: () {
                        _mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _currentCenter,
                              bearing: 0,
                              zoom: _currentZoom,
                            ),
                          ),
                        );
                      },
                      icon: Transform.rotate(
                          alignment: Alignment.center,
                          angle: _currentBearing * (math.pi / 180),
                          child: Image.asset('assets/Images/NorthArrow.png')),
                    ),
                    const SizedBox(height: 10),
                    MapIconButton(
                      // position: Pos.bottom,
                      onPressed: _showLayersModal,
                      icon: const Icon(
                        Icons.layers_rounded,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
