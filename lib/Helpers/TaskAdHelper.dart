import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Globals/global.dart' as globals;
import '../shared_prff.dart';
import '../Globals/global_methods.dart' as global_methods;

class TaskAdHelper{

  getData(int page,String filter,String search,  var token)async{

    var  url = Uri.parse("${globals.public_uri}ads/data");

    var body = jsonEncode({
      "page":page,
      "per_page":10,
      "status":filter,
      "search":search,

    });


    var response = await http.post(url,body: body, headers: {
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


  getDetails(int id,  var token)async{

    print("niaaaaaaaaa details");
    var  url = Uri.parse("${globals.public_uri}ads/$id");

    // var body = jsonEncode({
    //   "id":id,
    //
    //
    // });


    // var response = await http.post(url,body: body, headers: {
    var response = await http.post(url, headers: {
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


  getOffers(int id,  var token)async{

    var  url = Uri.parse("${globals.public_uri}ads/$id/offers");


    // var body = jsonEncode({
    //   "page":page,
    //   "per_page":10,
    //   // "id":id,
    //
    // });


    // var response = await http.post(url,body: body, headers: {
    var response = await http.post(url, headers: {
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

  acceptOffer(int id,  var token)async{

    var  url = Uri.parse("${globals.public_uri}ads/offers/$id/accept");
    var response = await http.post(url, headers: {
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
  retractOffer(int id,  var token)async{

    var  url = Uri.parse("${globals.public_uri}ads/offers/$id/retract");
    var response = await http.post(url, headers: {
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