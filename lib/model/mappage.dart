import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final LatLng location;
  const MapPage({super.key, required this.location});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final currentPos = CameraPosition(
      bearing: 0.0,  //compass direction – 90 degree orients east up
      target: widget.location,
      tilt: 60.0,   //title angle – 60 degree looks ahead towards the horizon
      zoom: 17,  //zoom level – a middle value of 11 shows city-level
    );
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        myLocationEnabled: true,
        initialCameraPosition: currentPos,
        markers: {Marker(markerId: const MarkerId('pickup'), position: widget.location)},
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
} //_MapPageState 