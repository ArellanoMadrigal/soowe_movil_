import 'package:dio/dio.dart';
import 'package:logger/logger.dart'; // delete after repairing the methods placement

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
            headers: {'Accept': 'application/json'},
          ),
        );

  Dio get dio => _dio;

  // Method to get auth token after login
  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Method to get the current auth token
  String? getAuthToken() {
    return _authToken;
  }

  // Method to clean auth token after login out
  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
   if (_authToken == null) {
     throw Exception("No has iniciado sesión");
   }

   try {
     final response = await _dio.get(
       "/notifications",
       options: Options(
         headers: {
           'Authorization': "Bearer $_authToken",
         },
       ),
     );

     return List<Map<String, dynamic>>.from(response.data['notifications']);
   } on DioException catch (e) {
     _logger.e("Error al obtener notificaciones: ${e.message}");
     return [];
   }
 }
}