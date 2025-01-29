import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';


void main() {
 runApp(const MyApp());
}

class MyApp extends StatelessWidget {
 const MyApp({super.key});

 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     debugShowCheckedModeBanner: false,
     title: 'Soowe',
     theme: ThemeData(
       colorScheme: ColorScheme.fromSeed(
         seedColor: const Color(0xFF4A90E2),
         brightness: Brightness.light,
       ),
       useMaterial3: true,
       textTheme: GoogleFonts.poppinsTextTheme(),
     ),
     initialRoute: '/login',
     routes: {
       '/login': (context) => const LoginScreen(),
       '/home': (context) => const HomeScreen(),
     },
   );
 }
}