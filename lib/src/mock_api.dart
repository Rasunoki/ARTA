import 'dart:async';

class MockApi {
  MockApi._();
  static final instance = MockApi._();
  // Keep an in-memory mock admin profile that can be updated via saveProfile
  final Map<String, String> _adminProfile = {
    'name': 'Gatchalian',
    'role': 'superadmin',
    'email': 'superadmin@valenzuela.gov.ph',
    // optional fields: 'imageBase64', 'phone', 'description'
  };
  // Broadcast stream to notify listeners when profile changes
  final _profileController = StreamController<Map<String, String>>.broadcast();
  // Broadcast stream to emit responses list when it changes or is fetched
  final _responsesController = StreamController<List<Map<String, String>>>.broadcast();

  Stream<Map<String, String>> get profileStream => _profileController.stream;
  Stream<List<Map<String, String>>> get responsesStream => _responsesController.stream;

  Future<Map<String, String>> fetchAdminProfile() async {
    await Future.delayed(const Duration(milliseconds: 250));
    // return a copy to mimic network transfer
    return Map<String, String>.from(_adminProfile);
  }

  Future<List<Map<String, String>>> fetchResponses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final regions = ['Karuhatan', 'Mapulang Lupa', 'Gen. T De Leon', 'Lawang Bato', 'Coloong', 'Polo'];
    final names = [
      'Joseph Macasling',
      'Ishmael Santiago',
      'Jorich Maricar',
      'Vesti Mercado',
      'Mark Ordona',
      'Khlarenz Olegario',
      'Ana Santos',
      'Bernard Cruz',
      'Carla Reyes',
      'Diego Ramos',
      'Ella Bautista',
      'Felix Gomez',
    ];
    final list = List.generate(26, (i) => {
      'id': '00-00${i + 1}',
      'name': names[i % names.length],
      'clientType': i % 3 == 0 ? 'Citizen' : 'Business',
      'region': regions[i % regions.length],
      'service': (i % 4 == 0) ? 'Service A' : (i % 4 == 1) ? 'Service B' : (i % 4 == 2) ? 'Service C' : 'Service D',
      'date': DateTime.utc(2025, 9, 30).add(Duration(days: i)).toIso8601String(),
    });
    // Emit latest responses to subscribers (useful for live analytics)
    try {
      _responsesController.add(List<Map<String, String>>.from(list));
    } catch (_) {}
    return list;
  }

  Future<List<Map<String, String>>> fetchSurveys() async {
    // reuse responses as surveys for demo purposes
    return fetchResponses();
  }

  Future<List<Map<String, String>>> fetchUsers() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.generate(30, (index) => {
      'id': '00-000${index + 1}',
      'role': index % 3 == 0 ? 'Admin' : 'User',
      'email': 'user${index + 1}@gov.ph',
      'dept': index % 2 == 0 ? 'IT Department' : 'Finance Department',
      'phone': '+63 912 345 67${index + 10}',
    });
  }

  Future<bool> saveProfile(Map<String, String> profile) async {
    // Simulate a network/save delay and return success.
    await Future.delayed(const Duration(milliseconds: 300));
    // Merge provided fields into the in-memory profile so subsequent fetches return updated data
    profile.forEach((k, v) {
      _adminProfile[k] = v;
    });
    // Emit updated profile to subscribers
    try {
      _profileController.add(Map<String, String>.from(_adminProfile));
    } catch (_) {}
    return true;
  }
}
