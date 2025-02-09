import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'solicit_medical.dart';

class ServiceCategory {
  final String id;
  final String title;
  final List<Service> services;

  ServiceCategory({
    required this.id,
    required this.title,
    required this.services,
  });
}

class Service {
  final String id;
  final String title;
  final String description;
  final double price;
  

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    
  });
}

class ListServiceScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const ListServiceScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<ListServiceScreen> createState() => _ListServiceScreenState();
}

class _ListServiceScreenState extends State<ListServiceScreen> {
  final ApiService _apiService = ApiService();
  List<ServiceCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      // Simular carga de datos de la API
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _categories = [
          ServiceCategory(
            id: '1',
            title: 'Servicios básicos',
            services: [
              Service(
                id: '1',
                title: 'Cuidados básicos del adulto mayor',
                description: 'Atención especializada para adultos mayores que requieren asistencia en sus actividades diarias.',
                price: 350.00,
              ),
              Service(
                id: '2',
                title: 'Asistencia en la medicación',
                description: 'Ayuda con la administración de medicamentos según prescripción médica.',
                price: 250.00,
                
              ),
            ],
          ),
          ServiceCategory(
            id: '2',
            title: 'Servicios especializados',
            services: [
              Service(
                id: '3',
                title: 'Terapia física',
                description: 'Sesiones de terapia física personalizada a domicilio.',
                price: 450.00,
                
              ),
              Service(
                id: '4',
                title: 'Rehabilitación post operatoria',
                description: 'Programa de rehabilitación especializado después de cirugías.',
                price: 500.00,
                
              ),
            ],
          ),
          ServiceCategory(
            id: '3',
            title: 'Servicios de emergencia',
            services: [
              Service(
                id: '5',
                title: 'Atención de urgencias',
                description: 'Servicio de atención inmediata para situaciones urgentes.',
                price: 600.00,
                
              ),
              Service(
                id: '6',
                title: 'Monitoreo 24/7',
                description: 'Supervisión continua del paciente durante todo el día.',
                price: 800.00,
                
              ),
            ],
          ),
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('No se pudieron cargar los servicios. Por favor, intenta de nuevo más tarde.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _navigateToSolicitMedical(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolicitMedicalScreen(
          
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.categoryTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                ...List.generate(_categories.length, (index) {
                  final category = _categories[index];
                  return SliverToBoxAdapter(
                    child: _CategorySection(
                      category: category,
                      onServiceTap: _navigateToSolicitMedical,
                    ),
                  );
                }),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final ServiceCategory category;
  final Function(Service) onServiceTap;

  const _CategorySection({
    required this.category,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Text(
            category.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: category.services.length,
          itemBuilder: (context, index) {
            return _ServiceCard(
              service: category.services[index],
              onTap: () => onServiceTap(category.services[index]),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    '\$${service.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}