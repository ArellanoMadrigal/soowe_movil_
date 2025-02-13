import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
 static final AuthService _instance = AuthService._internal();
 factory AuthService() => _instance;

 final ApiService _apiService = ApiService();
 SharedPreferences? _prefs;
 String? _currentUserId;
 String? _userName;

 AuthService._internal() {
   _initPrefs();
 }

 Future<void> _initPrefs() async {
   try {
     _prefs = await SharedPreferences.getInstance();
     _currentUserId = _prefs?.getString('userId');
     _userName = _prefs?.getString('userName');
   } catch (e) {
     debugPrint('Error inicializando SharedPreferences: $e');
   }
 }

 Future<bool> registerUser({
   required String nombre,
   required String apellido,
   required String correo,
   required String contrasena,
   required String telefono,
   required String direccion,
 }) async {
   try {
     final response = await _apiService.dio.post(
       'registerMobile',
       data: {
         'nombre': nombre,
         'apellido': apellido,
         'correo': correo,
         'contrasena': contrasena,
         'telefono': telefono,
         'direccion': direccion,
       },
     );

     debugPrint('Respuesta registro: ${response.data}');
     return response.statusCode == 200;
   } on DioException catch (e) {
     debugPrint('Error en registro: ${e.response?.data}');
     throw Exception(_apiService.handleError(e));
   } catch (e) {
     debugPrint('Error general en registro: $e');
     throw Exception('Error inesperado en registro');
   }
 }

 Future<bool> loginUser({
   required String correo,
   required String contrasena,
 }) async {
   try {
     if (_prefs == null) {
       await _initPrefs();
     }

     debugPrint('Intentando login con: $correo');
     final response = await _apiService.dio.post(
       'loginMobile',
       data: {
         'correo': correo,
         'contrasena': contrasena,
       },
     );

     debugPrint('Respuesta login: ${response.data}');

     if (response.statusCode == 200 && response.data != null) {
       final token = response.data['token'];
       if (token == null) {
         throw Exception('Token no recibido');
       }

       _currentUserId = response.data['_id'];
       _userName = '${response.data['nombre']} ${response.data['apellido']}'.trim();

       await _prefs?.setString('userId', _currentUserId ?? '');
       await _prefs?.setString('userName', _userName ?? '');
       _apiService.setAuthToken(token);

       return true;
     }
     return false;
   } on DioException catch (e) {
     debugPrint('Error DioException en login: ${e.response?.data}');
     throw Exception(_apiService.handleError(e));
   } catch (e) {
     debugPrint('Error general en login: $e');
     throw Exception('Error inesperado al iniciar sesión');
   }
 }

 String? getCurrentUserId() {
   try {
     _currentUserId ??= _prefs?.getString('userId');
     return _currentUserId;
   } catch (e) {
     debugPrint('Error al obtener userId: $e');
     return null;
   }
 }

 String? getUserName() {
   try {
     _userName ??= _prefs?.getString('userName');
     return _userName;
   } catch (e) {
     debugPrint('Error al obtener userName: $e');
     return null;
   }
 }

 Future<void> logout() async {
   try {
     if (_prefs == null) {
       await _initPrefs();
     }
     await _prefs?.clear(); // Limpia todas las preferencias
     _currentUserId = null;
     _userName = null;
     _apiService.clearAuthToken();
   } catch (e) {
     debugPrint('Error en logout: $e');
     throw Exception('Error al cerrar sesión');
   }
 }

 bool isLoggedIn() {
   final hasUserId = _currentUserId != null;
   final hasToken = _apiService.getAuthToken() != null;
   return hasUserId && hasToken;
 }

 Future<void> checkAuthStatus() async {
   try {
     if (_prefs == null) {
       await _initPrefs();
     }
     _currentUserId = _prefs?.getString('userId');
     _userName = _prefs?.getString('userName');
   } catch (e) {
     debugPrint('Error checking auth status: $e');
     throw Exception('Error al verificar estado de autenticación');
   }
 }
}