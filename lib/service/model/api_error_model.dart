import 'field_error_response.dart';

class ApiError {
  final int? httpCode;
  final String? message;
  final String? internalCode;
  final List<FieldErrorResponse>? errors;

  ApiError({
    this.errors,
    this.httpCode,
    this.internalCode,
    this.message,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      errors: json['errors'],
      httpCode: json['httpCode'],
      internalCode: json['internalCode'],
      message: json['message'],
    );
  }
}
