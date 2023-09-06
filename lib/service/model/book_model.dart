class BookModel {
  final int? id;

  final String? name;

  final double? price;

  final String? status;

  final Map? customer;

  final String? photoUrl;

  const BookModel(
      {this.id,
      this.name,
      this.price,
      this.status,
      this.customer,
      this.photoUrl});

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        status: json['status'],
        photoUrl: json['photoUrl'],
        customer: json['customer']);
  }
}
