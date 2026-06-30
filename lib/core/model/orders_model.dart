class OrderResponse {
  final List<Order> rows;

  OrderResponse({required this.rows});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      rows:
          json['rows'] is List
              ? List<Order>.from(json['rows'].map((x) => Order.fromJson(x)))
              : <Order>[],
    );
  }
}

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return fallback;
}

String _asString(dynamic value, [String fallback = '']) {
  return value?.toString() ?? fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  return _asDouble(value);
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

class Order {
  final int id;
  final String serialNumber;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String phoneNum1;
  final String phoneNum2;
  final int cityId;
  final String address;
  final String status;
  final bool isWholesale;
  final double priceDelivery;
  final double totalPriceWithDiscound;
  final double totalPriceWithOutDiscound;
  final String? discoundCodeId;
  final double? discoundCodePercent;
  final String? discoundCode;
  final double? totalPriceWithDiscoundCode;
  final String userAddId;
  final String dateAdd;
  final String userUpdate;
  final String dateUpdate;
  final OrderHandover? latestHandover;
  final List<OrderStatusLog> statusLogs;
  final OrderShiplyTracking? shiplyTracking;
  final List<OrderDetail> details;

  Order({
    required this.id,
    required this.serialNumber,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.phoneNum1,
    required this.phoneNum2,
    required this.cityId,
    required this.address,
    required this.status,
    required this.isWholesale,
    required this.priceDelivery,
    required this.totalPriceWithDiscound,
    required this.totalPriceWithOutDiscound,
    this.discoundCodeId,
    this.discoundCodePercent,
    this.discoundCode,
    this.totalPriceWithDiscoundCode,
    required this.userAddId,
    required this.dateAdd,
    required this.userUpdate,
    required this.dateUpdate,
    this.latestHandover,
    this.statusLogs = const <OrderStatusLog>[],
    this.shiplyTracking,
    required this.details,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    final serialNumber = _asString(json['serialNumber']);
    final orderNumber = _asString(
      json['orderNumber'],
      serialNumber.isNotEmpty ? serialNumber : id.toString(),
    );
    return Order(
      id: id,
      serialNumber: serialNumber,
      orderNumber: orderNumber,
      customerId: _asString(json['customerId']),
      customerName: _asString(json['customerName']),
      phoneNum1: _asString(json['phoneNum1']),
      phoneNum2: _asString(json['phoneNum2']),
      cityId: _asInt(json['cityId']),
      address: _asString(json['address']),
      status: _asString(json['status']),
      isWholesale: _asBool(json['isWholesale']),
      priceDelivery: _asDouble(json['priceDelivery']),
      totalPriceWithDiscound: _asDouble(json['totalPriceWithDiscound']),
      totalPriceWithOutDiscound: _asDouble(json['totalPriceWithOutDiscound']),
      discoundCodeId: _asNullableString(json['discoundCodeId']),
      discoundCodePercent: _asNullableDouble(json['discoundCodePercent']),
      discoundCode: _asNullableString(json['discoundCode']),
      totalPriceWithDiscoundCode: _asNullableDouble(
        json['totalPriceWithDiscoundCode'],
      ),
      userAddId: _asString(json['userAddId']),
      dateAdd: _asString(json['dateAdd']),
      userUpdate: _asString(json['userUpdate']),
      dateUpdate: _asString(json['dateUpdate']),
      latestHandover:
          json['latestHandover'] is Map<String, dynamic>
              ? OrderHandover.fromJson(json['latestHandover'])
              : null,
      statusLogs:
          json['statusLogs'] is List
              ? List<OrderStatusLog>.from(
                json['statusLogs'].map((x) => OrderStatusLog.fromJson(x)),
              )
              : <OrderStatusLog>[],
      shiplyTracking:
          json['shiplyTracking'] is Map<String, dynamic>
              ? OrderShiplyTracking.fromJson(json['shiplyTracking'])
              : null,
      details:
          json['details'] is List
              ? List<OrderDetail>.from(
                json['details'].map((x) => OrderDetail.fromJson(x)),
              )
              : <OrderDetail>[],
    );
  }
}

class OrderHandover {
  final int id;
  final String deliveryCompanyName;
  final String deliveryCompanyCode;
  final String trackingNumber;
  final String carrierContactName;
  final String carrierContactPhone;
  final String carrierOfficeName;
  final String carrierVehicleNumber;
  final String shiplyParcelCode;
  final String handedOverAt;
  final String deliveredAt;

  const OrderHandover({
    required this.id,
    required this.deliveryCompanyName,
    required this.deliveryCompanyCode,
    required this.trackingNumber,
    required this.carrierContactName,
    required this.carrierContactPhone,
    required this.carrierOfficeName,
    required this.carrierVehicleNumber,
    required this.shiplyParcelCode,
    required this.handedOverAt,
    required this.deliveredAt,
  });

  factory OrderHandover.fromJson(Map<String, dynamic> json) {
    return OrderHandover(
      id: _asInt(json['id']),
      deliveryCompanyName: _asString(json['deliveryCompanyName']),
      deliveryCompanyCode: _asString(json['deliveryCompanyCode']),
      trackingNumber: _asString(json['trackingNumber']),
      carrierContactName: _asString(json['carrierContactName']),
      carrierContactPhone: _asString(json['carrierContactPhone']),
      carrierOfficeName: _asString(json['carrierOfficeName']),
      carrierVehicleNumber: _asString(json['carrierVehicleNumber']),
      shiplyParcelCode: _asString(json['shiplyParcelCode']),
      handedOverAt: _asString(json['handedOverAt']),
      deliveredAt: _asString(json['deliveredAt']),
    );
  }
}

class OrderStatusLog {
  final String fromStatus;
  final String toStatus;
  final String note;
  final String userName;
  final String createdAt;

  const OrderStatusLog({
    required this.fromStatus,
    required this.toStatus,
    required this.note,
    required this.userName,
    required this.createdAt,
  });

  factory OrderStatusLog.fromJson(Map<String, dynamic> json) {
    return OrderStatusLog(
      fromStatus: _asString(json['fromStatus']),
      toStatus: _asString(json['toStatus']),
      note: _asString(json['note']),
      userName: _asString(json['userName']),
      createdAt: _asString(json['createdAt']),
    );
  }
}

class OrderShiplyTracking {
  final String parcelCode;
  final String shiplyMode;
  final int currentStatusId;
  final String currentStatusKey;
  final String currentStatusLabel;
  final List<int> statusSequence;
  final List<OrderShiplyTrackingEvent> events;

  const OrderShiplyTracking({
    required this.parcelCode,
    required this.shiplyMode,
    required this.currentStatusId,
    required this.currentStatusKey,
    required this.currentStatusLabel,
    required this.statusSequence,
    required this.events,
  });

  factory OrderShiplyTracking.fromJson(Map<String, dynamic> json) {
    return OrderShiplyTracking(
      parcelCode: _asString(json['parcelCode']),
      shiplyMode: _asString(json['shiplyMode']),
      currentStatusId: _asInt(json['currentStatusId']),
      currentStatusKey: _asString(json['currentStatusKey']),
      currentStatusLabel: _asString(json['currentStatusLabel']),
      statusSequence:
          json['statusSequence'] is List
              ? List<int>.from(json['statusSequence'].map((x) => _asInt(x)))
              : const <int>[],
      events:
          json['events'] is List
              ? List<OrderShiplyTrackingEvent>.from(
                json['events'].map((x) => OrderShiplyTrackingEvent.fromJson(x)),
              )
              : const <OrderShiplyTrackingEvent>[],
    );
  }
}

class OrderShiplyTrackingEvent {
  final int id;
  final int parcelStatusId;
  final String statusKey;
  final String statusLabel;
  final String note;
  final String source;
  final String occurredAt;

  const OrderShiplyTrackingEvent({
    required this.id,
    required this.parcelStatusId,
    required this.statusKey,
    required this.statusLabel,
    required this.note,
    required this.source,
    required this.occurredAt,
  });

  factory OrderShiplyTrackingEvent.fromJson(Map<String, dynamic> json) {
    return OrderShiplyTrackingEvent(
      id: _asInt(json['id']),
      parcelStatusId: _asInt(json['parcelStatusId']),
      statusKey: _asString(json['statusKey']),
      statusLabel: _asString(json['statusLabel']),
      note: _asString(json['note']),
      source: _asString(json['source']),
      occurredAt: _asString(json['occurredAt']),
    );
  }
}

class OrderDetail {
  final int id;
  final int orderId;
  final int itemId;
  final bool isOrderSize;
  final int? itemSizeColorId;
  final int? itemSizeId;
  final int quantity;
  final double itemPrice;
  final double totalPriceWithDiscound;
  final double totalPriceWithOutDiscound;
  final ItemSizeColor? itemSizeColor;
  final ItemSize? itemSize;
  final Item item;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.isOrderSize,
    this.itemSizeColorId,
    this.itemSizeId,
    required this.quantity,
    required this.itemPrice,
    required this.totalPriceWithDiscound,
    required this.totalPriceWithOutDiscound,
    this.itemSizeColor,
    this.itemSize,
    required this.item,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: _asInt(json['id']),
      orderId: _asInt(json['orderId']),
      itemId: _asInt(json['itemId']),
      isOrderSize: _asBool(json['isOrderSize']),
      itemSizeColorId:
          json['itemSizeColorId'] == null
              ? null
              : _asInt(json['itemSizeColorId']),
      itemSizeId:
          json['itemSizeId'] == null ? null : _asInt(json['itemSizeId']),
      quantity: _asInt(json['quantity'], 1),
      itemPrice: _asDouble(json['itemPrice']),
      totalPriceWithDiscound: _asDouble(json['totalPriceWithDiscound']),
      totalPriceWithOutDiscound: _asDouble(json['totalPriceWithOutDiscound']),
      itemSizeColor:
          json['itemSizeColor'] != null
              ? ItemSizeColor.fromJson(json['itemSizeColor'])
              : null,
      itemSize:
          json['itemSize'] != null ? ItemSize.fromJson(json['itemSize']) : null,
      item:
          json['item'] is Map<String, dynamic>
              ? Item.fromJson(json['item'])
              : Item.empty(),
    );
  }
}

class Item {
  final int id;
  final String nameAr;
  final String nameEng;
  final String nameAbree;
  final bool isShow;
  final String descriptionAr;
  final String descriptionEng;
  final String descriptionAbree;
  final String? videoUrl;
  final double normailPrice;
  final double wholesalePrice;
  final int stock;
  final String model;
  final bool isNewItem;
  final bool isMoreSales;
  final double rate;
  final int manufactureYear;
  final double discount;
  final String? userIdAdd;
  final String dateAdd;
  final String? userIdUpdate;
  final String dateUpdate;
  final List<ItemImage> viewImagesItems;
  final List<ItemSize> itemSizes;

  Item({
    required this.id,
    required this.nameAr,
    required this.nameEng,
    required this.nameAbree,
    required this.isShow,
    required this.descriptionAr,
    required this.descriptionEng,
    required this.descriptionAbree,
    this.videoUrl,
    required this.normailPrice,
    required this.wholesalePrice,
    required this.stock,
    required this.model,
    required this.isNewItem,
    required this.isMoreSales,
    required this.rate,
    required this.manufactureYear,
    required this.discount,
    this.userIdAdd,
    required this.dateAdd,
    this.userIdUpdate,
    required this.dateUpdate,
    required this.viewImagesItems,
    required this.itemSizes,
  });

  factory Item.empty() {
    return Item(
      id: 0,
      nameAr: '',
      nameEng: '',
      nameAbree: '',
      isShow: false,
      descriptionAr: '',
      descriptionEng: '',
      descriptionAbree: '',
      normailPrice: 0,
      wholesalePrice: 0,
      stock: 0,
      model: '',
      isNewItem: false,
      isMoreSales: false,
      rate: 0,
      manufactureYear: 0,
      discount: 0,
      dateAdd: '',
      dateUpdate: '',
      viewImagesItems: const <ItemImage>[],
      itemSizes: const <ItemSize>[],
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: _asInt(json['id']),
      nameAr: _asString(json['nameAr']),
      nameEng: _asString(json['nameEng']),
      nameAbree: _asString(json['nameAbree']),
      isShow: _asBool(json['isShow']),
      descriptionAr: _asString(json['descriptionAr']),
      descriptionEng: _asString(json['descriptionEng']),
      descriptionAbree: _asString(json['descriptionAbree']),
      videoUrl: _asNullableString(json['videoUrl']),
      normailPrice: _asDouble(json['normailPrice']),
      wholesalePrice: _asDouble(json['wholesalePrice']),
      stock: _asInt(json['stock']),
      model: _asString(json['model']),
      isNewItem: _asBool(json['isNewItem']),
      isMoreSales: _asBool(json['isMoreSales']),
      rate: _asDouble(json['rate']),
      manufactureYear: _asInt(json['manufactureYear']),
      discount: _asDouble(json['discount']),
      userIdAdd: _asNullableString(json['userIdAdd']),
      dateAdd: _asString(json['dateAdd']),
      userIdUpdate: _asNullableString(json['userIdUpdate']),
      dateUpdate: _asString(json['dateUpdate']),
      viewImagesItems:
          json['viewImagesItems'] is List
              ? List<ItemImage>.from(
                json['viewImagesItems'].map((x) => ItemImage.fromJson(x)),
              )
              : <ItemImage>[],
      itemSizes:
          json['itemSizes'] is List
              ? List<ItemSize>.from(
                json['itemSizes'].map((x) => ItemSize.fromJson(x)),
              )
              : <ItemSize>[],
    );
  }
}

class ItemImage {
  final int id;
  final String imageUrl;
  final int itemId;

  ItemImage({required this.id, required this.imageUrl, required this.itemId});

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: _asInt(json['id']),
      imageUrl: _asString(json['imageUrl']),
      itemId: _asInt(json['itemId']),
    );
  }
}

class ItemSize {
  final int id;
  final int itemId;
  final String size;
  final double discount;
  final String? description;
  final List<ItemSizeColor> itemSizeColor;

  ItemSize({
    required this.id,
    required this.itemId,
    required this.size,
    required this.discount,
    this.description,
    required this.itemSizeColor,
  });

  factory ItemSize.fromJson(Map<String, dynamic> json) {
    return ItemSize(
      id: _asInt(json['id']),
      itemId: _asInt(json['itemId']),
      size: _asString(json['size']),
      discount: _asDouble(json['discount']),
      description: _asNullableString(json['description']),
      itemSizeColor:
          json['itemSizeColor'] is List
              ? List<ItemSizeColor>.from(
                json['itemSizeColor'].map((x) => ItemSizeColor.fromJson(x)),
              )
              : [],
    );
  }
}

class ItemSizeColor {
  final int id;
  final int sizeId;
  final String colorAr;
  final String colorEn;
  final String colorAbbr;
  final double normailPrice;
  final double wholesalePrice;
  final double discount;
  final int stock;

  ItemSizeColor({
    required this.id,
    required this.sizeId,
    required this.colorAr,
    required this.colorEn,
    required this.colorAbbr,
    required this.normailPrice,
    required this.wholesalePrice,
    required this.discount,
    required this.stock,
  });

  factory ItemSizeColor.fromJson(Map<String, dynamic> json) {
    return ItemSizeColor(
      id: _asInt(json['id']),
      sizeId: _asInt(json['sizeId']),
      colorAr: _asString(json['colorAr']),
      colorEn: _asString(json['colorEn']),
      colorAbbr: _asString(json['colorAbbr']),
      normailPrice: _asDouble(json['normailPrice']),
      wholesalePrice: _asDouble(json['wholesalePrice']),
      discount: _asDouble(json['discount']),
      stock: _asInt(json['stock']),
    );
  }
}
