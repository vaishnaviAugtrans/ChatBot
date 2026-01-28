import 'dart:async';
import 'package:chatbot/util/AppPrefrences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';
import '../../util/Constants.dart';
import '../../util/colors.dart';
import '../../util/dimensions.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{

  bool _isTextVisible = false;
  double _logoOpacity = 0.0;

  @override
  void initState(){
    super.initState();
    _startLogoAnimation();
    _startTextAnimation();
    _navigateToNextScreen();
  }

  void _startLogoAnimation() {
    // Fade in the logo after a small delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });
  }

  void _startTextAnimation() {
    // Fade in the text after a longer delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTextVisible = true;
      });
    });
  }

  void _navigateToNextScreen() {
    // Redirect to the login screen after 4 seconds
    Timer(const Duration(seconds: 4), () async {

      //Save login token in preferances
      String? loginToken =  await AppPreferences.getAccessToken() ;
      // print("checkLoginToken $loginToken");

      //check preferences empty
      if (loginToken == null || loginToken.isEmpty) {
        context.go(AppRoutes.login);
      }else{
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6EF),
      body: Column(
        children: [
          // Spacer to push the logo to the center
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(left:50.0,top:0.0,right: 50.0,bottom: 0.0),
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/png/splash_image.png', // Change to your logo
                      width: 200,
                      height: 200,// Adjust size if needed
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Text at the bottom
          Padding(
            padding: EdgeInsets.only(right: Dimensions.level0Padding(context)), // Adjust as needed
            child: Text(
              "Welcome to Support Chat",
              style: GoogleFonts.poppins(
                fontSize: Dimensions.xlargeTextSize(context),
                color: AppColors.title_blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:40.0,top:0.0,right: 40.0,bottom: 0.0),
            child: Text(
              textAlign: TextAlign.center,
              "Connect with a support expert for service details and updates.",
              style: GoogleFonts.poppins(
                fontSize: Dimensions.mediumTextSize(context),
                color: AppColors.title_blue,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Spacer()
        ],
      ),
    );
  }
}