import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../services/api_services.dart';

class RegisterScreen extends StatefulWidget {
 const RegisterScreen({super.key});

 @override
 State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
 final _nameController = TextEditingController();
 final _emailController = TextEditingController();
 final _passwordController = TextEditingController();
 bool _acceptTerms = false;
 bool _isLoading = false;

 void _handleRegister() async {
   if (!_acceptTerms) return;
   
   if (_nameController.text.isEmpty || 
       _emailController.text.isEmpty || 
       _passwordController.text.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Por favor complete todos los campos'),
         backgroundColor: Colors.red,
       ),
     );
     return;
   }

   setState(() => _isLoading = true);

   try {
     final success = await ApiService().addUser(
       name: _nameController.text,
       userName: _emailController.text,
       password: _passwordController.text,
       foto: '', 
       verificado: 'false',
     );

     if (success && mounted) {
       Navigator.pop(context);
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Registro exitoso'),
           backgroundColor: Colors.green,
         )
       );
     } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Error al registrar usuario'),
           backgroundColor: Colors.red,
         )
       );
     }
   } catch (e) {
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Error: ${e.toString()}'),
           backgroundColor: Colors.red,
         )
       );
     }
   } finally {
     if (mounted) setState(() => _isLoading = false);
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Registro'),
       centerTitle: true,
     ),
     body: SingleChildScrollView(
       padding: const EdgeInsets.all(24.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Text(
             'SOOWE',
             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
               color: Theme.of(context).colorScheme.primary,
               fontWeight: FontWeight.bold
             ),
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 8),
           Text(
             'Únete a la comunidad de profesionales',
             style: Theme.of(context).textTheme.bodyLarge,
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 32),
           FilledTextField(
             controller: _nameController,
             label: 'Nombre completo',
             prefixIcon: Icons.person_outline,
             enabled: !_isLoading,
           ),
           const SizedBox(height: 16),
           FilledTextField(
             controller: _emailController,
             label: 'Correo electrónico',
             prefixIcon: Icons.email_outlined,
             enabled: !_isLoading,
           ),
           const SizedBox(height: 16),
           FilledTextField(
             controller: _passwordController,
             label: 'Contraseña',
             prefixIcon: Icons.lock_outline,
             obscureText: true,
             enabled: !_isLoading,
           ),
           const SizedBox(height: 8),
           CheckboxListTile(
             value: _acceptTerms,
             onChanged: _isLoading ? null : (value) => setState(() => _acceptTerms = value!),
             title: Row(
               children: [
                 const Text('Acepto los '),
                 GestureDetector(
                   onTap: _isLoading ? null : () {
                     // Implementar navegación a términos
                   },
                   child: Text(
                     'términos y condiciones',
                     style: TextStyle(
                       color: Theme.of(context).colorScheme.primary,
                       decoration: TextDecoration.underline,
                     ),
                   ),
                 ),
               ],
             ),
             controlAffinity: ListTileControlAffinity.leading,
             contentPadding: EdgeInsets.zero,
           ),
           const SizedBox(height: 24),
           ElevatedButton(
             onPressed: (_acceptTerms && !_isLoading) ? _handleRegister : null,
             style: ElevatedButton.styleFrom(
               padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(12)
               ),
             ),
             child: _isLoading 
               ? const SizedBox(
                   height: 20,
                   width: 20,
                   child: CircularProgressIndicator(strokeWidth: 2)
                 )
               : const Text('Crear cuenta'),
           ),
         ],
       ),
     ),
   );
 }

 @override
 void dispose() {
   _nameController.dispose();
   _emailController.dispose();
   _passwordController.dispose();
   super.dispose();
 }
}