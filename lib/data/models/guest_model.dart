// FILE: lib/data/models/guest_model.dart
// VERZIJA: 1.0
// OPIS: Data model za gosta - svi podaci potrebni za eVisitor

import 'package:cloud_firestore/cloud_firestore.dart';

class Guest {
  // Osobni podaci
  String firstName;
  String lastName;
  String dateOfBirth; // Format: DD.MM.YYYY
  String placeOfBirth;
  String countryOfBirth;
  String sex; // M / Ž
  String nationality;

  // Dokument
  String documentType; // ID_CARD / PASSPORT
  String documentNumber;
  String issuingCountry; // Država izdavanja

  // Prebivalište
  String residenceCountry;
  String residenceCity;

  // Check-in info
  DateTime? arrivalDateTime;
  DateTime? departureDate;

  // Meta
  DateTime? scannedAt;

  Guest({
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth = '',
    this.placeOfBirth = '',
    this.countryOfBirth = '',
    this.sex = '',
    this.nationality = '',
    this.documentType = '',
    this.documentNumber = '',
    this.issuingCountry = '',
    this.residenceCountry = '',
    this.residenceCity = '',
    this.arrivalDateTime,
    this.departureDate,
    this.scannedAt,
  });

  /// Provjera je li sve popunjeno
  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        dateOfBirth.isNotEmpty &&
        placeOfBirth.isNotEmpty &&
        countryOfBirth.isNotEmpty &&
        sex.isNotEmpty &&
        nationality.isNotEmpty &&
        documentType.isNotEmpty &&
        documentNumber.isNotEmpty &&
        residenceCountry.isNotEmpty &&
        residenceCity.isNotEmpty;
  }

  /// Lista praznih polja (za validaciju)
  List<String> get emptyFields {
    List<String> empty = [];
    if (firstName.isEmpty) empty.add('Ime');
    if (lastName.isEmpty) empty.add('Prezime');
    if (dateOfBirth.isEmpty) empty.add('Datum rođenja');
    if (placeOfBirth.isEmpty) empty.add('Mjesto rođenja');
    if (countryOfBirth.isEmpty) empty.add('Država rođenja');
    if (sex.isEmpty) empty.add('Spol');
    if (nationality.isEmpty) empty.add('Državljanstvo');
    if (documentType.isEmpty) empty.add('Vrsta dokumenta');
    if (documentNumber.isEmpty) empty.add('Broj dokumenta');
    if (residenceCountry.isEmpty) empty.add('Država prebivališta');
    if (residenceCity.isEmpty) empty.add('Grad prebivališta');
    return empty;
  }

  /// Konverzija u Map za Firebase
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'placeOfBirth': placeOfBirth,
      'countryOfBirth': countryOfBirth,
      'sex': sex,
      'nationality': nationality,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'issuingCountry': issuingCountry,
      'residenceCountry': residenceCountry,
      'residenceCity': residenceCity,
      'arrivalDateTime':
          arrivalDateTime != null ? Timestamp.fromDate(arrivalDateTime!) : null,
      'departureDate':
          departureDate != null ? Timestamp.fromDate(departureDate!) : null,
      'scannedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  /// Kreiranje iz Firebase Map
  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      placeOfBirth: map['placeOfBirth'] ?? '',
      countryOfBirth: map['countryOfBirth'] ?? '',
      sex: map['sex'] ?? '',
      nationality: map['nationality'] ?? '',
      documentType: map['documentType'] ?? '',
      documentNumber: map['documentNumber'] ?? '',
      issuingCountry: map['issuingCountry'] ?? '',
      residenceCountry: map['residenceCountry'] ?? '',
      residenceCity: map['residenceCity'] ?? '',
      arrivalDateTime: map['arrivalDateTime'] != null
          ? (map['arrivalDateTime'] as Timestamp).toDate()
          : null,
      departureDate: map['departureDate'] != null
          ? (map['departureDate'] as Timestamp).toDate()
          : null,
      scannedAt: map['scannedAt'] != null
          ? (map['scannedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Debug ispis
  @override
  String toString() {
    return '''
Guest:
  Ime: $firstName $lastName
  Rođenje: $dateOfBirth, $placeOfBirth, $countryOfBirth
  Spol: $sex
  Državljanstvo: $nationality
  Dokument: $documentType $documentNumber ($issuingCountry)
  Prebivalište: $residenceCity, $residenceCountry
  Dolazak: $arrivalDateTime
  Odlazak: $departureDate
''';
  }
}

/// Mapping ISO kodova država u puni naziv
class CountryHelper {
  static const Map<String, String> isoToName = {
    'HRV': 'Hrvatska',
    'DEU': 'Njemačka',
    'AUT': 'Austrija',
    'ITA': 'Italija',
    'SVN': 'Slovenija',
    'HUN': 'Mađarska',
    'CZE': 'Češka',
    'POL': 'Poljska',
    'SVK': 'Slovačka',
    'GBR': 'Velika Britanija',
    'FRA': 'Francuska',
    'NLD': 'Nizozemska',
    'BEL': 'Belgija',
    'ESP': 'Španjolska',
    'PRT': 'Portugal',
    'SWE': 'Švedska',
    'NOR': 'Norveška',
    'DNK': 'Danska',
    'FIN': 'Finska',
    'CHE': 'Švicarska',
    'USA': 'SAD',
    'CAN': 'Kanada',
    'AUS': 'Australija',
    'SRB': 'Srbija',
    'BIH': 'Bosna i Hercegovina',
    'MNE': 'Crna Gora',
    'MKD': 'Sjeverna Makedonija',
    'ALB': 'Albanija',
    'ROU': 'Rumunjska',
    'BGR': 'Bugarska',
    'GRC': 'Grčka',
    'TUR': 'Turska',
    'RUS': 'Rusija',
    'UKR': 'Ukrajina',
  };

  static String getName(String isoCode) {
    return isoToName[isoCode.toUpperCase()] ?? isoCode;
  }
}
