import 'dart:convert';

import 'package:smart_trucks_v2/constant.dart';
import 'package:smart_trucks_v2/models/api_response.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

Future<ApiResponse> createAlarma(
    int radio, String latitud, String longitud, int id_ruta) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(Uri.parse(createAlarmaURL), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'radio': radio.toString(),
      'latitud': latitud,
      'longitud': longitud,
      'id_ruta': id_ruta.toString(),
    });

    // here if the image is null we just send the body, if not null we send the image too

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body);
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  } catch (e) {
    apiResponse.error = serverError;
  }
  return apiResponse;
}

Future<ApiResponse> getAlarmas() async {
  ApiResponse apiResponse = ApiResponse();
    try {
      String token = await getToken();
      final response = await http.get(Uri.parse(getAlarmaURL), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      switch (response.statusCode) {
        case 200:
          apiResponse.data = jsonDecode(response.body)['alarmas'];
          break;
        case 401:
          apiResponse.error = unauthorized;
          break;
        default:
          apiResponse.error = somethingWentWrong;
          break;
      }
    } catch (e) {
      apiResponse.error = serverError;
    }

    return apiResponse;
}

Future<ApiResponse> getLastAlarma() async {
  ApiResponse apiResponse = ApiResponse();
    try {
      String token = await getToken();
      final response = await http.get(Uri.parse(getLastAlarmaURL), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      switch (response.statusCode) {
        case 200:
          apiResponse.data = jsonDecode(response.body)['alarma'];
          break;
        case 401:
          apiResponse.error = unauthorized;
          break;
        default:
          apiResponse.error = somethingWentWrong;
          break;
      }
    } catch (e) {
      apiResponse.error = serverError;
    }

    return apiResponse;
}

Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}