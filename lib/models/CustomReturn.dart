class CustomReturn {
  final bool status;
  final String error;

  CustomReturn({required this.status, required this.error});
}

class CustomReturnData {
  final bool status;
  final dynamic data;
  final String error;

  CustomReturnData(
      {required this.status, required this.data, required this.error});
}
