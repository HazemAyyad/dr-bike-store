// ignore_for_file: file_names



import '../classes/status_request.dart';

abstract class HandlingData {
  static handlingData(response) {
    if (response is StatusRequest) {
      return response;
    } else {
      return StatusRequest.success;
    }
  }
}
