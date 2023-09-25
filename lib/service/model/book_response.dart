class BookResponse {
  final int? id;

  final String? name;

  final double? price;

  final String? status;

  final Map? customer;

  final String? photoUrl;

  // final List? data;

  const BookResponse(
      {
      // this.dat
      this.name,
      this.id,
      this.price,
      this.status,
      this.customer,
      this.photoUrl});

  factory BookResponse.fromJson(Map<String, dynamic> json) {
    return BookResponse(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        status: json['status'],
        photoUrl: json['photoUrl'],
        customer: json['customer']);
  }
}
