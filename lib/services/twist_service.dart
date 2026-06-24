import 'dart:convert';
import 'package:http/http.dart' as http;

class TwistService {
  static const String _baseUrl = 'https://api.twistmena.com';

  Map<String, String> getBaseHeaders() {
    return {
      'user-agent': 'Twist-Mobile/10.10.49 (Android; 12; SM-A217F; music; ar-AE)',
      'app_version': '10.10.49',
      'appversion': '10.10.49',
      'channel': 'mobileapp',
      'content-type': 'application/json',
      'platform': 'android',
      'accept': 'application/json',
      'accept-language': 'ar',
      'host': 'api.twistmena.com',
      'device_id': 'SP1A.210812.016',
      'tgdeviceid': '',
      'device_token': '',
      'tg-token': '',
      'tg-refresh-token': '',
      'access-token': '',
      'connection': 'keep-alive',
    };
  }

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    String formatted = phone;
    if (phone.startsWith('01')) formatted = '2$phone';
    else if (phone.startsWith('+2')) formatted = phone.substring(1);

    final headers = getBaseHeaders();
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/music/Dlogin/sendCode'),
        headers: headers,
        body: jsonEncode({'dial': formatted}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return {'success': true, 'headers': headers, 'phone': formatted};
      }
      return {'success': false, 'message': 'فشل إرسال الكود'};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
      String phone, String code, Map<String, String> headers) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/music/Dlogin/verify'),
        headers: headers,
        body: jsonEncode({
          'dial': phone,
          'verifyCode': code,
          'socialServiceName': '',
          'socialServiceToken': '',
        }),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        return {'success': false, 'message': 'رمز التحقق غير صحيح'};
      }

      final data = jsonDecode(res.body);
      final newHeaders = Map<String, String>.from(headers);

      String token = data['token'] ?? data['authorization'] ?? '';
      if (token.isEmpty) {
        token = res.headers['authorization']?.replaceAll('Bearer ', '') ?? '';
      }
      if (token.isEmpty) return {'success': false, 'message': 'لم يتم استلام التوكن'};

      newHeaders['authorization'] = 'Bearer ${token.replaceAll('Bearer ', '')}';
      newHeaders['access-token'] = data['accessToken'] ?? '';
      newHeaders['tg-token'] = data['tgToken'] ?? data['tg_token'] ?? '';
      newHeaders['tg-refresh-token'] = data['tgRefreshToken'] ?? data['tg_refresh_token'] ?? '';
      newHeaders['tgdeviceid'] = data['tgDeviceId'] ?? data['tg_device_id'] ?? '22821093';

      return {'success': true, 'headers': newHeaders};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في التحقق'};
    }
  }

  Future<int> getBalance(Map<String, String> headers) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/music/user/loyalty/balance/details'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map) return int.tryParse('${data['balance']}') ?? 0;
        if (data is List && data.isNotEmpty) return int.tryParse('${data[0]['balance']}') ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<int> completeAchievements(Map<String, String> headers) async {
    int count = 0;
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/music/user/loyalty/achievements/v2'),
        headers: headers,
      ).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return 0;

      final data = jsonDecode(res.body);
      List categories = data is Map ? (data['badges'] ?? []) : data is List ? data : [];

      for (final cat in categories) {
        if (cat is! Map) continue;
        for (final task in (cat['badges'] ?? [])) {
          if (task is! Map || task['rewarded'] == true) continue;
          final id = task['id'];
          if (id == null) continue;
          try {
            final r = await http.post(
              Uri.parse('$_baseUrl/music/loyalty/action/$id'),
              headers: headers,
            ).timeout(const Duration(seconds: 5));
            if (r.statusCode == 200) count++;
          } catch (_) {}
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (_) {}
    return count;
  }

  List<Map<String, dynamic>> buildRedeemOptions(int balance) {
    final options = <Map<String, dynamic>>[
      {'cost': 100,  'units': 50,   'code': 'EAND_50_UNITS_ID_9'},
      {'cost': 200,  'units': 100,  'code': 'EAND_100_UNITS_ID_10'},
      {'cost': 300,  'units': 150,  'code': 'EAND_150_UNITS_ID_11'},
      {'cost': 600,  'units': 300,  'code': 'EAND_300_UNITS_ID_12'},
      {'cost': 1000, 'units': 500,  'code': 'EAND_500_UNITS_ID_13'},
      {'cost': 2000, 'units': 1000, 'code': 'EAND_1000_UNITS_ID_14'},
    ];
    return options.where((o) => balance >= (o['cost'] as int)).toList();
  }

  Future<bool> redeem(Map<String, String> headers, String code, int units) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/music/loyalty/redeem/$code'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
