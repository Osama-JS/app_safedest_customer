import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Globals/global.dart' as globals;
import '../Globals/global_methods.dart' as global_methods;

class User_Helper {

  sendError(var error)async{
    if (await global_methods.isInternetAvailable()) {
      var url = Uri.parse('${globals.public_uri}Home/PostException');
      var body = jsonEncode({"message":error});
      var response = await http.post(url,body: body, headers: {
        "Accept": "application/json",
        "Accept-Language": global_methods.getLanguage(),
        "content-type": "application/json"
      }).timeout(
          const Duration(minutes: 1),
          onTimeout: () {
            return http.Response('Errorr', 408);
          }
      );
      print("saeeeeeeeeeeed  error data: ${url}");
      print("saeeeeeeeeeeed  error data: ${response.body}");
      print("saeeeeeeeeeeed  error data: ${response.statusCode}");
      var data = jsonDecode(response.body);
      print("saeeeeeeeeeeed  error data: $data");
      return data;
    }
    return null;
  }


  login(var userName,var password, var notificationToken)async{
    var url = Uri.parse(globals.public_uri+'login');
    var body = jsonEncode({"email":userName,"password":password,"fcm_token":notificationToken});
    var response = await http.post(url, body: body,headers: {
      "Accept-Language": global_methods.getLanguage(),
      "Accept": "application/json",
      "content-type": "application/json"
    }).timeout(
      const Duration(minutes: 1),
      onTimeout: () {
        return http.Response('Errorr', 408);
      }


    );
    print("saeeeeeeeeeeed data: "+ url.toString());
    print("saeeeeeeeeeeed data: "+ body.toString());
    print("saeeeeeeeeeeed data: "+ response.body.toString());
    print("saeeeeeeeeeeed data: "+ response.body.toString());
    print("saeeeeeeeeeeed data: "+ response.statusCode.toString());

    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed data: "+ data.toString());
    return data;
  }


  register(var name,var email,var phone,var phoneCode,var password,var confirmPassword, var notificationToken)async{
    var url = Uri.parse(globals.public_uri+'register');
    var body = jsonEncode({
    "name":name,
    "email":email,
    "phone":phone,
    "phone_code":phoneCode,
    "password":password,
    "confirm-password":confirmPassword,
    // "notificationToken":notificationToken
    });
    var response = await http.post(url, body: body,headers: {
      "Accept-Language": global_methods.getLanguage(),
      "Accept": "application/json",
      "content-type": "application/json"
    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }


    );
    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed data: "+ data.toString());
    print("saeeeeeeeeeeed body: "+ body.toString());
    return data;
  }



  OTPVerification(var code, var email)async{
    print("saeeeeeeeeeeed code data: "+ code.toString());

    int codee = int.parse(code);
    print("saeeeeeeeeeeed code data: "+ codee.toString());

    var url;
    if(globals.isForgetPassword) {
       url = Uri.parse(
          globals.public_uri + "check-reset-code");
    }else {
       url = Uri.parse(
          globals.public_uri + "verify-email-code");
    }
    var body = jsonEncode({
    "email":email,
    "code":code
    });

    var response = await http.post(url,body: body, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }
    );
    print("saeeeeeeeeeeeddddyyy data: "+ response.statusCode.toString());
    print("saeeeeeeeeeeeddddyyy data: "+ response.body.toString());

    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeedddd data: "+ jsonDecode(response.body).toString());

    return data;
  }


  resendOTP(var email)async{

    var url;
    if(globals.isForgetPassword) {
       url = Uri.parse(globals.public_uri + "resend-verification");
    }else{
         url = Uri.parse(globals.public_uri + "resend-verification");
      }

    var body = jsonEncode({"email":email});


    var response = await http.post(url,body: body, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }
    );
    // print("saeeeeeeeeeeed data: "+ token.toString());
    print("saeeeeeeeeeeeddddzzz data: "+ url.toString());
    print("saeeeeeeeeeeeddddzzz data: "+ response.statusCode.toString());

    var data = jsonDecode(response.body);
    // print("saeeeeeeeeeeed data: "+ jsonDecode(response.body).toString());

    return data;
  }

  forgetPassword(var email)async{

    var url = Uri.parse(globals.public_uri+"forgot-password");
    var body = jsonEncode({"email":email});

    var response = await http.post(url,body: body, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }
    );

    var data = jsonDecode(response.body);
    // print("saeeeeeeeeeeed data: "+ jsonDecode(response.body).toString());

    return data;
  }

  resetForgettrnPassword(var password,var confirmPassword, var token, var notificationToken)async{

    var url = Uri.parse(globals.public_uri+"Authentication/ResetPassword");
    var body = jsonEncode({"newPassword":password,"confirmPassword":confirmPassword,"notificationToken":notificationToken});

    var response = await http.post(url,body: body, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",
      "Authorization":"Bearer "+  token.toString()

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }
    );


    var data = jsonDecode(response.body);
    // print("saeeeeeeeeeeed data: "+ jsonDecode(response.body).toString());

    return data;
  }
  setPassword(var email,var code,var password,var passwordConfirmation)async{
    // print("Niaaaaaa saeed1");

    var url = Uri.parse(globals.public_uri+"reset-password");
    // print("Niaaaaaa saeed2");
    int codee = int.parse(code);

    var body = jsonEncode({
    "email":email,
    "code":code,
    "password":password,
      "password_confirmation": passwordConfirmation
    }
    );
    // print("Niaaaaaa saeed3");

    var response = await http.post(url,body: body, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }
    );

    // print("Niaaaaaa saeed4");

    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed data: "+ data.toString());

    return data;
  }


  checkToken(var token)async{
    var url = Uri.parse(globals.public_uri+'check-token');
    // var body = jsonEncode({"userName":userName,"password":password});
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",
    "Authorization":"Bearer "+  token.toString()

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }


    );
    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed token data: "+ data.toString());
    return data;
  }


  updateAvatar( var img, var token)async{

    var url = Uri.parse("${globals.public_uri}profile/avatar");

    var head = {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",
      "Authorization": "Bearer $token"
    };


    var takenPicture = await http.MultipartFile.fromPath("avatar", img!.path);


    var request =  http.MultipartRequest("POST", url);


    // request.
    request.headers.addAll(head) ;

    // request.
    request.files.add(takenPicture);
    // var response = await request.send();
    var streamedResponse  = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print("saeeeeeeeeeeed data: $token");
    print("saeeeeeeeeeeed data: ${response.request}");

    print("saeeeeeeeeeeed data: $response");
    print("saeeeeeeeeeeed data: ${response.statusCode}");

    print("saeeeeeeeeeeed data: ${response.body}");

    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed data: ${jsonDecode(response.body)}");

    return data;
  }


  updateProfile(var name,var phone,var phoneCode,var companyName,var companyAddress, var token)async{
    var url = Uri.parse(globals.public_uri+'profile');
    var body = jsonEncode({
      "name":name,
      "phone":phone,
      "phone_code":phoneCode,
      "company_name":companyName,
      "company_address":companyAddress,

    });
    var response = await http.put(url, body: body,headers: {
      "Accept-Language": global_methods.getLanguage(),
      "Accept": "application/json",
      "content-type": "application/json",
    "Authorization": "Bearer $token"

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }


    );
    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed data: "+ data.toString());
    print("saeeeeeeeeeeed body: "+ body.toString());
    return data;
  }

  changePassword(var oldPassword,var password,var passwordConfirmation, var token)async{
    // print("Niaaaaaa saeed1");

    var url = Uri.parse(globals.public_uri+"change-password");
    // print("Niaaaaaa saeed2");

    var body = jsonEncode({
      "current_password":oldPassword,
      "password":password,
      "password_confirmation": passwordConfirmation
    }
    );
    // print("Niaaaaaa saeed3");

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

    // print("Niaaaaaa saeed4");

    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed data: "+ data.toString());

    return data;
  }


  //not ready


  deleteAccount(var token)async{
    var url = Uri.parse(globals.public_uri+'Manage/DeleteMyAccount');
    // var body = jsonEncode({"userName":userName,"password":password});
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",
      "Authorization":"Bearer "+  token.toString()

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }


    );
    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed token data: "+ data.toString());
    return data;
  }
  logout(var token)async{
    var url = Uri.parse(globals.public_uri+'logoutcode');
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      "Accept-Language": global_methods.getLanguage(),
      "content-type": "application/json",
      "Authorization":"Bearer "+  token.toString()

    }).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          return http.Response('Errorr', 408);
        }


    );
    print("saeeeeeeeeeeed token data: "+ response.body.toString());
    print("saeeeeeeeeeeed token data: "+ response.statusCode.toString());

    var data = jsonDecode(response.body);
    print("saeeeeeeeeeeed token data: "+ data.toString());
    return data;
  }


}