class CustomerModel {
  final int? id;

  final String? name;

  final String? email;

  const CustomerModel({
    this.id,
    this.name,
    this.email,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
