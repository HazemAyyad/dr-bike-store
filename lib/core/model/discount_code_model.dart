class CouponModel {
  final int id;
  final String code;
  final String discountType;
  final double discountValue;
  final double discountAmount;
  final bool isActive;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.isActive,
  });

  factory CouponModel.fromJson(
    Map<String, dynamic> json, {
    required double discountAmount,
  }) {
    return CouponModel(
      id: (json['id'] as num).toInt(),
      code: json['code'].toString(),
      discountType: json['discount_type']?.toString() ?? 'fixed',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,
      discountAmount: discountAmount,
      isActive: json['is_active'] == true,
    );
  }
}
