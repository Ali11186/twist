import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class TwistService {
  static const String _base = 'https://api.twistmena.com/music';
  Map<String, String> _headers = {};
  final _rand = Random();

  Map<String, String> _buildHeaders() {
    final ip = '102.62.${_rand.nextInt(255)}.${_rand.nextInt(255)}';
    final deviceId = 'AP3A.240905.015.${_rand.nextInt(900) + 100}';
    return {
      'user-agent': 'Dart/3.7 (dart:io)',
      'app_version': '10.10.45',
      'appversion': '10.10.45',
      'channel': 'mobileapp',
      'content-type': 'application/json',
      'platform': 'android',
      'accept': 'application/json',
      'accept-language': 'ar',
      'host': 'api.twistmena.com',
      'device_id': deviceId,
      'X-Forwarded-For': ip,
      'X-Real-IP': ip,
      'customer-ip': ip,
    };
  }

  Future<bool> sendCode(String phone) async {
    if (phone.startsWith('01')) phone = '2$phone';
    _headers = _buildHeaders();
    try {
      final r = await http.post(
        Uri.parse('$_base/Dlogin/sendCode'),
        headers: _headers,
        body: jsonEncode({'dial': phone}),
      ).timeout(const Duration(seconds: 15));
      return r.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyCode(String phone, String code) async {
    if (phone.startsWith('01')) phone = '2$phone';
    try {
      final r = await http.post(
        Uri.parse('$_base/Dlogin/verify'),
        headers: _headers,
        body: jsonEncode({'dial': phone, 'verifyCode': code}),
      ).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return false;
      final d = jsonDecode(r.body);
      final token = d['token'];
      if (token == null) return false;
      _headers = _buildHeaders();
      _headers['authorization'] = 'Bearer $token';
      _headers['access-token'] = d['accessToken'] ?? '';
      _headers['tgdeviceid'] = d['tgdeviceid'] ?? '22913102';
      _headers['device_token'] = d['deviceToken'] ?? '';
      _headers['tg-token'] = d['tgToken'] ?? '';
      _headers['tg-refresh-token'] = d['tgRefreshToken'] ?? '';
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getBalance() async {
    try {
      final r = await http.get(
        Uri.parse('$_base/user/loyalty/balance/details'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));
      if (r.statusCode == 200) {
        return jsonDecode(r.body)['balance'] ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<int> doTasks() async {
    int total = 0;
    try {
      final r = await http.get(
        Uri.parse('$_base/user/loyalty/achievements/v2'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));
      if (r.statusCode != 200) return 0;
      final data = jsonDecode(r.body);
      for (final cat in data['badges'] ?? []) {
        for (final task in cat['badges'] ?? []) {
          if (task['rewarded'] == true) continue;
          try {
            await http.post(
              Uri.parse('$_base/loyalty/action/${task['id']}'),
              headers: _headers,
            ).timeout(const Duration(seconds: 10));
            total++;
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (_) {}
        }
      }
    } catch (_) {}
    return total;
  }

  Future<bool> redeem(String pkg) async {
    try {
      final r = await http.post(
        Uri.parse('$_base/loyalty/redeem/$pkg'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static const packages = {
    '50 وحدة (100 نقطة)': 'EAND_50_UNITS_ID_9',
    '100 وحدة (200 نقطة)': 'EAND_100_UNITS_ID_10',
    '150 وحدة (300 نقطة)': 'EAND_150_UNITS_ID_11',
    '300 وحدة (600 نقطة)': 'EAND_300_UNITS_ID_12',
  };
}
