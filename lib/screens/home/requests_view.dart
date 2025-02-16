import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestsView extends StatelessWidget {
  final List<Map<String, dynamic>> requests;

  const RequestsView({
    super.key, 
    required this.requests
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mis Solicitudes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: const [
              Tab(
                icon: Icon(Icons.healing_outlined),
                text: 'Activas',
              ),
              Tab(
                icon: Icon(Icons.history_outlined),
                text: 'Historial',
              ),
            ],
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.outline,
          ),
        ),
        body: TabBarView(
          children: [
            _RequestList(
              requests: requests.where((r) => r['status'] == 'active').toList(),
              isActive: true,
            ),
            _RequestList(
              requests: requests.where((r) => r['status'] != 'active').toList(),
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final bool isActive;

  const _RequestList({
    required this.requests,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.healing_outlined : Icons.history_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? 'No tienes solicitudes activas'
                  : 'No tienes solicitudes en tu historial',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'Las solicitudes aparecerán aquí cuando las crees'
                  : 'El historial de solicitudes aparecerá aquí',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isActive
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        isActive
                            ? Icons.medical_services_outlined
                            : Icons.check_circle_outline,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['service']['title'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isActive ? Icons.timer_outlined : Icons.check_circle,
                                size: 16,
                                color: isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'En progreso' : 'Completada',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isActive
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.secondary,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        _showRequestDetails(context, request);
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Ver detalles'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles de la Solicitud',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Estado de la Solicitud
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.pending_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Pendiente de Asignación de Enfermero',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow('Servicio', request['service']['title']),
                  _buildDetailRow('Fecha', request['date']),
                  _buildDetailRow('Hora', request['time']),
                  const Divider(),
                  
                  Text(
                    'Información del Paciente',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _buildDetailRow('Nombre', request['patient']['name']),
                  _buildDetailRow('Edad', request['patient']['age'].toString()),
                  _buildDetailRow('Teléfono', request['patient']['phone']),
                  _buildDetailRow('Condición', request['patient']['condition']),
                  const Divider(),
                  
                  Text(
                    'Ubicación',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _buildDetailRow('Dirección', request['location']['address']),
                  const Divider(),
                  
                  Text(
                    'Pago',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _buildDetailRow('Método', 
                    request['payment']['method'] == 'card' 
                      ? 'Tarjeta de Crédito/Débito' 
                      : 'Efectivo'
                  ),
                  _buildDetailRow('Estado de Pago', 'Pago Procesado'),
                  _buildDetailRow('Total', 
                    NumberFormat.currency(
                      symbol: '\$', 
                      decimalDigits: 2
                    ).format(request['service']['price'])
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}