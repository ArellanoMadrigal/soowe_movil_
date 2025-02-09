import 'package:dio/dio.dart';
import 'api_service.dart';

class RequestService {
  final ApiService _apiService = ApiService();

  // Get all requests
  Future<List<Request>> getAllRequests({
    required int usuarioId,
    required int organizacionId,
  }) async {
    try {
      final response = await _apiService.dio.get(
        '/solicitudes',
        queryParameters: {
          'usuario_id': usuarioId,
          'organizacion_id': organizacionId,
        },
      );

      if (response.statusCode == 200) {
        List<Request> requests = (response.data as List)
            .map((data) => Request.fromJson(data))
            .toList();
        return requests;
      } else {
        throw Exception('Error al obtener las solicitudes');
      }
    } on DioException catch (e) {
      throw Exception('Error en la solicitud: ${e.message}');
    }
  }
}

class Request {
  final int id;
  final int usuarioId;
  final int pacienteId;
  final int? organizacionId;
  final int? enfermeroId;
  final String estado;
  final String metodoPago;
  final DateTime fechaSolicitud;
  final DateTime? fechaServicio;
  final int solicitudId;
  final String comentarios;

  Request({
    required this.id,
    required this.usuarioId,
    required this.pacienteId,
    this.organizacionId,
    this.enfermeroId,
    required this.estado,
    required this.metodoPago,
    required this.fechaSolicitud,
    this.fechaServicio,
    required this.solicitudId,
    this.comentarios = '',
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      usuarioId: json['usuario_id'],
      pacienteId: json['paciente_id'],
      organizacionId: json['organizacion_id'],
      enfermeroId: json['enfermero_id'],
      estado: json['estado'],
      metodoPago: json['metodo_pago'],
      fechaSolicitud: DateTime.parse(json['fecha_solicitud']),
      fechaServicio: json['fecha_servicio'] != null
          ? DateTime.parse(json['fecha_servicio'])
          : null,
      solicitudId: json['solicitud_id'],
      comentarios: json['comentarios'] ?? '',
    );
  }

    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'paciente_id': pacienteId,
      'organizacion_id': organizacionId,
      'enfermero_id': enfermeroId,
      'estado': estado,
      'metodo_pago': metodoPago,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'fecha_servicio': fechaServicio?.toIso8601String(),
      'solicitud_id': solicitudId,
      'comentarios': comentarios,
    };
  }
}
