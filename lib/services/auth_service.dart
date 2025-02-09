import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register
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
        '/auth/registerMobile',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'contrasena': contrasena,
          'telefono': telefono,
          'direccion': direccion,
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al registrar el usuario');
      }
    } on DioException catch (e) {
      throw Exception('Error en registro: ${e.message}');
    }
  }

  // Login
  Future<bool> loginUser({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/loginMobile',
        data: {
          'correo': correo,
          'contrasena': contrasena,
        },
      );

      final token = response.data['token'];
      _apiService.setAuthToken(token);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al iniciar sesión');
      }
    } on DioException catch (e) {
      throw Exception('Error en login: ${e.message}');
    }
  }

  // Logout
  void logout() {
    _apiService.clearAuthToken();
  }
}
