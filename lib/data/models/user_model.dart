class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? address;
  final List<String> orderHistory;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.address,
    this.orderHistory = const [],
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      profilePicture: data['profilePicture'],
      address: data['address'],
      orderHistory: List<String>.from(data['orderHistory'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'address': address,
      'orderHistory': orderHistory,
    };
  }
}
