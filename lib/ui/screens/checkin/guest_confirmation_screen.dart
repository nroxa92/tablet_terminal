// FILE: lib/ui/screens/checkin/guest_confirmation_screen.dart
// VERZIJA: 2.0 - LOKALIZACIJA (EN fallback + Translations)
// DATUM: 2026-01-11

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/guest_model.dart';
import '../../../utils/translations/translations.dart';

class GuestConfirmationScreen extends StatefulWidget {
  final Guest guest;
  final int guestNumber;
  final int totalGuests;
  final Function(Guest) onConfirm;
  final VoidCallback onRescan;

  const GuestConfirmationScreen({
    super.key,
    required this.guest,
    required this.guestNumber,
    required this.totalGuests,
    required this.onConfirm,
    required this.onRescan,
  });

  @override
  State<GuestConfirmationScreen> createState() =>
      _GuestConfirmationScreenState();
}

class _GuestConfirmationScreenState extends State<GuestConfirmationScreen> {
  late Guest _guest;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _dateOfBirthCtrl;
  late TextEditingController _placeOfBirthCtrl;
  late TextEditingController _countryOfBirthCtrl;
  late TextEditingController _nationalityCtrl;
  late TextEditingController _documentNumberCtrl;
  late TextEditingController _residenceCountryCtrl;
  late TextEditingController _residenceCityCtrl;

  String _selectedSex = 'M';
  String _selectedDocType = 'ID_CARD';

  @override
  void initState() {
    super.initState();
    _guest = widget.guest;

    _firstNameCtrl = TextEditingController(text: _guest.firstName);
    _lastNameCtrl = TextEditingController(text: _guest.lastName);
    _dateOfBirthCtrl = TextEditingController(text: _guest.dateOfBirth);
    _placeOfBirthCtrl = TextEditingController(text: _guest.placeOfBirth);
    _countryOfBirthCtrl = TextEditingController(text: _guest.countryOfBirth);
    _nationalityCtrl = TextEditingController(text: _guest.nationality);
    _documentNumberCtrl = TextEditingController(text: _guest.documentNumber);
    _residenceCountryCtrl =
        TextEditingController(text: _guest.residenceCountry);
    _residenceCityCtrl = TextEditingController(text: _guest.residenceCity);

    _selectedSex = _guest.sex.isNotEmpty ? _guest.sex : 'M';
    _selectedDocType =
        _guest.documentType.isNotEmpty ? _guest.documentType : 'ID_CARD';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dateOfBirthCtrl.dispose();
    _placeOfBirthCtrl.dispose();
    _countryOfBirthCtrl.dispose();
    _nationalityCtrl.dispose();
    _documentNumberCtrl.dispose();
    _residenceCountryCtrl.dispose();
    _residenceCityCtrl.dispose();
    super.dispose();
  }

  void _updateGuest() {
    _guest.firstName = _firstNameCtrl.text.trim();
    _guest.lastName = _lastNameCtrl.text.trim();
    _guest.dateOfBirth = _dateOfBirthCtrl.text.trim();
    _guest.placeOfBirth = _placeOfBirthCtrl.text.trim();
    _guest.countryOfBirth = _countryOfBirthCtrl.text.trim();
    _guest.sex = _selectedSex;
    _guest.nationality = _nationalityCtrl.text.trim();
    _guest.documentType = _selectedDocType;
    _guest.documentNumber = _documentNumberCtrl.text.trim();
    _guest.residenceCountry = _residenceCountryCtrl.text.trim();
    _guest.residenceCity = _residenceCityCtrl.text.trim();
  }

  void _onConfirm() {
    _updateGuest();

    if (!_guest.isComplete) {
      final emptyFields = _guest.emptyFields;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${Translations.t('confirm_fill_fields')}: ${emptyFields.join(", ")}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onConfirm(_guest);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final arrivalStr = _guest.arrivalDateTime != null
        ? dateFormat.format(_guest.arrivalDateTime!)
        : '-';
    final departureStr = _guest.departureDate != null
        ? DateFormat('dd.MM.yyyy').format(_guest.departureDate!)
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${Translations.t('cam_guest')} ${widget.guestNumber} / ${widget.totalGuests}'),
        backgroundColor: const Color(0xFF1A3A4A),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: widget.onRescan,
            icon: const Icon(Icons.refresh, color: Colors.white70),
            label: Text(Translations.t('confirm_rescan'),
                style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A3A4A), Color(0xFF0D1E26)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translations.t('cam_verify_data'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Translations.t('confirm_fields_required'),
                  style:
                      const TextStyle(color: Color(0x99FFFFFF), fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    Translations.t('cam_personal_data'), Icons.person),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_firstNameCtrl,
                            Translations.t('field_first_name'))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(
                            _lastNameCtrl, Translations.t('field_last_name'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: _buildTextField(_dateOfBirthCtrl,
                            Translations.t('field_birth_date'),
                            hint: 'DD.MM.YYYY')),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: _buildSexDropdown()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_placeOfBirthCtrl,
                            Translations.t('confirm_place_of_birth'))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_countryOfBirthCtrl,
                            Translations.t('confirm_country_of_birth'))),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                    _nationalityCtrl, Translations.t('field_nationality')),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    Translations.t('confirm_document'), Icons.badge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 1, child: _buildDocTypeDropdown()),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 2,
                        child: _buildTextField(_documentNumberCtrl,
                            Translations.t('field_doc_number'))),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    Translations.t('confirm_residence'), Icons.home),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(_residenceCountryCtrl,
                            Translations.t('confirm_country'))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_residenceCityCtrl,
                            Translations.t('confirm_city'))),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    Translations.t('confirm_stay'), Icons.calendar_today),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x3DFFFFFF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Translations.t('confirm_arrival'),
                                style: const TextStyle(
                                    color: Color(0x99FFFFFF), fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(arrivalStr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                          width: 1, height: 40, color: const Color(0x3DFFFFFF)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(Translations.t('confirm_departure'),
                                style: const TextStyle(
                                    color: Color(0x99FFFFFF), fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(departureStr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _onConfirm,
                    icon: const Icon(Icons.check_circle, size: 24),
                    label: Text(
                      widget.guestNumber < widget.totalGuests
                          ? Translations.t('confirm_next_guest')
                          : Translations.t('confirm_continue'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.cyan, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {String? hint}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0x99FFFFFF)),
        hintStyle: const TextStyle(color: Color(0x4DFFFFFF)),
        filled: true,
        fillColor: const Color(0x1AFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0x3DFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.cyan, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSexDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x3DFFFFFF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSex,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A3A4A),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: [
            DropdownMenuItem(
                value: 'M', child: Text(Translations.t('confirm_male'))),
            DropdownMenuItem(
                value: 'F', child: Text(Translations.t('confirm_female'))),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedSex = value);
          },
        ),
      ),
    );
  }

  Widget _buildDocTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x3DFFFFFF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDocType,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A3A4A),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: [
            DropdownMenuItem(
                value: 'ID_CARD', child: Text(Translations.t('doc_id_card'))),
            DropdownMenuItem(
                value: 'PASSPORT', child: Text(Translations.t('doc_passport'))),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedDocType = value);
          },
        ),
      ),
    );
  }
}
