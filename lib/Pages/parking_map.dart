import "dart:async";
import "dart:convert";
import "dart:math" show cos, sqrt, asin, pi;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:flutter_tts/flutter_tts.dart';
import "package:flutter_polyline_points/flutter_polyline_points.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:parkify/Components/layers_modal.dart";
import "package:parkify/Components/map_icon_button.dart";
import "package:parkify/Components/park_details_modal.dart";
import "package:parkify/data_models/constants.dart";
import "package:parkify/data_models/geojson_model.dart";
import "package:parkify/functions/locations.dart";
import "package:geolocator/geolocator.dart";
import "package:url_launcher/url_launcher.dart";

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
  FlutterTts tts = FlutterTts();
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
  List<Polygon> _polys = [];
  List<LatLng> _currentPolygon = [];
  String _currentParkName = "";
  LatLng? _polygoncenter;
  Marker? _polygonCenterMarker;
  Map<PolylineId, Polyline> _polylines = {};
  bool _isNavigating = false;

  //create polyline
  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId('lines');
    Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        color: Colors.blue,
        width: 4);
    setState(() {
      _polylines[id] = polyline;
    });
  }

  //function to create a routes between user and destinations
  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: GOOGLE_MAPS_API_KEY,
      request: PolylineRequest(
        origin: PointLatLng(_center.latitude, _center.longitude),
        destination:
            PointLatLng(_polygoncenter!.latitude, _polygoncenter!.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  // find the center of a selected polygon
  LatLng findCentroid(List<LatLng> vertices) {
    double area = 0.0;
    double centroidLat = 0.0;
    double centroidLng = 0.0;

    for (int i = 0; i < vertices.length; i++) {
      int nextIndex = (i + 1) % vertices.length;
      double lat0 = vertices[i].latitude;
      double lng0 = vertices[i].longitude;
      double lat1 = vertices[nextIndex].latitude;
      double lng1 = vertices[nextIndex].longitude;

      double a = lat0 * lng1 - lat1 * lng0;
      area += a;
      centroidLat += (lat0 + lat1) * a;
      centroidLng += (lng0 + lng1) * a;
    }

    area *= 0.5;
    centroidLat /= (6 * area);
    centroidLng /= (6 * area);

    return LatLng(centroidLat, centroidLng);
  }

  // this initializes the map controller
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapCreated = true;
    });
    startLocation();
  }

  // This hides or shows the default location marker
  void _toggleUserLocationMarker() {
    setState(() {
      _showMyLocationMarker
          ? _showMyLocationMarker = false
          : _showMyLocationMarker = true;
    });
  }

  void fetchPolygons() async {
    const path = "assets/data/parks.json";
    final file = await rootBundle.loadString(path);
    var jsonData = json.decode(file);

    var geojson = GeoJsonModel.fromJson(jsonData);

    setState(() {
      _polys = geojson.features.map<Polygon>((item) {
        // print(item['geometry']['coordinates']);
        return Polygon(
          consumeTapEvents: true,
          polygonId: PolygonId(item['properties']['Name']),
          fillColor: int.parse(item['properties']["available_spaces"]) > 0
              ? Colors.green
              : Colors.red,
          points: (item['geometry']['coordinates'][0] as List)
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList(),
          onTap: () {
            final vertices = (item['geometry']['coordinates'][0] as List)
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList();
            setState(() {
              if (_isNavigating) {
                // _currentPolygon = vertices;
                // _currentParkName = item['properties']['Name'];
              } else {
                _currentPolygon = vertices;
                _currentParkName = item['properties']['Name'];
                _polygoncenter = findCentroid(vertices);
                print(_polygoncenter);
                _polygonCenterMarker = Marker(
                  markerId: const MarkerId('polygonCenter'),
                  position: _polygoncenter!,
                  icon: int.parse(item['properties']["available_spaces"]) > 0
                      ? BitmapDescriptor.defaultMarker
                      : BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                );
              }
            });
            showPolygonModal(
                item['properties']['Name'],
                int.parse(item['properties']['capacity']),
                int.parse(item['properties']['available_spaces']));
          },
          strokeWidth: 1,
        );
      }).toList();
    });
  }

  onNavigationCancelled() {
    setState(() {
      _polygonCenterMarker = null;
      _polygoncenter = null;
    });
  }

  onNavigate() async {
    await getPolylinePoints()
        .then((coordinates) => {generatePolylineFromPoints(coordinates)});
    setState(() {
      _isNavigating = true;
    });
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
          // print(_currentPosition);
          // print(_center);
          if (_mapCreated) {
            _mapController.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(_currentPosition?.latitude ?? 0,
                    _currentPosition?.longitude ?? 0),
              ),
            );
          }
          if (_isNavigating &&
              _polygoncenter != null &&
              _currentPolygon.isNotEmpty) {
            if (isPointInPolygon(_center, _currentPolygon)) {
              tts.speak('You are inside $_currentParkName');
            }
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

  void showPolygonModal(name, capacity, availableSpaces) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return SizedBox(
            height: 240,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: ParkingModal(
                name: name,
                capacity: capacity,
                availableSpaces: availableSpaces,
                onNavigate: onNavigate,
                onNavigationCancelled: onNavigationCancelled,
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getLocationpermission();
    // startLocation();
    fetchPolygons();
    tts.setLanguage('en-US');
    tts.setVolume(1.0);
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
                zoom: 17,
              ),
              myLocationEnabled: _showMyLocationMarker,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: _mapType,
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
                        BitmapDescriptor.hueBlue),
                  ),
                if (_polygoncenter != null && _polygonCenterMarker != null)
                  _polygonCenterMarker!,
              },
              polygons: _polys.isNotEmpty ? Set<Polygon>.of(_polys) : {},
              polylines: Set<Polyline>.of(_polylines.values),
            ),
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
                          angle: _currentBearing * (pi / 180),
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
            if (_isNavigating)
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () async {
                    await tts.speak('Starting to navigate');
                    await launchUrl(Uri.parse(
                        'google.navigation:q=${_polygoncenter!.latitude}, ${_polygoncenter!.longitude}&key=$GOOGLE_MAPS_API_KEY'));
                  },
                  child: Container(
                    height: 64,
                    width: 64,
                    margin: const EdgeInsets.fromLTRB(0, 0, 16, 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Center(
                      child: Icon(Icons.navigation_outlined,
                          size: 32, color: Colors.white),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
