import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/twist_provider.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TwistProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('رمز التحقق'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.purple),
              const SizedBox(height: 16),
              Text('أدخل الكود المرسل إلى ${widget.phone}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '------',
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              if (provider.state == AppState.error)
                Text(provider.message, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.state == AppState.loading ? null : () async {
                    final code = _otpController.text.trim();
                    if (code.isEmpty) return;
                    final ok = await provider.verifyOtp(widget.phone, code);
                    if (ok && context.mounted) {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: provider.state == AppState.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تحقق', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
