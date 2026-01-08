// FILE: lib/ui/screens/checkin/guest_confirmation_screen.dart
// VERZIJA: 1.1 - FIXED (bez upozorenja)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/guest_model.dart';

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
          content: Text('Popunite polja: ${emptyFields.join(", ")}'),
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
        title: Text('Gost ${widget.guestNumber} / ${widget.totalGuests}'),
        backgroundColor: const Color(0xFF1A3A4A),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: widget.onRescan,
            icon: const Icon(Icons.refresh, color: Colors.white70),
            label: const Text('PONOVI SKEN',
                style: TextStyle(color: Colors.white70)),
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
                const Text(
                  'Provjerite i ispravite podatke',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sva polja su obavezna za eVisitor prijavu',
                  style: TextStyle(color: Color(0x99FFFFFF), fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('OSOBNI PODACI', Icons.person),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_firstNameCtrl, 'Ime')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_lastNameCtrl, 'Prezime')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: _buildTextField(
                            _dateOfBirthCtrl, 'Datum rođenja',
                            hint: 'DD.MM.YYYY')),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: _buildSexDropdown()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            _placeOfBirthCtrl, 'Mjesto rođenja')),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(
                            _countryOfBirthCtrl, 'Država rođenja')),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_nationalityCtrl, 'Državljanstvo'),
                const SizedBox(height: 24),
                _buildSectionHeader('DOKUMENT', Icons.badge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 1, child: _buildDocTypeDropdown()),
                    const SizedBox(width: 16),
                    Expanded(
                        flex: 2,
                        child: _buildTextField(
                            _documentNumberCtrl, 'Broj dokumenta')),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('PREBIVALIŠTE', Icons.home),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child:
                            _buildTextField(_residenceCountryCtrl, 'Država')),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(_residenceCityCtrl, 'Grad')),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('BORAVAK', Icons.calendar_today),
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
                            const Text('Dolazak',
                                style: TextStyle(
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
                            const Text('Odlazak',
                                style: TextStyle(
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
                          ? 'POTVRDI I SLJEDEĆI GOST'
                          : 'POTVRDI I NASTAVI',
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
          items: const [
            DropdownMenuItem(value: 'M', child: Text('M (Muški)')),
            DropdownMenuItem(value: 'Ž', child: Text('Ž (Ženski)')),
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
          items: const [
            DropdownMenuItem(value: 'ID_CARD', child: Text('Osobna')),
            DropdownMenuItem(value: 'PASSPORT', child: Text('Putovnica')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedDocType = value);
          },
        ),
      ),
    );
  }
}
