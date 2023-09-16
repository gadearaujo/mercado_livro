import 'field_error_response.dart';

class ErrorResponse {
  int? httpCode;
  String? message;
  String? internalCode;
  List<FieldErrorResponse> errors = [];
}
