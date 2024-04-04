import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class usefulFunctions {

  static Future<String> getRequest(String result) async{
    
    http.Response response = await http.get(Uri.parse(result));
    return utf8.encode(response.body).toString();
  }
  


}