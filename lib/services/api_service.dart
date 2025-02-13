import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio;
  String? _authToken;
  final Logger _logger = Logger();

  ApiService._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: "https://soowe-apidata.onrender.com/",
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        );

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  String? getAuthToken() => _authToken;

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> getUserProfile(String? userId) async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    if (userId == null) {
      throw Exception("ID de usuario no disponible");
    }

    try {
      final response = await _dio.get(
        "/usuarios/$userId",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      debugPrint('Respuesta getUserProfile: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      throw Exception("Error al obtener datos del perfil");
    } on DioException catch (e) {
      debugPrint('Error en getUserProfile: ${e.response?.data}');
      throw Exception(handleError(e));
    } catch (e) {
      debugPrint('Error inesperado en getUserProfile: $e');
      throw Exception('Error al obtener perfil de usuario');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    if (_authToken == null) {
      throw Exception("No has iniciado sesión");
    }

    try {
      final response = await _dio.get(
        "/notifications",
        options: Options(headers: {'Authorization': "Bearer $_authToken"}),
      );

      debugPrint('Respuesta fetchNotifications: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['notifications'] != null) {
          return List<Map<String, dynamic>>.from(response.data['notifications']);
        }
        return [];
      }
      throw Exception("Error al obtener notificaciones");
    } on DioException catch (e) {
      debugPrint('Error en fetchNotifications: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception("Sesión expirada");
      }
      return [];
    } catch (e) {
      debugPrint('Error inesperado en fetchNotifications: $e');
      return [];
    }
  }

  String handleError(DioException e) {
    if (e.response?.statusCode == 500) {
      return "Error del servidor. Por favor, intenta más tarde";
    } else if (e.response?.statusCode == 401) {
      return "Sesión expirada";
    } else if (e.response?.statusCode == 404) {
      return "Recurso no encontrado";
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return "Tiempo de conexión agotado";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return "Tiempo de respuesta agotado";
    }
    return "Error de conexión. Verifica tu conexión a internet";
  }
}