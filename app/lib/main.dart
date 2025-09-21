
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language/language_controller.dart';
import 'screens/login_register/splash_screen.dart';
import 'screens/main_screen.dart';
import 'services/storage_service.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageController.init();
  await StorageService.init();
  runApp(EmergencyApp());
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tez Yordam - 84U',
      // title: LanguageController.get('emergency_title'),

      theme: ThemeData(
        fontFamily: 'Nunito',
        useMaterial3: true,
        primarySwatch: Colors.red,

      ),
      home: FutureBuilder<bool>(
        future: _checkFirstTime(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return snapshot.data == true ? SplashScreen() : MainScreen();
        },
      ),
    );
  }

  Future<bool> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey('user_token');
  }


}
