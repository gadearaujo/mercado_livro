class BookModel {
  // final int? id;

  // final String? name;

  // final double? price;

  // final String? status;

  // final Map? customer;

  // final String? photoUrl;

  final List? data;

  const BookModel({
    this.data,
    // this.name,
    // this.price,
    // this.status,
    // this.customer,
    // this.photoUrl
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(data: json['content']);
    // id: json['id'],
    // name: json['name'],
    // price: json['price'],
    // status: json['status'],
    // photoUrl: json['photoUrl'],
    // customer: json['customer']);
  }
}
