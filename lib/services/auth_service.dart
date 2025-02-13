import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

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
    required String confirmarContrasena,
    String telefono = 'pendiente',    // Valor predeterminado significativo
    String direccion = 'pendiente',   // Valor predeterminado significativo
  }) async {
    try {
      // Validar que la contraseña y la confirmación coincidan
      if (contrasena != confirmarContrasena) {
        throw Exception('Las contraseñas no coinciden');
      }

      final response = await _apiService.dio.post(
        'registerMobile',
        data: {
          'nombre': nombre,
          'apellido': apellido,
          'correo': correo,
          'contrasena': contrasena,
          'telefono': telefono,
          'direccion': direccion
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

  // Método para actualizar el perfil del usuario
  Future<bool> updateUserProfile({
    String? telefono,
    String? direccion,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _apiService.dio.put(
        'updateProfile/$userId',
        data: {
          if (telefono != null) 'telefono': telefono,
          if (direccion != null) 'direccion': direccion,
        },
      );

      debugPrint('Respuesta actualización perfil: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en actualización de perfil: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error general en actualización de perfil: $e');
      throw Exception('Error inesperado al actualizar perfil');
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

  // Método para obtener el perfil del usuario
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _apiService.dio.get('profile/$userId');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      throw Exception('Error al obtener perfil de usuario');
    } on DioException catch (e) {
      debugPrint('Error al obtener perfil: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error general al obtener perfil: $e');
      throw Exception('Error inesperado al obtener perfil');
    }
  }

  // Método para cambiar la contraseña
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      if (newPassword != confirmNewPassword) {
        throw Exception('Las contraseñas nuevas no coinciden');
      }

      final response = await _apiService.dio.put(
        'changePassword/$userId',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      debugPrint('Respuesta cambio contraseña: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en cambio de contraseña: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error general en cambio de contraseña: $e');
      throw Exception('Error inesperado al cambiar contraseña');
    }
  }

  // Método para solicitar restablecimiento de contraseña
  Future<bool> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _apiService.dio.post(
        'requestPasswordReset',
        data: {
          'correo': email,
        },
      );

      debugPrint('Respuesta solicitud reset contraseña: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en solicitud reset contraseña: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error general en solicitud reset contraseña: $e');
      throw Exception('Error inesperado al solicitar reset de contraseña');
    }
  }

  // Método para verificar token de restablecimiento de contraseña
  Future<bool> verifyResetToken({
    required String token,
  }) async {
    try {
      final response = await _apiService.dio.post(
        'verifyResetToken',
        data: {
          'token': token,
        },
      );

      debugPrint('Respuesta verificación token: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en verificación token: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error general en verificación token: $e');
      throw Exception('Error inesperado al verificar token');
    }
  }

  // Método para actualizar contraseña con token de reset
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        throw Exception('Las contraseñas no coinciden');
      }

      final response = await _apiService.dio.post(
        'resetPassword',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      debugPrint('Respuesta reset contraseña: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('Error en reset contraseña: ${e.response?.data}');
      throw Exception(_apiService.handleError(e));
    } catch (e) {
      debugPrint('Error general en reset contraseña: $e');
      throw Exception('Error inesperado al resetear contraseña');
    }
  }
}