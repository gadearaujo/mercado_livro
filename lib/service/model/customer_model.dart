class CustomerModel {
  final int? id;

  final String? name;

  final String? email;

  final String? password;

  final String? photoUrl;

  const CustomerModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.photoUrl,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        password: json['password'],
        photoUrl: json['photo_url']);
  }
}
