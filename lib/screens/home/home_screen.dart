import 'package:appdesarrollo/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../transitions/search_page_transition.dart';
import 'profile_view.dart';
import 'requests_view.dart';
import 'categories_screen.dart';
import 'list_service.dart';
import '../../services/request_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showNotifications = false;
  List<Request> _requests = [];
  List<Map<String, dynamic>> _notifications = [];
  final ApiService _apiService = ApiService();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = AuthService().getCurrentUserId();
      if (userId == null) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return;
      }

      final userName = AuthService().getUserName();
      if (userName != null && userName.isNotEmpty) {
        setState(() {
          _userName = userName;
        });
      } else {
        try {
          final userData = await _apiService.getUserProfile(userId);
          if (mounted) {
            setState(() {
              _userName = '${userData['nombre']} ${userData['apellido']}'.trim();
            });
          }
        } catch (e) {
          debugPrint("Error obteniendo perfil: $e");
        }
      }

      try {
        final allRequests = await RequestService().getAllRequests(
          usuarioId: int.tryParse(userId) ?? 0,
          organizacionId: 0,
        );
        final allNotifications = await _apiService.fetchNotifications();

        if (mounted) {
          setState(() {
            _requests = allRequests.where((r) => r.estado == 'activo').toList();
            _notifications = allNotifications.where((n) => !n['read']).toList();
          });
        }
      } catch (e) {
        debugPrint("Error cargando datos: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar datos: $e')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error general: $e");
    }
  }

  void _toggleNotifications() =>
      setState(() => _showNotifications = !_showNotifications);
      
  void _navigateToProfile() => setState(() => _selectedIndex = 2);
  
  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _ServicesView(
                userName: _userName,
                onProfileTap: _navigateToProfile,
                onNotificationTap: _toggleNotifications,
                apiService: _apiService,
              ),
              RequestsView(requests: _requests.map((request) => request.toMap()).toList()),
              ProfileView(
                onLogout: _logout,
              ),
            ],
          ),
          if (_showNotifications)
            _NotificationsOverlay(
              notifications: _notifications,
              onDismiss: _toggleNotifications,
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        height: 65,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Servicios',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _ServicesView extends StatefulWidget {
  final String userName;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final ApiService apiService;

  const _ServicesView({
    required this.userName,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.apiService,
  });

  @override
  State<_ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<_ServicesView> {
  final TextEditingController _searchController = TextEditingController();
  final services = [
    ServiceModel(
      id: '1',
      title: 'Cuidados Básicos del Paciente',
      nurses: 1265,
      icon: Icons.medical_services_outlined,
    ),
    ServiceModel(
      id: '2',
      title: 'Atención Postoperatoria',
      nurses: 523,
      icon: Icons.healing_outlined,
    ),
    ServiceModel(
      id: '3',
      title: 'Suturas y Retiro de Suturas',
      nurses: 223,
      icon: Icons.cut_outlined,
    ),
    ServiceModel(
      id: '4',
      title: 'Limpieza y Curación de Heridas',
      nurses: 223,
      icon: Icons.cleaning_services_outlined,
    ),
    ServiceModel(
      id: '5',
      title: 'Control de Enfermedades Crónicas',
      nurses: 223,
      icon: Icons.monitor_heart_outlined,
    ),
    ServiceModel(
      id: '6',
      title: 'Vacunación',
      nurses: 223,
      icon: Icons.vaccines_outlined,
    ),
  ];

  void _navigateToCategories() {
    Navigator.push(
      context,
      SearchPageTransition(
        page: const CategoriesScreen(),
      ),
    );
  }

  void _navigateToListService(ServiceModel service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListServiceScreen(
          categoryId: service.id,
          categoryTitle: service.title,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            pinned: true,
            backgroundColor: Colors.white,
            title: GestureDetector(
              onTap: widget.onProfileTap,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.userName.isEmpty ? 'Usuario' : widget.userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: widget.onNotificationTap,
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Notificaciones',
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué servicio necesitas?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onTap: _navigateToCategories,
                    decoration: InputDecoration(
                      hintText: 'Buscar servicios',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Servicios populares',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ServiceCard(
                  service: services[index],
                  onTap: () => _navigateToListService(services[index]),
                ),
                childCount: services.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceModel {
  final String id;
  final String title;
  final int nurses;
  final IconData icon;

  ServiceModel({
    required this.id,
    required this.title,
    required this.nurses,
    required this.icon,
  });
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.12),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  service.icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                service.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${service.nurses} enfermeros',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final VoidCallback onDismiss;

  const _NotificationsOverlay({
    required this.notifications,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black54,
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              right: 8,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notificaciones',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: onDismiss,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      if (notifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay notificaciones nuevas'),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              title: Text(notification['title'] ?? ''),
                              subtitle: Text(notification['message'] ?? ''),
                              trailing: Text(
                                notification['time'] ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}