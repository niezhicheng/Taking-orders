import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static Future<void> addData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('Data added successfully');
  }

  static Future<String?> getData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> updateData(String key, String newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentValue = prefs.getString(key);
    if (currentValue != null) {
      await prefs.setString(key, newValue);
      print('Data updated successfully');
    } else {
      print('No data found for key $key');
    }
  }

  static Future<void> deleteData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool success = await prefs.remove(key);
    if (success) {
      print('Data deleted successfully');
    } else {
      print('No data found for key $key');
    }
  }
}

Future<String?> getData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<int?> getInt(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(key);
}

Future<bool> deleteData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.remove(key);
}

Future<void> SetData(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> SetInt(String key, int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value);
}
