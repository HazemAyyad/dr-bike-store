class UserModel {
  String id;
  String userName;
  String normalizedUserName;
  String email;
  String normalizedEmail;
  bool emailConfirmed;
  String passwordHash;
  String securityStamp;
  String concurrencyStamp;
  String? phoneNumber;
  bool phoneNumberConfirmed;
  bool twoFactorEnabled;
  String? lockoutEnd;
  bool lockoutEnabled;
  int accessFailedCount;
  String? address;
  String? profileImageUrl;
  bool block;
  String? fullName;
  String? phoneNumber2;
  String typeUser;
  String userToken;
  String dateAdd;
  String userUpdate;
  String dateUpdate;
  int? cityId;
  City? city;
  List<Role> roles;

  UserModel({
    required this.id,
    required this.userName,
    required this.normalizedUserName,
    required this.email,
    required this.normalizedEmail,
    required this.emailConfirmed,
    required this.passwordHash,
    required this.securityStamp,
    required this.concurrencyStamp,
    this.phoneNumber,
    required this.phoneNumberConfirmed,
    required this.twoFactorEnabled,
    this.lockoutEnd,
    required this.lockoutEnabled,
    required this.accessFailedCount,
    this.address,
    this.profileImageUrl,
    required this.block,
    this.fullName,
    this.phoneNumber2,
    required this.typeUser,
    required this.userToken,
    required this.dateAdd,
    required this.userUpdate,
    required this.dateUpdate,
    this.cityId,
    this.city,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"]?.toString() ?? '',
    userName: json["userName"]?.toString() ?? '',
    normalizedUserName: json["normalizedUserName"]?.toString() ?? '',
    email: json["email"]?.toString() ?? '',
    normalizedEmail: json["normalizedEmail"]?.toString() ?? '',
    emailConfirmed: json["emailConfirmed"] == true,
    passwordHash: json["passwordHash"]?.toString() ?? '',
    securityStamp: json["securityStamp"]?.toString() ?? '',
    concurrencyStamp: json["concurrencyStamp"]?.toString() ?? '',
    phoneNumber: json["phoneNumber"]?.toString(),
    phoneNumberConfirmed: json["phoneNumberConfirmed"] == true,
    twoFactorEnabled: json["twoFactorEnabled"] == true,
    lockoutEnd: json["lockoutEnd"]?.toString(),
    lockoutEnabled: json["lockoutEnabled"] == true,
    accessFailedCount:
        int.tryParse(json["accessFailedCount"]?.toString() ?? '') ?? 0,
    address: json["address"]?.toString(),
    profileImageUrl: json["profileImageUrl"]?.toString(),
    block: json["block"] == true,
    fullName: json["fullName"]?.toString(),
    phoneNumber2: json["phoneNumber2"]?.toString(),
    typeUser: json["typeUser"]?.toString() ?? '',
    userToken: json["userToken"]?.toString() ?? '',
    dateAdd: json["dateAdd"]?.toString() ?? '',
    userUpdate: json["userUpdate"]?.toString() ?? '',
    dateUpdate: json["dateUpdate"]?.toString() ?? '',
    cityId: int.tryParse(json["cityId"]?.toString() ?? ''),
    city:
        json["city"] is Map<String, dynamic>
            ? City.fromJson(json["city"])
            : null,
    roles:
        json["roles"] is List
            ? List<Role>.from(json["roles"].map((x) => Role.fromJson(x)))
            : <Role>[],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userName": userName,
    "normalizedUserName": normalizedUserName,
    "email": email,
    "normalizedEmail": normalizedEmail,
    "emailConfirmed": emailConfirmed,
    "passwordHash": passwordHash,
    "securityStamp": securityStamp,
    "concurrencyStamp": concurrencyStamp,
    "phoneNumber": phoneNumber,
    "phoneNumberConfirmed": phoneNumberConfirmed,
    "twoFactorEnabled": twoFactorEnabled,
    "lockoutEnd": lockoutEnd,
    "lockoutEnabled": lockoutEnabled,
    "accessFailedCount": accessFailedCount,
    "address": address,
    "profileImageUrl": profileImageUrl,
    "block": block,
    "fullName": fullName,
    "phoneNumber2": phoneNumber2,
    "typeUser": typeUser,
    "userToken": userToken,
    "dateAdd": dateAdd,
    "userUpdate": userUpdate,
    "dateUpdate": dateUpdate,
    "cityId": cityId,
    "city": city,
    "roles": List<dynamic>.from(roles.map((x) => x.toJson())),
  };
}

class City {
  int id;
  String cityNameAr;
  String cityNameEng;
  String cityNameAbree;
  double deliver;
  bool isShow;
  dynamic userIdAdd;
  String dateAdd;
  dynamic userUpdate;
  String dateUpdate;

  City({
    required this.id,
    required this.cityNameAr,
    required this.cityNameEng,
    required this.cityNameAbree,
    required this.deliver,
    required this.isShow,
    this.userIdAdd,
    required this.dateAdd,
    this.userUpdate,
    required this.dateUpdate,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: int.tryParse(json["id"]?.toString() ?? '') ?? 0,
    cityNameAr: json["cityNameAr"]?.toString() ?? '',
    cityNameEng: json["cityNameEng"]?.toString() ?? '',
    cityNameAbree: json["cityNameAbree"]?.toString() ?? '',
    deliver: double.tryParse(json["deliver"]?.toString() ?? '') ?? 0,
    isShow: json["isShow"] == true,
    userIdAdd: json["userIdAdd"],
    dateAdd: json["dateAdd"]?.toString() ?? '',
    userUpdate: json["userUpdate"],
    dateUpdate: json["dateUpdate"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cityNameAr": cityNameAr,
    "cityNameEng": cityNameEng,
    "cityNameAbree": cityNameAbree,
    "deliver": deliver,
    "isShow": isShow,
    "userIdAdd": userIdAdd,
    "dateAdd": dateAdd,
    "userUpdate": userUpdate,
    "dateUpdate": dateUpdate,
  };
}

class Role {
  String id;
  String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["id"]?.toString() ?? '',
    name: json["name"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
