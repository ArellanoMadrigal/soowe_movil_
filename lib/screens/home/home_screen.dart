import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../transitions/search_page_transition.dart';
import 'profile_view.dart';
import 'requests_view.dart';
import 'categories_screen.dart';
import 'solicit_medical.dart';
import 'list_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showNotifications = false;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _notifications = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final allRequests = await _apiService.fetchAllRequests();
      final allNotifications = await _apiService.fetchNotifications();

      setState(() {
        _requests = allRequests.where((r) => r['status'] == 'active').toList();
        _notifications = allNotifications.where((n) => !n['read']).toList();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _toggleNotifications() => setState(() => _showNotifications = !_showNotifications);
  void _navigateToProfile() => setState(() => _selectedIndex = 2);
  void _logout() {
    _apiService.logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
                onProfileTap: _navigateToProfile,
                onNotificationTap: _toggleNotifications,
                apiService: _apiService,
              ),
              RequestsView(requests: _requests),
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
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final ApiService apiService;

  const _ServicesView({
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
                    'Alejandro Arellano',
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Cómo podemos ayudarte?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'searchBar',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: InkWell(
                          onTap: _navigateToCategories,
                          borderRadius: BorderRadius.circular(28),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 22,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Busca en más de 20 servicios',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
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
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
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
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    service.icon,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  service.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${service.nurses} enfermeros',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              right: 8,
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Notificaciones',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onDismiss,
                          tooltip: 'Cerrar notificaciones',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  if (notifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes notificaciones',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: notification['read']
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.notifications,
                              color: notification['read']
                                  ? Theme.of(context).colorScheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            notification['title'],
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              notification['message'],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ),
                          onTap: () {
                            // Marcar notificación como leída
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}