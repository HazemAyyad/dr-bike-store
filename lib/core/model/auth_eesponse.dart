import 'dart:convert';

List<String> _accountRoles(dynamic value) =>
    value is List
        ? value.whereType<Object>().map((role) => role.toString()).toList()
        : <String>[];

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token};
  }
}

class User {
  final String id;
  final String userName;
  final String normalizedUserName;
  final String email;
  final String normalizedEmail;
  final bool emailConfirmed;
  final String passwordHash;
  final String securityStamp;
  final String concurrencyStamp;
  final String? phoneNumber;
  final bool phoneNumberConfirmed;
  final bool twoFactorEnabled;
  final dynamic lockoutEnd;
  final bool lockoutEnabled;
  final int accessFailedCount;
  final String? address;
  final bool block;
  final String? fullName;
  final String? phoneNumber2;
  final String? typeUser;
  final List<String> accountRoles;
  final String? userToken;
  final String? dateAdd;
  final String? userUpdate;
  final String? dateUpdate;
  final int? cityId;
  final City? city;
  final List<dynamic>? mainOrders;
  final List<Role>? roles;

  User({
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
    required this.lockoutEnd,
    required this.lockoutEnabled,
    required this.accessFailedCount,
    this.address,
    required this.block,
    required this.fullName,
    this.phoneNumber2,
    this.typeUser,
    this.accountRoles = const [],
    this.userToken,
    this.dateAdd,
    this.userUpdate,
    this.dateUpdate,
    this.cityId,
    this.city,
    this.mainOrders,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    userName: json["userName"],
    normalizedUserName: json["normalizedUserName"],
    email: json["email"],
    normalizedEmail: json["normalizedEmail"],
    emailConfirmed: json["emailConfirmed"],
    passwordHash: json["passwordHash"],
    securityStamp: json["securityStamp"],
    concurrencyStamp: json["concurrencyStamp"],
    phoneNumber: json["phoneNumber"],
    phoneNumberConfirmed: json["phoneNumberConfirmed"],
    twoFactorEnabled: json["twoFactorEnabled"],
    lockoutEnd: json["lockoutEnd"],
    lockoutEnabled: json["lockoutEnabled"],
    accessFailedCount: json["accessFailedCount"],
    address: json["address"],
    block: json["block"],
    fullName: json["fullName"],
    phoneNumber2: json["phoneNumber2"],
    typeUser: json["typeUser"],
    accountRoles: _accountRoles(json['accountRoles']),
    userToken: json["userToken"],
    dateAdd: json["dateAdd"],
    userUpdate: json["userUpdate"],
    dateUpdate: json["dateUpdate"],
    cityId: json["cityId"],
    city: City.fromJson(json['city'] ?? {}),
    mainOrders: List<dynamic>.from(json["mainOrders"].map((x) => x) ?? []),
    roles: List<Role>.from(json["roles"].map((x) => Role.fromJson(x)) ?? []),
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
    "block": block,
    "fullName": fullName,
    "phoneNumber2": phoneNumber2,
    "typeUser": typeUser,
    "accountRoles": accountRoles,
    "userToken": userToken,
    "dateAdd": dateAdd,
    "userUpdate": userUpdate,
    "dateUpdate": dateUpdate,
    "cityId": cityId,
    "city": city,
    "mainOrders": List<dynamic>.from(mainOrders!.map((x) => x)),
    "roles": List<dynamic>.from(roles!.map((x) => x.toJson())),
  };
}

class City {
  final int? id;
  final String? cityNameAr;
  final String? cityNameEng;
  final String? cityNameAbree;
  final double? deliver;
  final bool? isShow;
  final dynamic userIdAdd;
  final String? dateAdd;
  final dynamic userUpdate;
  final String? dateUpdate;

  City({
    this.id,
    this.cityNameAr,
    this.cityNameEng,
    this.cityNameAbree,
    this.deliver,
    this.isShow,
    this.userIdAdd,
    this.dateAdd,
    this.userUpdate,
    this.dateUpdate,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    id: json["id"],
    cityNameAr: json["cityNameAr"],
    cityNameEng: json["cityNameEng"],
    cityNameAbree: json["cityNameAbree"],
    deliver:
        json["deliver"] == null ? null : (json["deliver"] as num).toDouble(),
    isShow: json["isShow"],
    userIdAdd: json["userIdAdd"],
    dateAdd: json["dateAdd"],
    userUpdate: json["userUpdate"],
    dateUpdate: json["dateUpdate"],
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
  final String? id;
  final String? name;

  Role({this.id, this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// Convert JSON string to UserModel object
AuthResponse userModelFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

// Convert UserModel object to JSON string
String userModelToJson(AuthResponse data) => json.encode(data.toJson());

class UserSignUp {
  final String id;
  final String userName;
  final String normalizedUserName;
  final String email;
  final String normalizedEmail;
  final bool emailConfirmed;
  final String passwordHash;
  final String securityStamp;
  final String concurrencyStamp;
  final String? phoneNumber;
  final bool phoneNumberConfirmed;
  final bool twoFactorEnabled;
  final dynamic lockoutEnd;
  final bool lockoutEnabled;
  final int accessFailedCount;
  final String? address;
  final bool block;
  final String? fullName;
  final String? phoneNumber2;
  final String typeUser;
  final List<String> accountRoles;
  final String? userToken;
  final String dateAdd;
  final String userUpdate;
  final String dateUpdate;
  final int? cityId;
  final City? city;
  final List<dynamic>? mainOrders;
  final List<Role>? roles;

  UserSignUp({
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
    required this.lockoutEnd,
    required this.lockoutEnabled,
    required this.accessFailedCount,
    this.address,
    required this.block,
    required this.fullName,
    this.phoneNumber2,
    required this.typeUser,
    this.accountRoles = const [],
    this.userToken,
    required this.dateAdd,
    required this.userUpdate,
    required this.dateUpdate,
    this.cityId,
    this.city,
    this.mainOrders,
    this.roles,
  });

  factory UserSignUp.fromJson(Map<String, dynamic> json) => UserSignUp(
    id: json["id"],
    userName: json["userName"],
    normalizedUserName: json["normalizedUserName"],
    email: json["email"],
    normalizedEmail: json["normalizedEmail"],
    emailConfirmed: json["emailConfirmed"],
    passwordHash: json["passwordHash"],
    securityStamp: json["securityStamp"],
    concurrencyStamp: json["concurrencyStamp"],
    phoneNumber: json["phoneNumber"],
    phoneNumberConfirmed: json["phoneNumberConfirmed"],
    twoFactorEnabled: json["twoFactorEnabled"],
    lockoutEnd: json["lockoutEnd"],
    lockoutEnabled: json["lockoutEnabled"],
    accessFailedCount: json["accessFailedCount"],
    address: json["address"],
    block: json["block"],
    fullName: json["fullName"],
    phoneNumber2: json["phoneNumber2"],
    typeUser: json["typeUser"],
    accountRoles: _accountRoles(json['accountRoles']),
    userToken: json["userToken"],
    dateAdd: json["dateAdd"],
    userUpdate: json["userUpdate"],
    dateUpdate: json["dateUpdate"],
    cityId: json["cityId"],
    city: json["city"],
    mainOrders: json["mainOrders"],
    roles: json["roles"],
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
    "block": block,
    "fullName": fullName,
    "phoneNumber2": phoneNumber2,
    "typeUser": typeUser,
    "accountRoles": accountRoles,
    "userToken": userToken,
    "dateAdd": dateAdd,
    "userUpdate": userUpdate,
    "dateUpdate": dateUpdate,
    "cityId": cityId,
    "city": city,
    "mainOrders": mainOrders,
    "roles": roles,
  };
}

class AuthModel {
  final UserModel user;
  final String token;

  AuthModel({required this.user, required this.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token};
  }
}

class UserModel {
  final String id;
  final String userName;
  final String normalizedUserName;
  final String email;
  final String normalizedEmail;
  final bool emailConfirmed;
  final String passwordHash;
  final String securityStamp;
  final String concurrencyStamp;
  final String? phoneNumber;
  final bool phoneNumberConfirmed;
  final bool twoFactorEnabled;
  final String? lockoutEnd;
  final bool lockoutEnabled;
  final int accessFailedCount;
  final String? address;
  final bool block;
  final String? fullName;
  final String? phoneNumber2;
  final String typeUser;
  final List<String> accountRoles;
  final String userToken;
  final String dateAdd;
  final String userUpdate;
  final String dateUpdate;
  final int? cityId;
  final City? city;
  final List<dynamic>? mainOrders;
  final List<RoleModel> roles;

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
    required this.block,
    this.fullName,
    this.phoneNumber2,
    required this.typeUser,
    this.accountRoles = const [],
    required this.userToken,
    required this.dateAdd,
    required this.userUpdate,
    required this.dateUpdate,
    this.cityId,
    this.city,
    required this.mainOrders,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      normalizedUserName: json['normalizedUserName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      normalizedEmail: json['normalizedEmail']?.toString() ?? '',
      emailConfirmed: json['emailConfirmed'] == true,
      passwordHash: json['passwordHash']?.toString() ?? '',
      securityStamp: json['securityStamp']?.toString() ?? '',
      concurrencyStamp: json['concurrencyStamp']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      phoneNumberConfirmed: json['phoneNumberConfirmed'] == true,
      twoFactorEnabled: json['twoFactorEnabled'] == true,
      lockoutEnd: json['lockoutEnd'],
      lockoutEnabled: json['lockoutEnabled'] == true,
      accessFailedCount:
          int.tryParse(json['accessFailedCount']?.toString() ?? '') ?? 0,
      address: json['address']?.toString(),
      block: json['block'] == true,
      fullName: json['fullName']?.toString(),
      phoneNumber2: json['phoneNumber2']?.toString(),
      typeUser: json['typeUser']?.toString() ?? '',
      accountRoles: _accountRoles(json['accountRoles']),
      userToken: json['userToken']?.toString() ?? '',
      dateAdd: json['dateAdd']?.toString() ?? '',
      userUpdate: json['userUpdate']?.toString() ?? '',
      dateUpdate: json['dateUpdate']?.toString() ?? '',
      cityId: int.tryParse(json['cityId']?.toString() ?? ''),
      city:
          json['city'] is Map<String, dynamic>
              ? City.fromJson(json['city'])
              : null,
      mainOrders: List<dynamic>.from(json['mainOrders'] ?? []),
      roles:
          (json['roles'] as List<dynamic>? ?? [])
              .map((role) => RoleModel.fromJson(role))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'normalizedUserName': normalizedUserName,
      'email': email,
      'normalizedEmail': normalizedEmail,
      'emailConfirmed': emailConfirmed,
      'passwordHash': passwordHash,
      'securityStamp': securityStamp,
      'concurrencyStamp': concurrencyStamp,
      'phoneNumber': phoneNumber,
      'phoneNumberConfirmed': phoneNumberConfirmed,
      'twoFactorEnabled': twoFactorEnabled,
      'lockoutEnd': lockoutEnd,
      'lockoutEnabled': lockoutEnabled,
      'accessFailedCount': accessFailedCount,
      'address': address,
      'block': block,
      'fullName': fullName,
      'phoneNumber2': phoneNumber2,
      'typeUser': typeUser,
      'accountRoles': accountRoles,
      'userToken': userToken,
      'dateAdd': dateAdd,
      'userUpdate': userUpdate,
      'dateUpdate': dateUpdate,
      'cityId': cityId,
      'city': city,
      'mainOrders': mainOrders,
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }
}

class RoleModel {
  final String id;
  final String name;

  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
