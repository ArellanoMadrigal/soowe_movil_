import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileView extends StatefulWidget {
 final VoidCallback onLogout;

 const ProfileView({
   super.key,
   required this.onLogout,
 });

 @override
 State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
 String name = 'Alejandro Arellano';
 String email = 'alejandro@example.com';
 String phone = '+52 123 456 7890';
 String address = 'Ciudad de México';

 Future<void> _handleEdit() async {
   final result = await Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => EditProfileScreen(
         name: name,
         email: email,
         phone: phone,
         address: address,
       ),
     ),
   );

   if (result != null) {
     setState(() {
       name = result['name'];
       email = result['email'];
       phone = result['phone'];
       address = result['address'];
     });
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.surface,
     body: SafeArea(
       child: SingleChildScrollView(
         child: Column(
           children: [
             _ProfileHeader(
               name: name,
               onEdit: _handleEdit,
             ),
             const SizedBox(height: 20),
             _SectionGroup(
               children: [
                 _ProfileItem(
                   icon: Icons.email_outlined,
                   title: 'Correo electrónico',
                   subtitle: email,
                   showEdit: true,
                   onTap: _handleEdit,
                 ),
                 _ProfileItem(
                   icon: Icons.phone_outlined,
                   title: 'Teléfono',
                   subtitle: phone,
                   showEdit: true,
                   onTap: _handleEdit,
                 ),
                 _ProfileItem(
                   icon: Icons.location_on_outlined,
                   title: 'Dirección',
                   subtitle: address,
                   showEdit: true,
                   onTap: _handleEdit,
                 ),
               ],
             ),
             const SizedBox(height: 16),
             _SectionGroup(
               title: 'Preferencias',
               children: [
                 _ProfileItem(
                   icon: Icons.settings_outlined,
                   title: 'Configuración',
                   showArrow: true,
                 ),
                 _ProfileItem(
                   icon: Icons.help_outline,
                   title: 'Ayuda',
                   showArrow: true,
                 ),
                 _ProfileItem(
                   icon: Icons.logout,
                   title: 'Cerrar sesión',
                   showArrow: true,
                   onTap: () {
                     showDialog(
                       context: context,
                       builder: (context) => AlertDialog(
                         title: const Text('Cerrar sesión'),
                         content: const Text('¿Estás seguro que deseas cerrar sesión?'),
                         actions: [
                           TextButton(
                             onPressed: () => Navigator.pop(context),
                             child: const Text('Cancelar'),
                           ),
                           FilledButton(
                             onPressed: () {
                               Navigator.pop(context);
                               widget.onLogout();
                             },
                             child: const Text('Cerrar sesión'),
                           ),
                         ],
                       ),
                     );
                   },
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

class _ProfileHeader extends StatelessWidget {
 final String name;
 final VoidCallback onEdit;

 const _ProfileHeader({
   required this.name,
   required this.onEdit,
 });

 @override
 Widget build(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.all(24),
     child: Column(
       children: [
         const CircleAvatar(
           radius: 40,
           backgroundColor: Colors.grey,
           child: Icon(Icons.person_outline, size: 40, color: Colors.white),
         ),
         const SizedBox(height: 16),
         Text(
           name,
           style: const TextStyle(
             fontSize: 24,
             fontWeight: FontWeight.bold,
           ),
         ),
         TextButton(
           onPressed: onEdit,
           child: const Text('Editar perfil'),
         ),
       ],
     ),
   );
 }
}

class _SectionGroup extends StatelessWidget {
 final String? title;
 final List<Widget> children;

 const _SectionGroup({
   this.title,
   required this.children,
 });

 @override
 Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       if (title != null)
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           child: Text(
             title!,
             style: Theme.of(context).textTheme.titleSmall?.copyWith(
                   color: Colors.grey,
                 ),
           ),
         ),
       Container(
         margin: const EdgeInsets.symmetric(horizontal: 16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Colors.grey.shade200),
         ),
         child: Column(
           children: children,
         ),
       ),
     ],
   );
 }
}

class _ProfileItem extends StatelessWidget {
 final IconData icon;
 final String title;
 final String? subtitle;
 final bool showEdit;
 final bool showArrow;
 final VoidCallback? onTap;

 const _ProfileItem({
   required this.icon,
   required this.title,
   this.subtitle,
   this.showEdit = false,
   this.showArrow = false,
   this.onTap,
 });

 @override
 Widget build(BuildContext context) {
   return InkWell(
     onTap: onTap,
     child: Container(
       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
       decoration: BoxDecoration(
         border: Border(
           bottom: BorderSide(
             color: Colors.grey.shade200,
             width: 1,
           ),
         ),
       ),
       child: Row(
         children: [
           Icon(icon, color: Theme.of(context).colorScheme.primary),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   title,
                   style: const TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
                 if (subtitle != null)
                   Text(
                     subtitle!,
                     style: TextStyle(
                       fontSize: 14,
                       color: Colors.grey.shade600,
                     ),
                   ),
               ],
             ),
           ),
           if (showEdit)
             Icon(
               Icons.edit_outlined,
               color: Theme.of(context).colorScheme.primary,
               size: 20,
             )
           else if (showArrow)
             const Icon(
               Icons.chevron_right,
               color: Colors.grey,
               size: 24,
             ),
         ],
       ),
     ),
   );
 }
}