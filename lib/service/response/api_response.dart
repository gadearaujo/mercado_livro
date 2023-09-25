import 'package:mercado_livro/service/model/book_model.dart';

import '../model/api_error_model.dart';
import '../model/book_response.dart';
import '../model/customer_login_model.dart';
import '../model/customer_model.dart';

class ApiResponse {
  BookModel? _book;
  BookResponse? _bookResponse;
  CustomerModel? _customer;
  List<Map<String, dynamic>>? _customerLogin;

  ApiError? apiErrorT;

  BookModel? get book => _book!;
  set book(BookModel? book) => _book = book;

  BookResponse? get bookResponse => _bookResponse!;
  set bookResponse(BookResponse? bookResponse) => _bookResponse = bookResponse;

  List<Map<String, dynamic>>? get customerLogin => _customerLogin!;
  set customerLogin(List<Map<String, dynamic>>? customerLogin) =>
      _customerLogin = customerLogin;

  CustomerModel? get customer => _customer!;
  set customer(CustomerModel? customer) => _customer = customer;

  ApiError? get apiError => apiErrorT;
  set apiError(ApiError? error) => apiErrorT = error;
}
