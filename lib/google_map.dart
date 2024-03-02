import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late double _zoomLevel;
  late Location _location;
  LocationData? _currentLocation;

  @override
  void initState() {
    super.initState();
    _zoomLevel = 5;
    _location = Location();
  }

  Future<LocationData?> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await _location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationData?>(
      future: _getCurrentLocation(),
      builder: (BuildContext context, AsyncSnapshot<LocationData?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          _currentLocation = snapshot.data;
          return GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                _zoomLevel = _zoomLevel - details.scale / 10;
                if (_zoomLevel < 1) {
                  _zoomLevel = 1;
                }
                if (_zoomLevel > 18) {
                  _zoomLevel = 18;
                }
              });
            },
            child: SfMaps(
              layers: [
                MapTileLayer(
                  initialFocalLatLng: MapLatLng(
                      _currentLocation!.latitude!, _currentLocation!.longitude!),
                  initialZoomLevel: _zoomLevel.toInt(),
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  markerBuilder: (BuildContext context, int index) {
                    return MapMarker(
                      latitude: _currentLocation!.latitude!,
                      longitude: _currentLocation!.longitude!,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red[800],
                      ),
                      size: Size(20, 20),
                    );
                  },
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Center(child: Text('Unable to fetch location'));
        }
      },
    );
  }
}
