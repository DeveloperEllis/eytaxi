class GuestContact {
  final String? id;
  final String? name;
  final String? method;
  final String? contact;
  final String? address;
  final String? extraInfo;

  GuestContact({
    this.id,
    this.name,
    this.method,
    this.contact,
    this.address,
    this.extraInfo,
  });

  factory GuestContact.fromJson(Map<String, dynamic> json) {
    return GuestContact(
      id: json['id'] as String?,
      name: json['name'] as String?,
      method: json['method'] as String?,
      contact: json['contact'] as String?,
      address: json['address'] as String?,
      extraInfo: json['extra_info'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {

      'name': name,
      'method': method,
      'contact': contact,
      'address': address,
      'extra_info': extraInfo,
    };
  }
}
