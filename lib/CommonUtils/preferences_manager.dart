import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static SharedPreferences? _prefInstance;

  static init() async {
    _prefInstance = await SharedPreferences.getInstance();
  }

  static reload() async{
    await _prefInstance?.reload();
  }
  static Future<bool> clear() async {
    return _prefInstance!.clear();
  }

  static Future<bool> setBool(String key, bool value) {
    return _prefInstance!.setBool(key, value);
  }

  static bool getBool(String key) {
    return _prefInstance!.getBool(key) ?? false;
  }

  static Future<bool> setString(String key, String value) {
    return _prefInstance!.setString(key, value);
  }

  static Future<bool> setDouble(String key, double value) {
    return _prefInstance!.setDouble(key, value);
  }

  static double getDouble(String key) {
    return _prefInstance!.getDouble(key) ?? 0.0;
  }

  static String getString(String key) {
    return _prefInstance!.getString(key) ?? "";
  }

  static Future<bool> setInt(String key, int value) {
    return _prefInstance!.setInt(key, value);
  }

  static int getInt(String key) {
    return _prefInstance!.getInt(key) ?? 0;
  }
}
