import 'package:mercado_livro/service/model/book_model.dart';

class ApiResponse {
  BookModel? _book;

  BookModel? get book => _book!;
  set book(BookModel? book) => _book = book;
}
