import 'package:upaychat/Apis/network_utils.dart';
import 'package:upaychat/Models/commonmodel.dart';

class LockFundsApi{
  NetworkUtils _netUtil = new NetworkUtils();
  Future<CommonModel> lockFunds(String lockAmount, String interestRate, String lockDuration, String interestedEarned, String earnings, String paybackDate, String lockedDate, String safeLockName) async {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.safeLockFunds;
    return _netUtil.post(
      baseTokenUrl,
      body: {
        "lock_amount": lockAmount,
        "interest_rate": interestRate,
        "lock_duration": lockDuration,
        'earnings': earnings,
        'payback_date': paybackDate,
        'locked_date': lockedDate,
        'interest_earned': interestedEarned,
        'safe_lock_name': safeLockName
      },
    ).then((dynamic res) {
      CommonModel result = new CommonModel.map(res);
      return result;
    });
  }
}