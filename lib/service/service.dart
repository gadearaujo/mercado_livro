import 'dart:io';

import 'package:mercado_livro/service/model/book_model.dart';
import 'package:mercado_livro/service/model/customer_model.dart';
import 'package:mercado_livro/service/response/api_response.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import 'model/api_error_model.dart';

class Service {
  Future<ApiResponse> getBooks(bool active) async {
    ApiResponse _apiResponse = ApiResponse();

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Headers': 'Access-Control-Allow-Origin, Accept'
      };
      var request = http.Request('GET',
          Uri.parse(active ? '$SERVER_URL/book/active' : '$SERVER_URL/book'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var responseRequest = await http.Response.fromStream(response);

      switch (response.statusCode) {
        case 200:
          _apiResponse.book =
              BookModel.fromJson(json.decode(responseRequest.body));

          break;
        case 401:
          if (_apiResponse != null) {
            // _apiResponse.apiError =
            //     ApiError.fromJson(json.decode(responseRequest.body));
          }
          break;
        case 400:
          // _apiResponse.apiError =
          //     ApiError.fromJson(json.decode(responseRequest.body));
          break;
        default:
          // _apiResponse.apiError =
          //     ApiError.fromJson(json.decode(responseRequest.body));
          break;
      }
    } on SocketException {
      // _apiResponse.apiError = ApiError(isError: true);
    }

    return _apiResponse;
  }

  Future<ApiResponse> registerCustomer(
      String? name, String? password, String? email) async {
    ApiResponse _apiResponse = ApiResponse();

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Headers': 'Access-Control-Allow-Origin, Accept'
      };
      http.Response r = await http.post(Uri.parse('$SERVER_URL/customer'),
          headers: headers,
          body: jsonEncode(<String, dynamic>{
            "name": name,
            "email": email,
            "password": password,
          }));

      switch (r.statusCode) {
        case 200:
          _apiResponse.customer = CustomerModel.fromJson(json.decode(r.body));
          break;
        case 401:
          _apiResponse.apiError = ApiError.fromJson(json.decode(r.body));
          break;
        case 400:
          if (_apiResponse != null) {
            _apiResponse.apiError = ApiError.fromJson(json.decode(r.body));
          }
          break;
        case 201:
          _apiResponse.customer = CustomerModel.fromJson(json.decode(r.body));
          break;
        default:
          if (r.body.isNotEmpty) {
            _apiResponse.apiError = ApiError.fromJson(json.decode(r.body));
          }
      }
    } on SocketException {
      _apiResponse.apiError = ApiError();
    }

    return _apiResponse;
  }
}
