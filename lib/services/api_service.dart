import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  // ================================================================
  // BASE URL
  // ================================================================
  static const String _baseUrl = 'http://tlp-election-api.runasp.net/api/Auth';

  // ================================================================
  // CONFIRMED ENDPOINT
  // Swagger se confirmed:
  //
  // POST
  // http://tlp-election-api.runasp.net/api/Auth/add-user
  // ================================================================
  static const String _addUserUrl = '$_baseUrl/add-user';

  // ================================================================
  // YE ENDPOINTS ABHI SWAGGER SE CONFIRM NAHI HUE
  // Inko guess nahi karna chahiye.
  // ================================================================
  //
  // Jab Swagger mein exact routes mil jayein to yahan replace karein.
  //
  static const String _getAllUsersUrl = '$_baseUrl/get-all-users';
  static const String _updateUserUrl = '$_baseUrl/update-user';
  static const String _deleteUserUrl = '$_baseUrl/delete-user';

  // ================================================================
  // HEADERS
  // ================================================================
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ================================================================
  // GET ALL USERS
  // ================================================================

  static Future<List<UserModel>> getAllUsers() async {
    final url = Uri.parse(_getAllUsersUrl);

    debugPrint('========================================');
    debugPrint('GET ALL USERS');
    debugPrint('URL: $url');
    debugPrint('METHOD: GET');
    debugPrint('========================================');

    try {
      final response = await http.get(url, headers: _headers);

      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE BODY: ${response.body}');
      debugPrint('RESPONSE HEADERS: ${response.headers}');
      debugPrint('========================================');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          debugPrint('⚠️ Response body empty');
          return [];
        }

        final decoded = jsonDecode(response.body);

        debugPrint('DECODED DATA: $decoded');

        final List<dynamic> list;

        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map<String, dynamic>) {
          final data = decoded['data'] ?? decoded['users'];

          list = data is List ? data : [];
        } else {
          list = [];
        }

        debugPrint('TOTAL USERS: ${list.length}');

        return list
            .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      throw Exception(
        'Users load nahi hue: '
        '${response.statusCode} - ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ GET ALL USERS ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  // static Future<List<UserModel>> getAllUsers() async {
  //   final response = await http.get(
  //     Uri.parse(_getAllUsersUrl),
  //     headers: _headers,
  //   );

  //   if (response.statusCode == 200) {
  //     if (response.body.isEmpty) {
  //       return [];
  //     }

  //     final dynamic decoded = jsonDecode(response.body);

  //     final List<dynamic> list;

  //     if (decoded is List) {
  //       list = decoded;
  //     } else if (decoded is Map<String, dynamic>) {
  //       final dynamic data = decoded['data'] ?? decoded['users'];

  //       if (data is List) {
  //         list = data;
  //       } else {
  //         list = [];
  //       }
  //     } else {
  //       list = [];
  //     }

  //     return list
  //         .map(
  //           (e) => UserModel.fromJson(
  //             Map<String, dynamic>.from(e),
  //           ),
  //         )
  //         .toList();
  //   }

  //   throw Exception(
  //     'Users load nahi hue: '
  //     '${response.statusCode} - ${response.body}',
  //   );
  // }

  // ================================================================
  // ADD USER
  // ================================================================

  static Future<bool> addUser(UserModel user) async {
    final url = Uri.parse(_addUserUrl);

    debugPrint('========================================');
    debugPrint('ADD USER API');
    debugPrint('URL: $url');
    debugPrint('METHOD: POST');
    debugPrint('HEADERS: $_headers');
    debugPrint('REQUEST: ${jsonEncode(user.toJson())}');
    debugPrint('========================================');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(user.toJson()),
      );

      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE BODY: ${response.body}');
      debugPrint('RESPONSE HEADERS: ${response.headers}');
      debugPrint('========================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ USER ADDED SUCCESSFULLY');
        return true;
      }

      debugPrint('❌ USER ADD FAILED');

      throw Exception(
        'User add nahi hua: '
        '${response.statusCode} - ${response.body}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ADD USER EXCEPTION: $e');
      debugPrint('STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  // static Future<bool> addUser(UserModel user) async {
  //   final response = await http.post(
  //     Uri.parse(_addUserUrl),
  //     headers: _headers,
  //     body: jsonEncode(user.toJson()),
  //   );

  //   if (response.statusCode == 200 ||
  //       response.statusCode == 201) {
  //     return true;
  //   }

  //   throw Exception(
  //     'User add nahi hua: '
  //     '${response.statusCode} - ${response.body}',
  //   );
  // }

  // ================================================================
  // UPDATE USER
  // ================================================================
  static Future<bool> updateUser(int id, UserModel user) async {
    final response = await http.put(
      Uri.parse('$_updateUserUrl/$id'),
      headers: _headers,
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception(
      'User update nahi hua: '
      '${response.statusCode} - ${response.body}',
    );
  }

  // ================================================================
  // DELETE USER
  // ================================================================
  static Future<bool> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$_deleteUserUrl/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception(
      'User delete nahi hua: '
      '${response.statusCode} - ${response.body}',
    );
  }
}
