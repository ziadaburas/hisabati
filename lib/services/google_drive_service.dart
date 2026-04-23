import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/entry_model.dart';

class GoogleDriveService {
  static const String _fileName = 'ownaccounts_data.json';
  static const String _appDataFolder = 'appDataFolder';

  String? _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

  // Find file in appDataFolder
  Future<String?> _findFileId() async {
    if (_accessToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files'
          '?spaces=$_appDataFolder'
          '&q=name%3D%27$_fileName%27'
          '&fields=files(id,name)',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final files = data['files'] as List;
        if (files.isNotEmpty) {
          return files.first['id'] as String;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Drive findFile error: $e');
      return null;
    }
  }

  // Upload entries to Google Drive appDataFolder
  Future<bool> uploadEntries(List<EntryModel> entries) async {
    if (_accessToken == null) return false;
   
    try {
      final jsonData = jsonEncode({
        'version': 2,
        'lastModified': DateTime.now().toIso8601String(),
        'entries': entries.map((e) => e.toJson()).toList(),
      });

      final existingFileId = await _findFileId();
      
      if (existingFileId != null) {
        // Update existing file
        final response = await http.patch(
          Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files/$existingFileId'
            '?uploadType=media',
          ),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );

        return response.statusCode == 200;
      } else {
        // Create new file with multipart upload
        final boundary = 'ownaccounts_boundary';
        final metadata = jsonEncode({
          'name': _fileName,
          'parents': [_appDataFolder],
          'mimeType': 'application/json',
        });

        final body = '--$boundary\r\n'
            'Content-Type: application/json; charset=UTF-8\r\n\r\n'
            '$metadata\r\n'
            '--$boundary\r\n'
            'Content-Type: application/json\r\n\r\n'
            '$jsonData\r\n'
            '--$boundary--';

        final response = await http.post(
          Uri.parse(
            'https://www.googleapis.com/upload/drive/v3/files'
            '?uploadType=multipart',
          ),
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'multipart/related; boundary=$boundary',
          },
          body: body,
        );
         
        return response.statusCode == 200;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Drive upload error: $e');
      return false;
    }
  }

  // Download entries from Google Drive
  Future<List<EntryModel>?> downloadEntries() async {
    if (_accessToken == null) return null;
    try {
      final fileId = await _findFileId();
      if (fileId == null) return [];

      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/drive/v3/files/$fileId?alt=media',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entriesJson = data['entries'] as List;
        return entriesJson
            .map((e) => EntryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Drive download error: $e');
      return null;
    }
  }

  // Check if we can reach Drive API
  Future<bool> isAvailable() async {
    if (_accessToken == null) return false;
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/drive/v3/about?fields=user'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
