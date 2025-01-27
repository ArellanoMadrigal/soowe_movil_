import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import 'recovery_screen.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

// Constantes para los strings
class _Strings {
  static const String title = 'SOOWE';
  static const String subtitle = 'Encuentra los mejores profesionales de enfermería';
  static const String emailLabel = 'Correo electrónico';
  static const String passwordLabel = 'Contraseña';
  static const String rememberMe = 'Recuérdame';
  static const String loginButton = 'Iniciar sesión';
  static const String forgotPassword = '¿Has olvidado tu contraseña?';
  static const String register = '¿No tienes una cuenta? Regístrate gratis';
  static const String errorEmptyFields = 'Por favor complete todos los campos';
  static const String errorInvalidEmail = 'Por favor ingrese un email válido';
  static const String errorInvalidPassword = 'La contraseña debe tener al menos 6 caracteres';
  static const String errorInvalidCredentials = 'Usuario o contraseña incorrectos';
}

class FilledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final String semanticsLabel;

  const FilledTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.validator,
    this.suffixIcon,
    this.focusNode,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onFieldSubmitted: (_) => onSubmitted?.call(),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          errorMaxLines: 2,
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _loginAttempts = 0;
  static const int _maxLoginAttempts = 3;

  @override
  void initState() {
    super.initState();
    _emailFocus.requestFocus();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return _Strings.errorEmptyFields;
    }
    if (!_isValidEmail(value!)) {
      return _Strings.errorInvalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return _Strings.errorEmptyFields;
    }
    if (!_isValidPassword(value!)) {
      return _Strings.errorInvalidPassword;
    }
    return null;
  }

  void _handleLogin() async {
    if (_loginAttempts >= _maxLoginAttempts) {
      _showErrorSnackBar('Demasiados intentos. Por favor, intente más tarde.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ApiService().login(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        _loginAttempts = 0;
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        _loginAttempts++;
        if (mounted) {
          _showErrorSnackBar(_Strings.errorInvalidCredentials);
        }
      }
    } catch (e) {
      _loginAttempts++;
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  _Strings.title,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _Strings.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                FilledTextField(
                  controller: _emailController,
                  label: _Strings.emailLabel,
                  prefixIcon: Icons.email_outlined,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  focusNode: _emailFocus,
                  onSubmitted: () => _passwordFocus.requestFocus(),
                  validator: _validateEmail,
                  semanticsLabel: 'Campo de correo electrónico',
                ),
                const SizedBox(height: 16),
                FilledTextField(
                  controller: _passwordController,
                  label: _Strings.passwordLabel,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                  focusNode: _passwordFocus,
                  onSubmitted: _handleLogin,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  semanticsLabel: 'Campo de contraseña',
                ),
                CheckboxListTile(
                  value: _rememberMe,
                  onChanged: _isLoading 
                    ? null 
                    : (value) => setState(() => _rememberMe = value!),
                  title: const Text(_Strings.rememberMe),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(_Strings.loginButton),
                ),
                TextButton(
                  onPressed: _isLoading 
                    ? null 
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RecoveryScreen()),
                    ),
                  child: const Text(_Strings.forgotPassword),
                ),
                OutlinedButton(
                  onPressed: _isLoading 
                    ? null 
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    ),
                  child: const Text(_Strings.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}