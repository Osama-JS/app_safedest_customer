import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Dashboard.dart';
import 'Globals/MyColors.dart';
import 'Helpers/Users.dart';
import 'Views/Users/Login.dart';
import 'Views/Widgets/ProgressWithIcon.dart';
import 'shared_prff.dart';
import 'Globals/global_methods.dart' as global_methods;
import 'Globals/global.dart' as globals;
import 'package:get/get.dart';

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashState();
}

class SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  User_Helper user = new User_Helper();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  startapp() async {
    messaging.getToken().then((token) {
      if (token != null) {
        globals.notificationToken = token.toString();
        print("MY FCM Token : $token");
      }
    });
    print("saeeeeeeeeeeeeeeeeeeeeed : " + Token_pref.getToken().toString());

    if (!await global_methods.isInternetAvailable()) {
      if (mounted) {
        global_methods.showInternetConnectionDialog(context, () {
          startapp(); // إعادة المحاولة
        });
      }
      return;
    } else if (Token_pref.getToken() == "") {
      Get.offAll(() => Login());
    } else {
      try {
        print(
          "saeeeeeeeeeeeeeeeeeeeeed2 : " + Token_pref.getToken().toString(),
        );

        var Data = await user.checkToken(Token_pref.getToken());
        if (Data["status"] == 200) {
          globals.user = await Data;
          Get.offAll(() => Dashboard());
        } else {
          Get.offAll(() => Login());
        }
      } catch (e) {
        global_methods.sendError("splash : $e");

        Get.offAll(() => Login());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    if (Selected_Language.getLanguage() == null) {
      Selected_Language.setLanguage("ar");
    }

    Future.delayed(const Duration(seconds: 2), () async {
      startapp();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );

    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // شعار التطبيق
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.local_shipping,
                              size: 60,
                              color: Color(0xFFd40019),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // اسم التطبيق
                    Text(
                      'app_name'.tr,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // شعار التطبيق
                    Text(
                      'app_slogan'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // مؤشر التحميل
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // معلومات الإصدار أسفل الشاشة
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          '${'version'.tr} 1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ),
    );
  }
}
