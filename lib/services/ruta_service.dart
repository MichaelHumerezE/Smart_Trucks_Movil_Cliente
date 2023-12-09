import 'dart:convert';

import 'package:smart_trucks_v2/constant.dart';
import 'package:smart_trucks_v2/models/api_response.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

Future<ApiResponse> getRutas() async {
  ApiResponse apiResponse = ApiResponse();
    try {
      String token = await getToken();
      final response = await http.get(Uri.parse(getRutasURL), headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });

      switch (response.statusCode) {
        case 200:
          apiResponse.data = jsonDecode(response.body)['rutas'];
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

Future<ApiResponse> getRuta(int id_ruta) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse('$getRutaURL/$id_ruta'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    switch(response.statusCode){
      case 200:
        apiResponse.data = jsonDecode(response.body)['ruta'];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = unauthorized;
        break;
      default:
        apiResponse.error = somethingWentWrong;
        break;
    }
  }
  catch (e){
    apiResponse.error = serverError;
  }
  return apiResponse;
}

Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}