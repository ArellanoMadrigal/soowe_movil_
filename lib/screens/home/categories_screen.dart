import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _showSuggestions = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search Header with integrated back button
          SafeArea(
            bottom: false,
            child: Hero(
              tag: 'searchBar',
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Material(
                          type: MaterialType.transparency,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, size: 22),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Icon(Icons.search, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Buscar categorias...',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (value) {
                              setState(() => _showSuggestions = value.length >= 3);
                            },
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Material(
                            type: MaterialType.transparency,
                            child: IconButton(
                              icon: const Icon(Icons.clear, size: 22),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _showSuggestions = false);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content with Animations
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showSuggestions
                  ? _buildSuggestions()
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categorías Populares',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _PopularCategoriesGrid(),
                              const SizedBox(height: 32),
                              Text(
                                'Todas las Categorías',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _AllCategoriesList(),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      _CategoryData('Cuidados Básicos del Paciente', 1265),
      _CategoryData('Atención Postoperatoria', 523),
      _CategoryData('Suturas y Retiro de Suturas', 223),
      _CategoryData('Limpieza y Curación de Heridas', 223),
      _CategoryData('Control de Enfermedades Crónicas', 223),
      _CategoryData('Vacunación', 223),
    ].where((category) =>
        category.name.toLowerCase().contains(_searchController.text.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search, size: 20),
          title: Text(suggestion.name),
          onTap: () {
            // TODO: Implementar navegación a la categoría
          },
        );
      },
    );
  }
}

// El resto de las clases permanecen igual...
class _PopularCategoriesGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final popularCategories = [
      _CategoryData('Inyecciones', 890),
      _CategoryData('Curaciones', 756),
      _CategoryData('Terapia Física', 432),
      _CategoryData('Cuidados Intensivos', 345),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: popularCategories.length,
          itemBuilder: (context, index) {
            return _PopularCategoryCard(category: popularCategories[index]);
          },
        );
      },
    );
  }
}

class _AllCategoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final allCategories = [
      _CategoryData('Cuidados Básicos del Paciente', 1265),
      _CategoryData('Atención Postoperatoria', 523),
      _CategoryData('Suturas y Retiro de Suturas', 223),
      _CategoryData('Limpieza y Curación de Heridas', 223),
      _CategoryData('Control de Enfermedades Crónicas', 223),
      _CategoryData('Vacunación', 223),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allCategories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _CategoryListTile(category: allCategories[index]);
      },
    );
  }
}

class _PopularCategoryCard extends StatelessWidget {
  final _CategoryData category;

  const _PopularCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          // TODO: Implementar navegación a la categoría
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.nursesCount} enfermeros',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final _CategoryData category;

  const _CategoryListTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          // TODO: Implementar navegación a la categoría
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.nursesCount} enfermeros',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final int nursesCount;

  _CategoryData(this.name, this.nursesCount);
}