import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../Dashboard.dart';
import '../../Globals/MyColors.dart';
import '../../theme/app_theme.dart';
import '../../Views/Widgets/CustomTextField.dart';
import '../../Views/Widgets/CustomButton.dart';
import '../../Helpers/Users.dart';
import '../../shared_prff.dart';
import '../../Globals/global_methods.dart' as gm;
import '../../Globals/global.dart' as globals;
import 'ForgetPassword.dart';
import 'SimpleRegister.dart';

class Login extends StatefulWidget {
  final bool canPop;

  const Login({super.key, this.canPop = false});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  DateTime? _lastBackPressed;

  User_Helper user = User_Helper();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Prevent multiple login attempts
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!await gm.isInternetAvailable()) {
        if (mounted) {
          gm.errorView(context, 'checkInternetConnection'.tr);
        }
        return;
      }

      var data = await user.login(
        _emailController.text.trim(),
        _passwordController.text,
        globals.notificationToken, // notification token
      );

      if (mounted) {
        if (data['status'] == 200) {
          // Save user data and token based on API response structure
          await User_pref.setUser(data['data']['customer'].toString());
          await Token_pref.setToken(data['data']['token']);

          // Set globals.user to match the expected structure
          globals.user = data;

          // Navigate to dashboard
          Get.offAll(() => Dashboard());
        } else {
          _showErrorDialog(data['message'] ?? 'loginFailed'.tr);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('unexpectedErrorOccurred'.tr);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('loginErrorTitle'.tr),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );

    return PopScope(
      canPop: widget.canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          globals.fromLoginPassword = false;

          if (widget.canPop) {
            Get.back();
          } else {
            DateTime now = DateTime.now();
            if (_lastBackPressed == null ||
                now.difference(_lastBackPressed!) >
                    const Duration(seconds: 2)) {
              _lastBackPressed = now;
              Get.snackbar('warning'.tr, 'pressAgainToExit'.tr);
            } else {
              if (Platform.isAndroid) {
                await SystemChannels.platform.invokeMethod(
                  'SystemNavigator.pop',
                );
              } else if (Platform.isIOS) {
                exit(0);
              }
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacing6),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: MyColors.backgroundColor,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
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
                            backgroundImage: AssetImage(
                              'assets/flags/${selectedLanguage.value}.png',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Header with Logo and Title
                  _buildHeader(),

                  const SizedBox(height: 60),

                  // Login Form
                  _buildLoginForm(),

                  const SizedBox(height: 32),

                  // Login Button
                  _buildLoginButton(),

                  const SizedBox(height: 20),

                  // Remember Me and Forgot Password
                  _buildRememberMe(),

                  const SizedBox(height: 40),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  RxString selectedLanguage = Selected_Language.getLanguage()!.obs;

  Widget buildListTile(
      BuildContext context,
      String languageCode,
      String countryCode,
      RxString selectedLanguage,
      ) {
    return ListTile(
      leading: ClipOval(
        child: Image.asset(
          'assets/flags/$languageCode.png',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(languageCode == "ar" ? "عربي" : "English"),
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


  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: MyColors.whiteColor,
            borderRadius: BorderRadius.circular(AppTheme.radius2XL),
            boxShadow: AppTheme.shadowLG,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radius2XL),
            child: Image.asset(
              'assets/images/logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.local_shipping,
                  size: 50,
                  color: MyColors.primaryColor,
                );
              },
            ),
          ),
        ),

        const SizedBox(height: AppTheme.spacing5),

        // App Name
        Text(
          'app_name'.tr,
          style: AppTheme.headlineLarge.copyWith(
            fontWeight: AppTheme.bold,
            color: MyColors.primaryColor,
          ),
        ),

        const SizedBox(height: AppTheme.spacing2),

        // Subtitle
        Text(
          'welcomeToCustomerApp'.tr,
          style: AppTheme.bodyLarge.copyWith(
            color: MyColors.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email Field
        CustomTextField(
          controller: _emailController,
          label: 'emailOrUsernameLabel'.tr,
          hint: 'enterEmailOrUsernameHint'.tr,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'pleaseEnterEmailError'.tr;
            }
            return null;
          },
        ),

        const SizedBox(height: AppTheme.spacing5),

        // Password Field
        CustomTextField(
          controller: _passwordController,
          label: 'passwordFieldLabel'.tr,
          hint: 'enterPasswordHint'.tr,
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: MyColors.textSecondaryColor,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'pleaseEnterPasswordError'.tr;
            }
            if (value.length < 6) {
              return 'passwordMinLengthError'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return CustomButton(
      text: 'loginButtonText'.tr,
      onPressed: _isLoading ? null : _handleLogin,
      isLoading: _isLoading,
      icon: Icons.login,
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: MyColors.primaryColor,
        ),
        Text('rememberMeText'.tr, style: AppTheme.bodyMedium),
        const Spacer(),
        TextButton(
          onPressed: () {
            Get.to(() => const ForgetPassword());
          },
          child: Text(
            'forgotPasswordText'.tr,
            style: AppTheme.bodyMedium.copyWith(
              color: MyColors.primaryColor,
              fontWeight: AppTheme.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const SizedBox(height: AppTheme.spacing4),

        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'dontHaveAccountText'.tr,
              style: AppTheme.bodyMedium.copyWith(
                color: MyColors.textSecondaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => const SimpleRegister());
              },
              child: Text(
                'createNewAccountText'.tr,
                style: AppTheme.bodyMedium.copyWith(
                  color: MyColors.primaryColor,
                  fontWeight: AppTheme.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacing4),

        Text(
          'byLoggingInYouAgreeText'.tr,
          style: AppTheme.bodySmall.copyWith(color: MyColors.neutral400),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Show terms of service
              },
              child: Text(
                'termsOfServiceText'.tr,
                style: AppTheme.bodySmall.copyWith(
                  color: MyColors.primaryColor,
                ),
              ),
            ),
            Text(
              'andText'.tr,
              style: AppTheme.bodySmall.copyWith(color: MyColors.neutral400),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show privacy policy
              },
              child: Text(
                'privacy_policy'.tr,
                style: AppTheme.bodySmall.copyWith(
                  color: MyColors.primaryColor,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          '${'versionNumber'.tr} 1.0.0',
          style: AppTheme.bodySmall.copyWith(color: MyColors.neutral400),
        ),
      ],
    );
  }
}