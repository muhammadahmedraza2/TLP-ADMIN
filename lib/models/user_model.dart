class UserModel {
  final int? id; // server se aayega, naya user banate waqt null hoga
  final String name;
  final String email;
  final String cnic;
  final String phone;
  final String district;
  final int unionCouncil;
  final int charge;
  final int psConstituencyId;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.cnic,
    required this.phone,
    required this.district,
    required this.unionCouncil,
    required this.charge,
    required this.psConstituencyId,
  });

  // Server se JSON aane par UserModel banane ke liye
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['userId'], // dono possible key names cover kiye
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      cnic: json['cnic'] ?? '',
      phone: json['phone'] ?? '',
      district: json['district'] ?? '',
      unionCouncil: json['unionCouncil'] ?? 0,
      charge: json['charge'] ?? 0,
      psConstituencyId: json['psConstituencyId'] ?? 0,
    );
  }

  // Add ya Update API ko bhejne ke liye JSON
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "cnic": cnic,
      "phone": phone,
      "district": district,
      "unionCouncil": unionCouncil,
      "charge": charge,
      "psConstituencyId": psConstituencyId,
    };
  }
}
