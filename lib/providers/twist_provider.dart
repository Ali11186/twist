import 'package:flutter/material.dart';
import '../services/twist_service.dart';

enum AppState { idle, loading, success, error }

class TwistProvider extends ChangeNotifier {
  final TwistService _service = TwistService();

  AppState state = AppState.idle;
  String message = '';
  int balanceBefore = 0;
  int balanceAfter = 0;
  int earned = 0;
  List<Map<String, dynamic>> redeemOptions = [];
  Map<String, String> headers = {};

  Future<bool> sendOtp(String phone) async {
    state = AppState.loading;
    message = '';
    notifyListeners();
    final result = await _service.sendOtp(phone);
    if (result['success']) {
      headers = result['headers'];
      state = AppState.success;
    } else {
      state = AppState.error;
      message = result['message'];
    }
    notifyListeners();
    return result['success'];
  }

  Future<bool> verifyOtp(String phone, String code) async {
    state = AppState.loading;
    notifyListeners();
    final result = await _service.verifyOtp(phone, code, headers);
    if (result['success']) {
      headers = result['headers'];
      state = AppState.success;
    } else {
      state = AppState.error;
      message = result['message'];
    }
    notifyListeners();
    return result['success'];
  }

  Future<void> collectAchievements() async {
    state = AppState.loading;
    message = 'جارٍ تجميع الكوينز...';
    notifyListeners();

    balanceBefore = await _service.getBalance(headers);

    for (int i = 0; i < 4; i++) {
      await _service.completeAchievements(headers);
    }

    balanceAfter = await _service.getBalance(headers);
    earned = balanceAfter - balanceBefore;
    redeemOptions = _service.buildRedeemOptions(balanceAfter);

    state = AppState.success;
    message = '';
    notifyListeners();
  }

  Future<bool> redeem(String code, int units) async {
    state = AppState.loading;
    notifyListeners();
    final result = await _service.redeem(headers, code, units);
    if (result) {
      balanceAfter = await _service.getBalance(headers);
      state = AppState.success;
      message = 'تم السحب بنجاح! +$units وحدة';
    } else {
      state = AppState.error;
      message = 'فشل السحب';
    }
    notifyListeners();
    return result;
  }
}
