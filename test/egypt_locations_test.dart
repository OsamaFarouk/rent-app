import 'package:flutter_test/flutter_test.dart';
import 'package:rent_app/core/constants/egypt_locations.dart';

void main() {
  group('EgyptLocations Dataset Tests', () {
    test('Contains Cairo and Giza governorates', () {
      const governorates = EgyptLocations.governorates;
      expect(governorates.any((g) => g.id == 'cairo'), true);
      expect(governorates.any((g) => g.id == 'giza'), true);
      expect(governorates.any((g) => g.id == 'alexandria'), true);
    });

    test('Cairo governorate contains Maadi and Nasr City', () {
      final cairo = EgyptLocations.findGovernorate('Cairo');
      expect(cairo.nameEn, 'Cairo Governorate');
      expect(cairo.districts.any((d) => d.id == 'maadi_basatin'), true);
      expect(cairo.districts.any((d) => d.id == 'nasr_city'), true);
    });

    test('Giza governorate contains Dokki and Mohandessin', () {
      final giza = EgyptLocations.findGovernorate('Giza');
      expect(giza.nameEn, 'Giza Governorate');
      expect(giza.districts.any((d) => d.id == 'dokki'), true);
      expect(giza.districts.any((d) => d.id == 'agouza_mohandessin'), true);
    });

    test('findGovernorate matching Arabic name works', () {
      final alex = EgyptLocations.findGovernorate('الإسكندرية');
      expect(alex.id, 'alexandria');
    });

    test('findDistrict matching works correctly', () {
      final cairo = EgyptLocations.findGovernorate('Cairo');
      final maadi = EgyptLocations.findDistrict(cairo, 'Maadi');
      expect(maadi.nameEn, 'Maadi & Zahraa El Maadi');
    });
  });
}
