import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class ApiService {
  static Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');
  static const _timeout = Duration(seconds: 8);

  static Exception _networkError(Object error) => Exception(
    'تعذر الاتصال بالخادم. تأكد أن Backend خدام على ${ApiConfig.baseUrl} ثم أعد المحاولة. ($error)');

  static Future<dynamic> _request(String method, String path, {Map<String,dynamic>? body}) async {
    try {
      late http.Response response;
      final uri = _uri(path);
      if (method == 'GET') {
        response = await http.get(uri).timeout(_timeout);
      } else if (method == 'POST') {
        response = await http.post(uri, headers: {'Content-Type':'application/json'}, body: jsonEncode(body)).timeout(_timeout);
      } else if (method == 'PATCH') {
        response = await http.patch(uri, headers: {'Content-Type':'application/json'}, body: jsonEncode(body)).timeout(_timeout);
      } else {
        response = await http.delete(uri).timeout(_timeout);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String detail = response.body;
        try { detail = (jsonDecode(response.body) as Map)['detail'].toString(); } catch (_) {}
        throw Exception('الخادم رجع ${response.statusCode}: $detail');
      }
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } catch (e) {
      if (e is Exception && e.toString().contains('الخادم رجع')) rethrow;
      throw _networkError(e);
    }
  }

  static Future<Map<String,dynamic>> dashboard() async => Map<String,dynamic>.from(await _request('GET','/dashboard'));
  static Future<List<dynamic>> getList(String path) async => List<dynamic>.from(await _request('GET',path));
  static Future<void> post(String path, Map<String,dynamic> body) async { await _request('POST',path,body:body); }
  static Future<void> patch(String path, Map<String,dynamic> body) async { await _request('PATCH',path,body:body); }
  static Future<void> delete(String path) async { await _request('DELETE',path); }
}
