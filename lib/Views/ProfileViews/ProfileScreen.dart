import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:save_dest_customer/Views/ProfileViews/ChangePassword.dart';
import 'package:save_dest_customer/Views/ProfileViews/EditProfile.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Globals/MyColors.dart';
import '../../../shared_prff.dart';
import '../../Helpers/Users.dart';
import '../../Services/InitialService.dart';
import '../../splash.dart';
import '../../Globals/global.dart' as globals;
import '../../Globals/global_methods.dart' as global_methods;
import '../Widgets/custom_image_view.dart';

class ProfileScreenPage extends StatefulWidget {
  const ProfileScreenPage({super.key});

  @override
  State<ProfileScreenPage> createState() => _ProfileScreenPageState();
}

class _ProfileScreenPageState extends State<ProfileScreenPage> with SingleTickerProviderStateMixin {
  final iniService = InitialService.to;

  @override
  void initState() {
    super.initState();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'warning'.tr,
                    style: TextStyle(
                      color: MyColors.lightPrimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'sureLogout'.tr,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.lightPrimaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          logout();
                        },
                        child: Text(
                          'confirm'.tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  User_Helper helperData =  User_Helper();

  logout() async {
    if (!await global_methods.isInternetAvailable()) {
      global_methods.errorView(context, 'checkInternetConnection'.tr);
    } else {
      global_methods.showDialogLoading(context: context);

      try {
        var data = await helperData.logout(Token_pref.getToken());
        global_methods.hideLoadingDialog();
        if (data["status"] == 200) {
          Get.snackbar("success".tr, data["message"]);
          Token_pref.setToken("");
          User_pref.setUser("");
          globals.user=null;
          Get.off(Splash());
        } else {
          Get.snackbar("error".tr, data["message"]);
          print(data["message"]);
        }
      } catch (e) {
        global_methods.hideLoadingDialog();

        // Get.snackbar("error".tr, e.toString());
        Get.snackbar("error".tr, "somethingWentWrong".tr);
        print(e.toString());
      }
    }
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: MyColors.lightPrimaryColor),
          title: Text(title, style: TextStyle(fontSize: 16)),
          trailing: Icon(
              Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

    return Scaffold(
      backgroundColor: Theme_pref.getTheme() == 0
          ? MyColors.lightBackground
          : MyColors.darkBackground,
      appBar:
      AppBar(
        backgroundColor: MyColors.backgroundColor,
        surfaceTintColor: MyColors.backgroundColor,
        title:Text("profile".tr),
        centerTitle: true,
              actions: [
                IconButton(onPressed: (){
                  _showConfirmationDialog();

                }, icon: Icon(Icons.logout)),
              ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Obx(()=> Container(
                          decoration: BoxDecoration(
                              color: MyColors.primaryColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(100)
                          ),
                          padding: const EdgeInsets.all(16),
                          child:
                          iniService.userImage.value != ""
                              ? CustomImageView(
                            imagePath:  iniService.userImage.value ,
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            onTap: () {

                            },
                          )
                              :
                          Icon(Icons.person, size: 38,
                            color: MyColors.primaryColor,)
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(()=> Text(
                        iniService.userName.value,
                        style: TextStyle(fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: MyColors.lightPrimaryColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(()=> Text(
                        iniService.userEmail.value,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSettingsItem(Icons.person, 'editProfile'.tr, () {
                Get.to(EditProfile());
              }),
              _buildSettingsItem(Icons.password, 'changePassword'.tr, () {
                Get.to(ChangePassword());
              }),

              SizedBox(
                width: double.maxFinite,
                child: Divider(
                  color: MyColors.borderColor.withAlpha(90),
                ),
              ),
              ListTile(

                leading:
                    Icon(Icons.language,size: 20,),


                title: Text(
                  "display_language".tr,
                  style:global_methods.textBody(),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      backgroundColor: MyColors.backgroundColor,
                      context: context,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildListTile(
                                context,
                                "ar",
                                "AE",
                                selectedLanguage,
                              ),
                              const SizedBox(height: 10),
                              buildListTile(
                                context,
                                "en",
                                "US",
                                selectedLanguage,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/flags/${selectedLanguage.value}.png'),
                    ),
                  ),
                ),


                // Padding(
                //   padding: const EdgeInsetsDirectional.only(start: 24),
                //   child: Obx(() => DropdownButton<String>(
                //     menuMaxHeight: 700,
                //     value: selectedLanguage.value,
                //     items: ["ar","en"].map((language) {
                //       return DropdownMenuItem<String>(
                //         value: language,
                //         child: Image.asset(
                //           'assets/flags/$language.png',
                //           width: 32,
                //         ),
                //       );
                //     }).toList(),
                //     onChanged: (value) {
                //       if (value != null) {
                //         String subValue = value=="ar"?"AE":"US";
                //         selectedLanguage.value=value;
                //         Get.updateLocale(Locale(value, subValue));
                //         Selected_Language.setLanguage(value);
                //         iniService.getData();
                //       }
                //     },
                //   ),
                //   ),
                // )
              ),
              // _buildSettingsItem(Icons.help, 'helpCenter'.tr, () {
              //   Get.to(HelpCenterPage());
              // }),
              _buildSettingsItem(Icons.shield, 'privacyPolicy'.tr, () async {
                // final Uri _url = Uri.parse("https://www.nawaam.com/Home/Privacy");
                // if (!await launchUrl(_url)) {
                //   throw Exception('Could not launch $_url');
                // }
              }),
            ],
          ),
        ),
      ),
    );

  }

  RxString selectedLanguage = Selected_Language.getLanguage()!.obs;

  Widget buildListTile(BuildContext context ,String languageCode , String countryCode , RxString selectedLanguage) {
    return ListTile(
      leading: ClipOval(
        child: Image.asset(
          'assets/flags/$languageCode.png',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(languageCode == "ar" ? "العربية" : "English"),
      trailing: selectedLanguage.value == languageCode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        selectedLanguage.value = languageCode;
        String subValue = languageCode == "ar" ? "AE" : "US";
        Get.updateLocale(Locale(languageCode, subValue));
        Selected_Language.setLanguage(languageCode);
        // iniService.getData();
        Navigator.pop(context);
      },
    );
  }


}