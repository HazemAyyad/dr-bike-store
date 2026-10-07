class StoreAddress {
  const StoreAddress({
    required this.id,
    required this.label,
    required this.streetAddress,
    required this.isDefault,
    this.phone,
    this.cityId,
    this.shiplyCityId,
    this.shiplyVillageId,
    this.shiplyCityName,
    this.shiplyVillageName,
    this.deliveryNotes,
  });

  final int id;
  final String label;
  final String streetAddress;
  final bool isDefault;
  final String? phone;
  final int? cityId;
  final int? shiplyCityId;
  final int? shiplyVillageId;
  final String? shiplyCityName;
  final String? shiplyVillageName;
  final String? deliveryNotes;

  String get locationLabel => [
    shiplyVillageName,
    shiplyCityName,
  ].whereType<String>().where((value) => value.trim().isNotEmpty).join('، ');

  factory StoreAddress.fromJson(Map<String, dynamic> json) => StoreAddress(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    label: json['label']?.toString() ?? 'عنوان',
    streetAddress: json['street_address']?.toString() ?? '',
    phone: json['phone']?.toString(),
    cityId: int.tryParse(json['city_id']?.toString() ?? ''),
    shiplyCityId: int.tryParse(json['shiply_city_id']?.toString() ?? ''),
    shiplyVillageId: int.tryParse(json['shiply_village_id']?.toString() ?? ''),
    shiplyCityName: json['shiply_city_name']?.toString(),
    shiplyVillageName: json['shiply_village_name']?.toString(),
    deliveryNotes: json['delivery_notes']?.toString(),
    isDefault: json['is_default'] == true || json['is_default'] == 1,
  );
}
