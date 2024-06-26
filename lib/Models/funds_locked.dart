class FundsLockedListModel{
  String status = '';
  String message = '';
  String total = '';
  List<FundsLocked> fundsLockedList = [];

  FundsLockedListModel.map(dynamic obj) {
    this.status = obj["status"].toString();
    this.message = obj["message"].toString();
    this.total = obj["total"].toString();
    this.fundsLockedList = (obj['data'] as List)
        .map((i) => FundsLocked.fromJson(i))
        .toList();
  }
}
class FundsLocked{
  int? userId;
  int? id;
  String? lockedAt;
  String? paybackAt;
  double? lockAmount;
  double? interestRate;
  double? interestEarned;
  double? earnings;
  String? safeLockName;

  FundsLocked.fromJson(dynamic jsonMap)
      : id = int.parse(jsonMap['id'].toString()),
        userId = int.parse(jsonMap['user_id'].toString()),
        lockedAt = jsonMap['locked_at'],
        paybackAt = jsonMap['payback_at'],
        lockAmount = double.parse(jsonMap['lock_amount'].toString()),
        interestRate = double.parse(jsonMap['interest_rate'].toString()),
        earnings = double.parse(jsonMap['earnings'].toString()),
        interestEarned = double.parse(jsonMap['interest_earned'].toString()),
        safeLockName = jsonMap['safe_lock_name'].toString();
}