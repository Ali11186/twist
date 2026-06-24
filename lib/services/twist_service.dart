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
        return {'success': false, 'message': 'رمز التحقق غير صحيح - ${res.statusCode}'};
      }

      // نرجع الـ response كامل عشان نشوف فيه إيه
      final body = res.body;
      final resHeaders = res.headers;

      return {
        'success': false,
        'message': 'BODY: ${body.substring(0, body.length > 200 ? 200 : body.length)} | HEADERS: ${resHeaders.toString().substring(0, 100)}'
      };

    } catch (e) {
      return {'success': false, 'message': 'خطأ: $e'};
    }
  }

  Future<int> getBalance(Map<String, String> headers) async => 0;
  Future<int> completeAchievements(Map<String, String> headers) async => 0;
  List<Map<String, dynamic>> buildRedeemOptions(int balance) => [];
  Future<bool> redeem(Map<String, String> headers, String code, int units) async => false;
}
