import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkingService {
  const NetworkingService(this.baseUrl);

  final String baseUrl;

  Future<dynamic> fetchData(String endpoint) async {
    try {
      final http.Response response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
      );
      dynamic data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(
          '${response.statusCode}: ${data['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      return {'error': 'Failed to fetch data- $e'};
    }
  }

  Future<void> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }
}
