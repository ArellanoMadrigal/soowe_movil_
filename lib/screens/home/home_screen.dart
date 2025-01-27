import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'nurses_list_screen.dart';
import 'profile_view.dart';
import 'requests_view.dart';

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

class _ServicesView extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final ApiService apiService;

  const _ServicesView({
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    final services = [
      ServiceModel(
        id: '1',
        title: 'Cuidados Básicos\ndel Paciente',
        nurses: 1265,
        icon: Icons.medical_services_outlined,
      ),
      ServiceModel(
        id: '2',
        title: 'Atención\nPostoperatoria',
        nurses: 523,
        icon: Icons.healing_outlined,
      ),
      ServiceModel(
        id: '3',
        title: 'Suturas y Retiro\nde Suturas',
        nurses: 223,
        icon: Icons.cut_outlined,
      ),
      ServiceModel(
        id: '4',
        title: 'Limpieza y\nCuración de\nHeridas',
        nurses: 223,
        icon: Icons.cleaning_services_outlined,
      ),
      ServiceModel(
        id: '5',
        title: 'Control de\nEnfermedades\nCrónicas',
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

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: onProfileTap,
          child: const Row(
            children: [
              CircleAvatar(child: Icon(Icons.person_outline)),
              SizedBox(width: 8),
              Text('Alejandro Arellano'),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¿Cómo podemos ayudarte?',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SearchBar(
                      hintText: 'Busca en más de 20 servicios',
                      leading: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) => _ServiceCard(
                    service: services[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LongList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
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
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(service.icon, size: 24),
              const Spacer(),
              Text(
                service.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '${service.nurses} enfermeros',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Notificaciones'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                    ),
                  ),
                  const Divider(),
                  if (notifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No tienes notificaciones'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notification['read']
                                ? Theme.of(context).colorScheme.surfaceVariant
                                : Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.notifications),
                          ),
                          title: Text(notification['title']),
                          subtitle: Text(notification['message']),
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