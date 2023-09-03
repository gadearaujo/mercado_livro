import 'book_status.dart';
import 'customer_model.dart';

class BookModel {
  final int? id;

  final String? name;

  final double? price;

  final String? status;

  final CustomerModel? customerId;

  const BookModel(
      {this.id, this.name, this.price, this.status, this.customerId});

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        status: json['status'],
        customerId: json['customer_id']);
  }
}
