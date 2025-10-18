import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Globals/global.dart' as globals;
import '../shared_prff.dart';
import '../Globals/global_methods.dart' as global_methods;

class MapHelper{

  getData(var token)async{
    print("saeeeeeeeeeed1 MapHelper");

    var  url = Uri.parse("${globals.public_uri}tasks/map-data");



    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",
      "Authorization": "Bearer $token"

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }
    );
    print("saeeeeeeeeeeedddddddd data: ${response.body}");
    print("saeeeeeeeeeeedddddddd data: ${response.statusCode}");

    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeedddddddd data: ${jsonDecode(response.body)}");

    return data;
  }

}