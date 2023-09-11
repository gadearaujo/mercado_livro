import 'package:mercado_livro/service/model/book_model.dart';

import '../model/api_error_model.dart';
import '../model/customer_model.dart';

class ApiResponse {
  BookModel? _book;
  CustomerModel? _customer;

  ApiError? apiErrorT;

  BookModel? get book => _book!;
  set book(BookModel? book) => _book = book;

  CustomerModel? get customer => _customer!;
  set customer(CustomerModel? customer) => _customer = customer;

  ApiError? get apiError => apiErrorT;
  set apiError(ApiError? error) => apiErrorT = error;
}
