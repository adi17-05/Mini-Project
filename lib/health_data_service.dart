import 'package:flutter/services.dart';

class HealthDataService {
  static const platform = MethodChannel('com.adity.health/healthdata');

  Future<Map<String, dynamic>> getHealthData() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getHealthData');
      return result.map((key, value) => MapEntry(key.toString(), value));
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching health data: $e");
      return {};
    }
  }
}
