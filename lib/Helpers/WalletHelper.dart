import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Globals/global.dart' as globals;
import '../shared_prff.dart';
import '../Globals/global_methods.dart' as global_methods;

class WalletHelper{

  getData(var token)async{

    var  url = Uri.parse("${globals.public_uri}wallet");


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
  getTransactionData(int page,String sortBy,String filter,int withImageOnly,String search,  var token)async{

    var  url = Uri.parse("${globals.public_uri}wallet/transactions");

    var body = jsonEncode({
      "page":page,
      "per_page":10,
      "sort_by":sortBy,
      "search":search,
      if(withImageOnly!=0)
        "image":withImageOnly,
      if(filter!='all')
      "transaction_type":filter,

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
    print("saeeeeeeeeeeedddddddd body: ${body}");
    print("saeeeeeeeeeeedddddddd data: ${response.body}");
    print("saeeeeeeeeeeedddddddd data: ${response.statusCode}");

    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeedddddddd data: ${jsonDecode(response.body)}");

    return data;
  }

}