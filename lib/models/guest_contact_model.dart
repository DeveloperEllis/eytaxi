class GuestContact {
  final String? id;
  final String? name;
  final String? method;
  final String? contact;
  final String? address;
  final String? extraInfo;
  final DateTime? createdAt;

  GuestContact({
    this.id,
    this.name,
    this.method,
    this.contact,
    this.address,
    this.extraInfo,
    this.createdAt,
  });

  factory GuestContact.fromJson(Map<String, dynamic> json) {
    return GuestContact(
      id: json['id'],
      name: json['name'],
      method: json['method'],
      contact: json['contact'],
      address: json['address'],
      extraInfo: json['extra_info'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'method': method,
      'contact': contact,
      'address': address,
      'extra_info': extraInfo,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
