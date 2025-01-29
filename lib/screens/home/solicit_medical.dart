import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SolicitMedicalScreen extends StatefulWidget {
  const SolicitMedicalScreen({super.key});

  @override
  State<SolicitMedicalScreen> createState() => _SolicitMedicalScreenState();
}

class _SolicitMedicalScreenState extends State<SolicitMedicalScreen> {
  final PageController _pageController = PageController();
  int currentStep = 0;
  
  // Date selection
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String _selectedTimeOption = 'Fecha específica';

  // Patient information
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _conditionController = TextEditingController();

  void _nextPage() {
    if (currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentStep++);
    }
  }

  void _previousPage() {
    if (currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _previousPage,
        ),
        title: Text(
          'Nueva Solicitud',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: currentStep),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DateStep(
                  selectedTimeOption: _selectedTimeOption,
                  selectedDate: selectedDate,
                  selectedTime: selectedTime,
                  onTimeOptionChanged: (value) => setState(() => _selectedTimeOption = value),
                  onDateChanged: (date) => setState(() => selectedDate = date),
                  onTimeChanged: (time) => setState(() => selectedTime = time),
                ),
                _PatientStep(
                  formKey: _formKey,
                  nameController: _nameController,
                  ageController: _ageController,
                  phoneController: _phoneController,
                  conditionController: _conditionController,
                ),
                const _LocationStep(),
                const _PaymentStep(),
              ],
            ),
          ),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: _previousPage,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            child: Text(
              currentStep == 0 ? 'Cancelar' : 'Atrás',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: currentStep == 3 ? _submitRequest : _nextPage,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              currentStep == 3 ? 'Confirmar' : 'Continuar',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitRequest() {
    // Aquí iría la lógica para enviar la solicitud
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitud Enviada'),
        content: const Text('Tu solicitud ha sido procesada exitosamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              Navigator.of(context).pop(); // Vuelve a la pantalla anterior
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _conditionController.dispose();
    super.dispose();
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: List.generate(4, (index) {
              final isActive = index <= currentStep;
              final isCompleted = index < currentStep;
              final color = isActive ? Colors.blue : Colors.grey[350];

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (index < 3)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: color,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildLabel('Fecha', 0),
              const Spacer(),
              _buildLabel('Paciente', 1),
              const Spacer(),
              _buildLabel('Ubicación', 2),
              const Spacer(),
              _buildLabel('Pago', 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, int step) {
    final isActive = step <= currentStep;
    return Text(
      text,
      style: TextStyle(
        color: isActive ? Colors.black : Colors.grey[500],
        fontSize: 13,
        fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
      ),
    );
  }
}

class _DateStep extends StatelessWidget {
  final String selectedTimeOption;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<String> onTimeOptionChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const _DateStep({
    required this.selectedTimeOption,
    required this.selectedDate,
    required this.selectedTime,
    required this.onTimeOptionChanged,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cuándo necesita el servicio?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                _buildTimeOption('Hoy'),
                const Divider(height: 1),
                _buildTimeOption('Mañana'),
                const Divider(height: 1),
                _buildTimeOption('Fecha específica'),
              ],
            ),
          ),
          if (selectedTimeOption == 'Fecha específica') ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDateButton(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeButton(context),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeOption(String option) {
    return InkWell(
      onTap: () => onTimeOptionChanged(option),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              selectedTimeOption == option
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selectedTimeOption == option ? Colors.blue : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              option,
              style: TextStyle(
                fontSize: 15,
                color: selectedTimeOption == option ? Colors.black87 : Colors.grey[600],
                fontWeight: selectedTimeOption == option ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onDateChanged(picked);
      },
      icon: const Icon(Icons.calendar_today, size: 18),
      label: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        if (picked != null) onTimeChanged(picked);
      },
      icon: const Icon(Icons.access_time, size: 18),
      label: Text(selectedTime.format(context)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _PatientStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController conditionController;

  const _PatientStep({
    required this.formKey,
    required this.nameController,
    required this.ageController,
    required this.phoneController,
    required this.conditionController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Paciente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: nameController,
              label: 'Nombre completo',
              icon: Icons.person,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ingrese el nombre' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: ageController,
              label: 'Edad',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ingrese la edad' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: phoneController,
              label: 'Teléfono',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ingrese el teléfono' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: conditionController,
              label: 'Condición o padecimiento',
              icon: Icons.medical_services,
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Ingrese la condición' : null,
            ),
          ],
        ),
      ),
    );
  }

Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ubicación del Servicio',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text('Mapa aquí'), // Placeholder para el mapa
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Implementar obtención de ubicación actual
            },
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('Usar ubicación actual'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Dirección completa',
                prefixIcon: Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Método de Pago',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          _buildPaymentOption(
            icon: Icons.credit_card,
            title: 'Tarjeta de Crédito/Débito',
            subtitle: 'Pago seguro con tarjeta',
            isSelected: true,
          ),
          const SizedBox(height: 16),
          _buildPaymentOption(
            icon: Icons.payments,
            title: 'Efectivo',
            subtitle: 'Pago en efectivo al personal de enfermería',
            isSelected: false,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del Servicio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Servicio:', 'Cuidados Básicos'),
                _buildSummaryRow('Fecha:', '29/01/2025'),
                _buildSummaryRow('Hora:', '7:19 PM'),
                const Divider(),
                _buildSummaryRow('Total:', '\$500.00', isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, 
          color: isSelected ? Colors.blue : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isSelected ? Colors.blue : Colors.grey[400],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}