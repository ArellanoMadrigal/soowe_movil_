import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

// Constantes para los strings
class _Strings {
  static const String title = 'SOOWE';
  static const String subtitle = 'Únete a la comunidad de profesionales';
  static const String appBarTitle = 'Registro';
  static const String nameLabel = 'Nombre completo';
  static const String lastNameLabel = 'Apellido';
  static const String emailLabel = 'Correo electrónico';
  static const String passwordLabel = 'Contraseña';
  static const String phoneLabel = 'Teléfono';
  static const String addressLabel = 'Dirección';
  static const String termsPrefix = 'Acepto los ';
  static const String termsText = 'términos y condiciones';
  static const String createAccountButton = 'Crear cuenta';
  static const String successMessage = 'Registro exitoso';
  static const String errorRegister = 'Error al registrar usuario';
  static const String errorEmptyFields = 'Por favor complete todos los campos';
  static const String errorInvalidEmail = 'Por favor ingrese un email válido';
  static const String errorInvalidName =
      'El nombre debe tener al menos 3 caracteres';
  static const String errorPasswordLength =
      'La contraseña debe tener al menos 6 caracteres';
  static const String errorAcceptTerms =
      'Debe aceptar los términos y condiciones';
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
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _nameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();

  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return _Strings.errorEmptyFields;
    }
    if (value!.length < 3) {
      return _Strings.errorInvalidName;
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value?.isEmpty ?? true) return _Strings.errorEmptyFields;
    return null;
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
    if (value!.length < 6) {
      return _Strings.errorPasswordLength;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value?.isEmpty ?? true) return _Strings.errorEmptyFields;
    if (!RegExp(r'^\d{10}$').hasMatch(value!)) return 'Ingrese un número válido';
    return null;
  }

  String? _validateAddress(String? value) {
    if (value?.isEmpty ?? true) return _Strings.errorEmptyFields;
    return null;
  }

  void _handleRegister() async {
    if (!_acceptTerms) {
      _showErrorSnackBar(_Strings.errorAcceptTerms);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await AuthService().registerUser(
        nombre: _nameController.text,
        apellido: _emailController.text,
        correo: _passwordController.text,
        contrasena: '',
        telefono: 'false',
        direccion: 'false',
      );

      if (success && mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar(_Strings.successMessage);
      } else if (mounted) {
        _showErrorSnackBar(_Strings.errorRegister);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: const SingleChildScrollView(
          child: Text(
            'Aquí irían los términos y condiciones detallados...',
            // Reemplazar con los términos reales
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_Strings.appBarTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _Strings.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _Strings.subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledTextField(
                controller: _nameController,
                label: _Strings.nameLabel,
                prefixIcon: Icons.person_outline,
                enabled: !_isLoading,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _lastNameFocus.requestFocus(),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              FilledTextField(
                controller: _lastNameController,
                label: _Strings.lastNameLabel,
                prefixIcon: Icons.person_outline,
                enabled: !_isLoading,
                focusNode: _lastNameFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _emailFocus.requestFocus(),
                validator: _validateLastName,
              ),
              const SizedBox(height: 16),
              FilledTextField(
                controller: _emailController,
                label: _Strings.emailLabel,
                prefixIcon: Icons.email_outlined,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _passwordFocus.requestFocus(),
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              FilledTextField(
                controller: _passwordController,
                label: _Strings.passwordLabel,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                focusNode: _passwordFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _phoneFocus.requestFocus(),
                validator: _validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              FilledTextField(
                controller: _phoneController,
                label: _Strings.phoneLabel,
                prefixIcon: Icons.phone_outlined,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                focusNode: _phoneFocus,
                textInputAction: TextInputAction.next,
                onSubmitted: () => _addressFocus.requestFocus(),
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),
              FilledTextField(
                controller: _addressController,
                label: _Strings.addressLabel,
                prefixIcon: Icons.home_outlined,
                enabled: !_isLoading,
                focusNode: _addressFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: () => _handleRegister(),
                validator: _validateAddress,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _acceptTerms,
                onChanged: _isLoading
                    ? null
                    : (value) => setState(() => _acceptTerms = value!),
                title: Row(
                  children: [
                    const Text(_Strings.termsPrefix),
                    GestureDetector(
                      onTap: _isLoading ? null : _showTermsDialog,
                      child: Text(
                        _Strings.termsText,
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
                onPressed:
                    (_acceptTerms && !_isLoading) ? _handleRegister : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(_Strings.createAccountButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }
}
