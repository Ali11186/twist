import 'package:flutter/material.dart';
import '../services/twist_service.dart';

enum AppState { idle, loading, loggedIn, error }

class TwistProvider extends ChangeNotifier {
  final _service = TwistService();
  AppState state = AppState.idle;
  int balance = 0;
  String message = '';
  int tasksCount = 0;
  bool redeemSuccess = false;

  Future<bool> sendCode(String phone) async {
    state = AppState.loading;
    message = '';
    notifyListeners();
    final ok = await _service.sendCode(phone);
    state = AppState.idle;
    message = ok ? '' : '❌ فشل إرسال الكود';
    notifyListeners();
    return ok;
  }

  Future<bool> verify(String phone, String code) async {
    state = AppState.loading;
    message = '';
    notifyListeners();
    final ok = await _service.verifyCode(phone, code);
    if (ok) {
      balance = await _service.getBalance();
      state = AppState.loggedIn;
      message = '';
    } else {
      state = AppState.error;
      message = '❌ كود خاطئ أو انتهت صلاحيته';
    }
    notifyListeners();
    return ok;
  }

  Future<void> doTasks() async {
    state = AppState.loading;
    notifyListeners();
    tasksCount = await _service.doTasks();
    balance = await _service.getBalance();
    message = 'تم تنفيذ $tasksCount مهمة';
    state = AppState.loggedIn;
    notifyListeners();
  }

  Future<void> redeem(String pkg) async {
    state = AppState.loading;
    notifyListeners();
    redeemSuccess = await _service.redeem(pkg);
    balance = await _service.getBalance();
    message = redeemSuccess ? '✅ تم الاسترداد' : '❌ فشل الاسترداد';
    state = AppState.loggedIn;
    notifyListeners();
  }
}
