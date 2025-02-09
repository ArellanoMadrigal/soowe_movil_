import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio;
  String? _authToken;

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

  // Method to clean auth token after login out
  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }
}