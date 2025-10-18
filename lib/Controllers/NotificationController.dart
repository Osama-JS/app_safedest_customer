import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:save_dest_customer/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {


  @override
  void onInit() {
    super.onInit();
    _initNotificationSystem();
  }

  Future<void> _initNotificationSystem() async {
    await requestNotificationPermission();
    await manageTopicSubscription();
    await _setupFirebaseMessagingListeners();
  }

  Future<void> requestNotificationPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> manageTopicSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySubscribed = prefs.getBool('News') ?? false;

    if (!alreadySubscribed) {
      await FirebaseMessaging.instance.subscribeToTopic('News');
      await prefs.setBool('News', true);
    }
  }

  Future<void> _setupFirebaseMessagingListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotification(message, showSnackbar: true);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotification(message);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotification(initialMessage);
    }
  }

  Future<void> _handleNotification(RemoteMessage message, {bool showSnackbar = false}) async {
    final notification = message.notification;
    if (notification == null) return;

    final newNotification = {
      "title": notification.title ?? "No Title",
      "body": notification.body ?? "No Body",
      // "phone": globals.user["data"]["phoneNumber"].toString(),
      "time": DateTime.now(),
    };


    if (showSnackbar) {
      Get.snackbar(
        newNotification['title'].toString(),
        newNotification['body'].toString(),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        // onTap: (_) => Get.to(() => NotificationPage()),
        onTap: (_) => Get.to(() =>  Dashboard()),
      );
    }
  }


}
