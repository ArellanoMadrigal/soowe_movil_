import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class _Strings {
  static const String title = 'SOOWE';
  static const String subtitle = 'Únete a la comunidad de profesionales';
  static const String appBarTitle = 'Registro';
  static const String nameLabel = 'Nombre completo';
  static const String lastNameLabel = 'Apellido';
  static const String emailLabel = 'Correo electrónico';
  static const String passwordLabel = 'Contraseña';
  static const String confirmPasswordLabel = 'Confirmar contraseña';
  static const String termsPrefix = 'Acepto los ';
  static const String termsText = 'términos y condiciones';
  static const String createAccountButton = 'Crear cuenta';
  static const String successMessage = 'Registro exitoso';
  static const String errorRegister = 'Error al registrar usuario';
  static const String errorEmptyFields = 'Por favor complete todos los campos';
  static const String errorInvalidEmail = 'Por favor ingrese un email válido';
  static const String errorInvalidName = 'El nombre debe tener al menos 3 caracteres';
  static const String errorPasswordLength = 'La contraseña debe tener al menos 6 caracteres';
  static const String errorPasswordMismatch = 'Las contraseñas no coinciden';
  static const String errorAcceptTerms = 'Debe aceptar los términos y condiciones';
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
  final bool showValidationIcon;

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
    this.showValidationIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
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
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            errorMaxLines: 2,
          ),
        ),
        if (validator != null && controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: _buildValidationMessage(),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (!showValidationIcon || controller.text.isEmpty) return suffixIcon;
    return validator?.call(controller.text) == null
        ? Icon(Icons.check_circle, color: Colors.green)
        : Icon(Icons.error, color: Colors.red);
  }

  Widget? _buildValidationMessage() {
    final error = validator?.call(controller.text);
    if (error == null) return null;
    return Text(
      error,
      style: const TextStyle(color: Colors.red, fontSize: 12),
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
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  String? _validateName(String? value) {
    if (value?.isEmpty ?? true) return _Strings.errorEmptyFields;
    if (value!.length < 3) return _Strings.errorInvalidName;
    return null;
  }

  String? _validateLastName(String? value) => (value?.isEmpty ?? true) ? _Strings.errorEmptyFields : null;

  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) return _Strings.errorEmptyFields;
    if (!_isValidEmail(value!)) return _Strings.errorInvalidEmail;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return _Strings.errorEmptyFields;
    if (value!.length < 6) return _Strings.errorPasswordLength;
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return _Strings.errorEmptyFields;
    if (value != _passwordController.text) return _Strings.errorPasswordMismatch;
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      _showErrorSnackBar(_Strings.errorAcceptTerms);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await AuthService().registerUser(
        nombre: _nameController.text.trim(),
        apellido: _lastNameController.text.trim(),
        correo: _emailController.text.trim(),
        contrasena: _passwordController.text,
        confirmarContrasena: _confirmPasswordController.text,
        telefono: 'Pendiente de agregar', // Valor predeterminado
        direccion: 'Pendiente de agregar', // Valor predeterminado
      );

      if (success && mounted) {
        _showSuccessSnackBar(_Strings.successMessage);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

  void _showSuccessSnackBar(String message) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

  void _showTermsDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Términos y Condiciones'),
          content: const SingleChildScrollView(
            child: Text('Aquí irían los términos y condiciones detallados...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(_Strings.appBarTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _Strings.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                  const SizedBox(height: 32),
                  FilledTextField(
                    controller: _nameController,
                    label: _Strings.nameLabel,
                    prefixIcon: Icons.person_outline,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: () => _lastNameFocus.requestFocus(),
                    validator: _validateName,
                    showValidationIcon: true,
                  ),
                  const SizedBox(height: 16),
                  FilledTextField(
                    controller: _lastNameController,
                    label: _Strings.lastNameLabel,
                    prefixIcon: Icons.person_outline,
                    focusNode: _lastNameFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: () => _emailFocus.requestFocus(),
                    validator: _validateLastName,
                    showValidationIcon: true,
                  ),
                  const SizedBox(height: 16),
                  FilledTextField(
                    controller: _emailController,
                    label: _Strings.emailLabel,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: () => _passwordFocus.requestFocus(),
                    validator: _validateEmail,
                    showValidationIcon: true,
                  ),
                  const SizedBox(height: 16),
                  FilledTextField(
                    controller: _passwordController,
                    label: _Strings.passwordLabel,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    focusNode: _passwordFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: () => _confirmPasswordFocus.requestFocus(),
                    validator: _validatePassword,
                    showValidationIcon: true,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledTextField(
                    controller: _confirmPasswordController,
                    label: _Strings.confirmPasswordLabel,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    focusNode: _confirmPasswordFocus,
                    textInputAction: TextInputAction.done,
                    onSubmitted: _handleRegister,
                    validator: _validateConfirmPassword,
                    showValidationIcon: true,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _acceptTerms,
                    onChanged: _isLoading ? null : (value) => setState(() => _acceptTerms = value ?? false),
                    title: InkWell(
                      onTap: _isLoading ? null : _showTermsDialog,
                      child: RichText(
                        text: TextSpan(
                          text: _Strings.termsPrefix,
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: _Strings.termsText,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: (_formKey.currentState?.validate() ?? false) && _acceptTerms && !_isLoading
                        ? _handleRegister
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Text(_Strings.createAccountButton),
                  ),
                ],
              ),
            ),
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
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }
}