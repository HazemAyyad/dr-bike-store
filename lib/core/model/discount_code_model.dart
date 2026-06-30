class CouponModel {
  final int id;
  final String code;
  final String name;
  final String description;
  final double discountPercent;
  final bool isActive;
  final String addDate;
  final String addUserId;
  final String updateDate;
  final String updateUserId;

  CouponModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountPercent,
    required this.isActive,
    required this.addDate,
    required this.addUserId,
    required this.updateDate,
    required this.updateUserId,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      discountPercent: (json['discoundPercent'] as num).toDouble(),
      isActive: json['isActive'],
      addDate: json['addDate'],
      addUserId: json['addUserId'],
      updateDate: json['updateDate'],
      updateUserId: json['updateUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'discoundPercent': discountPercent,
      'isActive': isActive,
      'addDate': addDate,
      'addUserId': addUserId,
      'updateDate': updateDate,
      'updateUserId': updateUserId,
    };
  }
}
