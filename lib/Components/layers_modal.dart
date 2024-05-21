import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkify/Components/basemap_button.dart';

class LayersModal extends StatefulWidget {
  const LayersModal({
    super.key,
    required this.changeLayersFunction,
    required this.toggleLocationMarker,
    required this.locationMarker,
    required this.activeMapType,
  });
  final Function(String) changeLayersFunction;
  final Function() toggleLocationMarker;
  final bool locationMarker;
  final MapType activeMapType;

  @override
  State<LayersModal> createState() => _LayersModalState();
}

class _LayersModalState extends State<LayersModal> {
  bool isMapTypeDefault = true;
  bool isMapTypeSatellite = false;
  bool isMapTypeTerrain = false;
  IconData _toggleIconData = FontAwesomeIcons.eye;

  void _toggleEyeIcon() {
    setState(
      () {
        if (_toggleIconData == FontAwesomeIcons.eye) {
          _toggleIconData = FontAwesomeIcons.eyeSlash;
        } else if (_toggleIconData == FontAwesomeIcons.eyeSlash) {
          _toggleIconData = FontAwesomeIcons.eye;
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    widget.locationMarker
        ? _toggleIconData = FontAwesomeIcons.eye
        : _toggleIconData = FontAwesomeIcons.eyeSlash;

    if (widget.activeMapType == MapType.normal) {
      isMapTypeDefault = true;
      isMapTypeSatellite = false;
      isMapTypeTerrain = false;
    } else if (widget.activeMapType == MapType.satellite) {
      isMapTypeDefault = false;
      isMapTypeSatellite = true;
      isMapTypeTerrain = false;
    } else if (widget.activeMapType == MapType.terrain) {
      isMapTypeDefault = false;
      isMapTypeSatellite = false;
      isMapTypeTerrain = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Layers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  iconSize: 24,
                  color: Colors.grey,
                  icon: const Icon(Icons.cancel),
                ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BasemapButton(
                    activeColor: Theme.of(context).primaryColor,
                    isActive: isMapTypeDefault,
                    mapType: 'Default',
                    onPressed: () {
                      widget.changeLayersFunction('def');
                      setState(() {
                        isMapTypeDefault = true;
                        isMapTypeSatellite = false;
                        isMapTypeTerrain = false;
                      });
                    },
                    image: Image.asset('assets/Images/default.png'),
                  ),
                  BasemapButton(
                    activeColor: Theme.of(context).primaryColor,
                    isActive: isMapTypeSatellite,
                    mapType: 'Satellite',
                    onPressed: () {
                      widget.changeLayersFunction('sat');
                      setState(() {
                        isMapTypeDefault = false;
                        isMapTypeSatellite = true;
                        isMapTypeTerrain = false;
                      });
                    },
                    image: Image.asset('assets/Images/satellite.png'),
                  ),
                  BasemapButton(
                    activeColor: Theme.of(context).primaryColor,
                    isActive: isMapTypeTerrain,
                    mapType: 'Terrain',
                    onPressed: () {
                      widget.changeLayersFunction('ter');
                      setState(() {
                        isMapTypeDefault = false;
                        isMapTypeSatellite = false;
                        isMapTypeTerrain = true;
                      });
                    },
                    image: Image.asset('assets/Images/terrain.png'),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Map Layers',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.locationDot,
                  size: 24,
                  color: Colors.red[600],
                ),
                const SizedBox(
                  width: 16,
                ),
                const Expanded(
                  child: Text(
                    'Your Location',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _toggleEyeIcon();
                    widget.toggleLocationMarker();
                  },
                  icon: Icon(
                    _toggleIconData,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
