import 'package:shared_preferences/shared_preferences.dart';


class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList(key);
    if(list == null){
      return new List<String>();
    }
    else{
      return list;
    }
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}