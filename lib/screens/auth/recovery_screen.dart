import 'package:flutter/material.dart';
import 'login_screen.dart';

class RecoveryScreen extends StatefulWidget {
 const RecoveryScreen({super.key});

 @override
 State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
 final _emailController = TextEditingController();
 final _codeController = TextEditingController();
 final _newPasswordController = TextEditingController();
 final _confirmPasswordController = TextEditingController();
 bool _codeSent = false;

 void _handleRecovery() {
   setState(() => _codeSent = true);
   debugPrint('Email: ${_emailController.text}');
 }

 void _handlePasswordReset() {
   debugPrint('Code: ${_codeController.text}');
   debugPrint('New Password: ${_newPasswordController.text}');
   debugPrint('Confirm Password: ${_confirmPasswordController.text}');
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Recuperar Contraseña'),
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
           const SizedBox(height: 32),
           if (!_codeSent) ...[
             FilledTextField(
               controller: _emailController,
               label: 'Correo electrónico',
               prefixIcon: Icons.email_outlined,
             ),
             const SizedBox(height: 24),
             ElevatedButton(
               onPressed: _handleRecovery,
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 16),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12)
                 ),
               ),
               child: const Text('Enviar código'),
             ),
           ] else ...[
             const Text(
               'Te hemos enviado un código a tu correo',
               style: TextStyle(fontSize: 16),
               textAlign: TextAlign.center,
             ),
             const SizedBox(height: 24),
             FilledTextField(
               controller: _codeController,
               label: 'Código',
               prefixIcon: Icons.key_outlined,
             ),
             const SizedBox(height: 16),
             FilledTextField(
               controller: _newPasswordController,
               label: 'Nueva contraseña',
               prefixIcon: Icons.lock_outline,
               obscureText: true,
             ),
             const SizedBox(height: 16),
             FilledTextField(
               controller: _confirmPasswordController,
               label: 'Confirmar nueva contraseña',
               prefixIcon: Icons.lock_outline,
               obscureText: true,
             ),
             const SizedBox(height: 24),
             ElevatedButton(
               onPressed: _handlePasswordReset,
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 16),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12)
                 ),
               ),
               child: const Text('Cambiar contraseña'),
             ),
           ],
         ],
       ),
     ),
   );
 }
}