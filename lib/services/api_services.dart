import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiService {
 static final ApiService _instance = ApiService._internal();
 factory ApiService() => _instance;

 final Dio _dio;
 String? _authToken;
 final Logger _logger = Logger();

 ApiService._internal()
     : _dio = Dio(
         BaseOptions(
           baseUrl: "https://api-soonwe-blue.onrender.com/",
           connectTimeout: const Duration(seconds: 60),
           receiveTimeout: const Duration(seconds: 60),
           headers: {
             'Accept': 'application/json',
           },
         ),
       );

 Future<bool> login(String userName, String password) async {
   try {
     final response = await _dio.post(
       "/users/login",
       data: {
         "user_name": userName,
         "password": password,
       },
       options: Options(
         headers: {
           'Content-Type': 'application/json',
         },
       ),
     );

     _authToken = response.data['token'];
     _dio.options.headers['Authorization'] = "Bearer $_authToken";
     return true;
   } on DioException catch (e) {
     _logger.e("Error de conexión: ${e.message}");
     return false;
   }
 }

 Future<void> logout() async {
   try {
     if (_authToken != null) {
       await _dio.post("/users/logout",
           options: Options(
             headers: {'Authorization': "Bearer $_authToken"},
           ));
     }
   } catch (e) {
     _logger.e("Error en logout: $e");
   } finally {
     _authToken = null;
     _dio.options.headers.remove('Authorization');
     _dio.options = BaseOptions(
       baseUrl: "https://api-soonwe-blue.onrender.com/",
       connectTimeout: const Duration(seconds: 60),
       receiveTimeout: const Duration(seconds: 60),
       headers: {
         'Accept': 'application/json',
       },
     );
   }
 }

 Future<List<dynamic>> fetchAllUsers({int limit = 10, int page = 1}) async {
   if (_authToken == null) {
     throw Exception("No has iniciado sesión");
   }

   try {
     final response = await _dio.get(
       "/users",
       queryParameters: {
         'page': page,
         'limit': limit,
       },
     );

     return response.data['users'];
   } on DioException catch (e) {
     _logger.e("Error al obtener usuarios: ${e.message}");
     return [];
   }
 }

 Future<List<Map<String, dynamic>>> fetchAllRequests() async {
   if (_authToken == null) {
     throw Exception("No has iniciado sesión");
   }

   try {
     final response = await _dio.get(
       "/requests",
       options: Options(
         headers: {
           'Authorization': "Bearer $_authToken",
         },
       ),
     );

     return List<Map<String, dynamic>>.from(response.data['requests']);
   } on DioException catch (e) {
     _logger.e("Error al obtener solicitudes: ${e.message}");
     return [];
   }
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

 Future<Map<String, dynamic>> fetchServiceDetails(String serviceTitle) async {
   if (_authToken == null) {
     throw Exception("No has iniciado sesión");
   }

   try {
     final response = await _dio.get(
       "/services",
       queryParameters: {
         'title': serviceTitle,
       },
       options: Options(
         headers: {
           'Authorization': "Bearer $_authToken",
         },
       ),
     );

     return response.data['service'];
   } on DioException catch (e) {
     _logger.e("Error al obtener detalles del servicio: ${e.message}");
     rethrow;
   }
 }

 Future<List<dynamic>> fetchNursesForService(String serviceId) async {
   if (_authToken == null) {
     throw Exception("No has iniciado sesión");
   }

   try {
     final response = await _dio.get(
       "/services/$serviceId/nurses",
       options: Options(
         headers: {
           'Authorization': "Bearer $_authToken",
         },
       ),
     );

     return response.data['nurses'];
   } on DioException catch (e) {
     _logger.e("Error al obtener enfermeros para el servicio: ${e.message}");
     return [];
   }
 }

 Future<bool> addUser({
   required String name,
   required String userName,
   required String password,
   required String foto,
   required String verificado,
 }) async {
   if (_authToken == null) return false;

   try {
     await _dio.post(
       "/users",
       data: {
         "name": name,
         "user_name": userName,
         "password": password,
         "foto": foto,
         "verificado": verificado,
       },
       options: Options(
         headers: {
           'Content-Type': 'application/json',
           'Authorization': "Bearer $_authToken",
         },
       ),
     );
     return true;
   } catch (e) {
     _logger.e("Error al agregar usuario: $e");
     return false;
   }
 }

 Future<bool> editUser({
   required String userId,
   required String name,
   required String userName,
   required String password,
   required String foto,
   required String verificado,
 }) async {
   if (_authToken == null) return false;

   try {
     await _dio.put(
       "/users/$userId",
       data: {
         "name": name,
         "user_name": userName,
         "password": password,
         "foto": foto,
         "verificado": verificado,
       },
       options: Options(
         headers: {
           'Content-Type': 'application/json',
           'Authorization': "Bearer $_authToken",
         },
       ),
     );
     return true;
   } catch (e) {
     _logger.e("Error al editar usuario: $e");
     return false;
   }
 }

 Future<bool> deleteUser(String userId) async {
   if (_authToken == null) return false;

   try {
     await _dio.delete(
       "/users/$userId",
       options: Options(
         headers: {'Authorization': "Bearer $_authToken"},
       ),
     );
     return true;
   } catch (e) {
     _logger.e("Error al eliminar usuario: $e");
     return false;
   }
 }
}

