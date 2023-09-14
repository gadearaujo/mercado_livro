class CustomerLoginModel {
  final List? data;

  const CustomerLoginModel({required this.data});

  factory CustomerLoginModel.fromJson(Map<String, dynamic> json) {
    return CustomerLoginModel(data: json["name"]);
  }
}
