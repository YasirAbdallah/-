import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paligolshir/controllers/splash_page_controller.dart';

class SplashView extends StatelessWidget {
  final SplashController splashController = Get.put(SplashController());
 
  SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
          
           mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset("assets/photos/logo.png", fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
            
            ],
          ),
        ),
      ),
    );
  }
}
