import 'dart:ffi';
import 'dart:math';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_trucks_v2/constant.dart';
import 'package:smart_trucks_v2/services/alarma_service.dart';
import 'package:smart_trucks_v2/services/notifications_service.dart';
import 'package:smart_trucks_v2/services/user_service.dart';

import '../models/api_response.dart';
import '../screens/login.dart';
import '../services/ruta_service.dart';

class mapC extends StatefulWidget {
  const mapC({Key? key}) : super(key: key);

  @override
  State<mapC> createState() => _mapCState();
}

class _mapCState extends State<mapC> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Marker> _alarmaMarker = {};
  final Map<PolylineId, Polyline> _polylines = {};
  bool loading = false;
  dynamic alarma;

  Set<Circle> _circle = {};

  bool notificacion = false;

  List<LatLng> points = [];
  dynamic ruta;
  List<dynamic> coordenadas = [];

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (context, setState) => Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  label: const Text('Mapa'),
                  backgroundColor: Colors.grey,
                  onPressed: () {},
                ),
              ],
            ),
            appBar: AppBar(
              title: Text("Marcar Puntos"),
              backgroundColor: Colors.indigoAccent,
              elevation: 0,
            ),
            body: Stack(
              children: [
                GoogleMap(
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-17.78629, -63.18117),
                    zoom: 12.4746,
                  ),
                  markers: _markers.union(_alarmaMarker),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  circles: _circle,
                  polylines: _polylines.values.toSet(),
                ),
              ],
            )));
  }

  @override
  void initState() {
    super.initState();
    iniciar();
  }

  Future<void> iniciar() async {
    await _getLastAlarma();
    await _getRuta();
    _getConductoresEnTiempoReal();
  }

  Future<void> _getLastAlarma() async {
    ApiResponse response = await getLastAlarma();
    if (response.error == null) {
      setState(() {
        alarma = response.data;
        _cargarMarkerYou(alarma);
        _centrar(alarma);
        _cargarCirculo(alarma);
        loading = false;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  Future<void> _getRuta() async {
    ApiResponse response = await getRuta(alarma['id_ruta']);
    if (response.error == null) {
      setState(() {
        ruta = response.data;
        coordenadas = jsonDecode(ruta['coordenadas']) as List<dynamic>;
        _cargarPoints(coordenadas);
        _cargarPolyline();
        print(coordenadas);
        loading = false;
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _getConductoresEnTiempoReal() async {
    await FirebaseFirestore.instance
        .collection("Conductor")
        .where("id_ruta", isEqualTo: alarma['id_ruta'])
        .snapshots()
        .listen((snapshot) async {
      _markers.clear();
      for (var doc in snapshot.docs) {

        final data = doc.data() as Map<String, dynamic>;
        double lat = double.parse(data['latitud'].toString());
        double lng = double.parse(data['longitud'].toString());

        final conductorMarker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: "Vehiculo - Camion",
          ),
        );
        setState(() {
          _markers.add(conductorMarker);
          if (passInPosition(alarma, LatLng(lat, lng)) && notificacion) {
            mostrarNotificacion();
            print(
                "enviar Notificación*********************************************************");
          }
        });
      }
    });
  }

  void _cargarCirculo(var alarma) {
    _circle.clear();
    _circle.add(
      Circle(
        circleId: CircleId(alarma['id'].toString()),
        center: LatLng(
            double.parse(alarma['latitud']), double.parse(alarma['longitud'])),
        radius: alarma['radio'].toDouble(), // Radio en metros
        fillColor: Colors.blue.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.blue,
      ),
    );
  }

  void _cargarMarkerYou(var alarma) {
    final marker = Marker(
      markerId: MarkerId(alarma['id'].toString()),
      position: LatLng(
          double.parse(alarma['latitud']), double.parse(alarma['longitud'])),
          infoWindow: InfoWindow(
            title: "Alarma",
          ),
    );
    _alarmaMarker.add(marker);
  }

  void _centrar(var alarma) {
    // Calcula la nueva posición de la cámara
    CameraPosition nuevaPosicion = CameraPosition(
      target: LatLng(double.parse(alarma['latitud']),
          double.parse(alarma['longitud'])), // Define las nuevas coordenadas
      zoom: 12.4746, // Opcional: cambia el nivel de zoom si es necesario
    );
    _mapController
        ?.animateCamera(CameraUpdate.newCameraPosition(nuevaPosicion));
  }

  bool passInPosition(var data, LatLng pos) {
    double long = double.parse(data['longitud']);
    double lat = double.parse(data['latitud']);
    LatLng punto = LatLng(lat, long);
    double dist = getDistanceBetweenPointsNew(
        punto.latitude, punto.longitude, pos.latitude, pos.longitude);
    print(dist);
    if (dist <= data['radio']) {
      notificacion = true;
      return true;
    }
    return false;
  }

  double getDistanceBetweenPointsNew(double latitude1, double longitude1,
      double latitude2, double longitude2) {
    double theta = longitude1 - longitude2;
    double distance = 60 *
        1.1515 *
        (180 / pi) *
        acos(sin(latitude1 * (pi / 180)) * sin(latitude2 * (pi / 180)) +
            cos(latitude1 * (pi / 180)) *
                cos(latitude2 * (pi / 180)) *
                cos(theta * (pi / 180)));
    return distance * 1.609344 * 1000;
  }

  void _cargarPoints(List<dynamic> coordenadas) {
    for (var i = 0; i < coordenadas.length; i++) {
      double lat = coordenadas[i]['lat'];
      double long = coordenadas[i]['lng'];
      LatLng point = LatLng(lat, long);
      points.add(point);
    }
  }

  void _cargarPolyline() {
    _polylines.clear();
    PolylineId polylineId = const PolylineId('id1');
    Polyline polyline = Polyline(
      polylineId: polylineId,
      points: points,
      color: Colors.blue,
      width: 3,
    );
    _polylines[polylineId] = polyline;
  }
}
