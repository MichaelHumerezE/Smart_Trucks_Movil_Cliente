import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:smart_trucks_v2/constant.dart';
import 'package:smart_trucks_v2/services/ruta_service.dart';
import 'package:smart_trucks_v2/services/alarma_service.dart';
import 'package:smart_trucks_v2/services/user_service.dart';
import 'package:flutter/material.dart';

import '../models/api_response.dart';
import '../screens/login.dart';

import 'package:location/location.dart';

class alarmas extends StatefulWidget {
  //const alarmas({Key? key}) : super(key: key);
  const alarmas({super.key});
  @override
  State<alarmas> createState() => _alarmasState();
}

class _alarmasState extends State<alarmas> {
  bool loading = false;
  // Variables para el input y el select
  String selectedValue = '1';
  TextEditingController inputController = TextEditingController();

  List<dynamic> rutas = [];
  List<dynamic> alarmas = [];
  Location location = Location();

  // Función para mostrar el modal
  void _showAddAlarmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  title: Text('Agregar Alarma'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: inputController,
                        decoration: InputDecoration(
                            labelText: 'Ingrese el radio desde su ubicación'),
                      ),
                      SizedBox(height: 20),
                      DropdownButton<String>(
                        value: selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                        },
                        items:
                            rutas.map<DropdownMenuItem<String>>((dynamic ruta) {
                          return DropdownMenuItem<String>(
                            value: ruta['id'].toString(),
                            child: FittedBox(
                              fit: BoxFit
                                  .scaleDown, // Ajusta el contenido para que quepa en el espacio disponible
                              child: Text(ruta['nombre'] +
                                  ' - ' +
                                  ruta['distrito'] +
                                  ' - ' +
                                  ruta['zona']),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el modal
                      },
                      child: Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Cierra el modal después de guardar la alarma
                          Navigator.of(context).pop();
                          // Aquí puedes manejar la lógica para guardar la alarma
                          // Puedes acceder a los valores ingresados en inputController.text y selectedValue
                          // Agrega tu lógica de guardado aquí
                          _createAlarma(int.parse(inputController.text),
                              int.parse(selectedValue));
                        });
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ));
      },
    );
  }

  void _createAlarma(int radio, int id_ruta) async {
    try {
      Position position = await determinarPosition();
      double latitude = position.latitude!;
      double longitude = position.longitude!;

      ApiResponse response = await createAlarma(
          radio, latitude.toString(), longitude.toString(), id_ruta);

      if (response.error == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Alarma Creada.')));
      } else if (response.error == unauthorized) {
        logout().then((value) => {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false)
            });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${response.error}')));
        setState(() {
          loading = !loading;
        });
      }
    } catch (e) {
      // Maneja posibles errores al obtener la ubicación
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${e}')));
      setState(() {
        loading = !loading;
      });
    }
  }

  Future<Position> determinarPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("error");
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void _getRutas() async {
    ApiResponse response = await getRutas();
    if (response.error == null) {
      setState(() {
        rutas = response.data as List<dynamic>;
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

  void _getAlarmas() async {
    ApiResponse response = await getAlarmas();
    if (response.error == null) {
      setState(() {
        alarmas = response.data as List<dynamic>;
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

  @override
  void initState() {
    super.initState();
    _getAlarmas();
    _getRutas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              label: const Text('Agregar Alarma'),
              backgroundColor: Colors.grey,
              onPressed: () {
                _showAddAlarmDialog();
              },
            ),
          ],
        ),
        appBar: AppBar(
          title: Text("Alarmas"),
          backgroundColor: Colors.indigoAccent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20.0),
          children: _cards(),
        ));
  }

  List<Widget> _cards() {
    List<Widget> alarmasWidget = [];
    int i = 0;
    for (dynamic alarma in alarmas) {
      i += 1;
      alarmasWidget.add(Container(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.alarm,
                color: Colors.blue,
              ),
              title: Text('Alarma #' + (alarmas.length - i + 1).toString()),
              subtitle: Text('Ruta: ' +
                  alarma['ruta'] +
                  '\n' +
                  'Coordenadas: LatLng(' +
                  alarma['latitud'].toString() +
                  ', ' +
                  alarma['longitud'].toString() +
                  ')' +
                  '\n' +
                  'Radio: ' +
                  alarma['radio'].toString() +
                  ' Mts' +
                  '\n' +
                  'Estado: ' +
                  (alarma['estado'] == 1 ? "Activo" : "Terminado")),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(onPressed: () {}, child: const Text('Editar')),
                TextButton(onPressed: () {}, child: const Text('Borrar'))
              ],
            )
          ],
        ),
      ));
    }
    return alarmasWidget;
  }
}
