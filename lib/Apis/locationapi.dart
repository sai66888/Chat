import 'network_utils.dart';
import 'package:upaychat/Models/locationmodel.dart';
import 'package:upaychat/CommonUtils/preferences_manager.dart';
import 'package:upaychat/CommonUtils/string_files.dart';


class LocationApi {
  final NetworkUtils _netUtil = NetworkUtils();

  sendLocation(double? latitude, double? longitude) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.sendLocation;
    if(latitude != null && longitude != null){
      return _netUtil.post(
        baseTokenUrl,
        body: {
          "latitude"  : latitude.toString(),
          "longitude" : longitude.toString()
        },
      ).then((dynamic res) {
        // PreferencesManager.setString(StringMessage.myAddress, res.data);
      });
    }

  }

  Future<LocationModel> getUsers(lat, lng, currentAddress, mile) {
    String baseTokenUrl = NetworkUtils.api_url + NetworkUtils.getUsers;
    return _netUtil.post(
      baseTokenUrl,
      body: {
        'lat': lat,
        'lng': lng,
        'address': currentAddress,
        'mile': mile.toString(),
      }
    ).then((dynamic res) {
      LocationModel result = LocationModel.map(res);
      return result;
    });
  }
}