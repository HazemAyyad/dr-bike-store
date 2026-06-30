
// import 'package:http/http.dart' as htpp;
// import 'package:pos/core/helper/db_helper.dart';
// import 'package:pos/core/model/client_model.dart';
// import 'package:pos/repository/client_repository.dart';

// class SyncronizationData {

//   // static Future<bool> isInternet()async{
//   //   var connectivityResult = await (Connectivity().checkConnectivity());
//   //   if (connectivityResult == ConnectivityResult.mobile) {
//   //     if (await DataConnectionChecker().hasConnection) {
//   //       print("Mobile data detected & internet connection confirmed.");
//   //       return true;
//   //     }else{
//   //       print('No internet :( Reason:');
//   //       return false;
//   //     }
//   //   } else if (connectivityResult == ConnectivityResult.wifi) {
//   //     if (await DataConnectionChecker().hasConnection) {
//   //       print("wifi data detected & internet connection confirmed.");
//   //       return true;
//   //     }else{
//   //       print('No internet :( Reason:');
//   //       return false;
//   //     }
//   //   }else {
//   //     print("Neither mobile data or WIFI detected, not internet connection found.");
//   //     return false;
//   //   }
//   // }

//   final conn = DBHelper.instance;
//   static final clientTable = 'users';
//   late ClientRepository clientRepository;

//  Future<List<ClientModel>> fetchAllInfo()async{
//     final dbClient = await conn.db;
//     List<ClientModel> contactList = [];
//     try {
//       final maps = await dbClient!.query(clientTable);
//       for (var item in maps) {
//         contactList.add(ClientModel.fromJson(item));
//       }
//     } catch (e) {
//       print(e.toString());
//     }
//     return contactList;
//   }
//   Future saveToMysqlWith(List<ClientModel> contactList)async{
//     for (var i = 0; i < contactList.length; i++) {
//       Map<String, dynamic> data = {
//         "cID":contactList[i].cID.toString(),
//         "cName":contactList[i].cName.toString(),
//         "code":contactList[i].code.toString(),
//         "address1":contactList[i].address1.toString(),
//         "tel1":contactList[i].tel1.toString(),
//         "taxCardNo":contactList[i].taxCardNo.toString(),
//         "itemPriceListName":contactList[i].itemPriceListName.toString(),
//         "custnationality":contactList[i].custnationality.toString(),
//       };
//       final response =await clientRepository.postAddClient( contactList[i].cName.toString(),  contactList[i].cName.toString() ,contactList[i].tel1.toString(),contactList[i].address1.toString(),contactList[i].taxCardNo.toString());
//       if (response.statusCode==200) {
//         print("Saving Data ");
//       }else{
//         print(response.statusCode);
//       }
//     }
//   }


// }