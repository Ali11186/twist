import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/twist_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _collected = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TwistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twist'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('رصيد الكوينز', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${provider.balanceAfter}',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                    if (_collected && provider.earned > 0)
                      Text('+${provider.earned} كوينز مكتسبة',
                          style: const TextStyle(color: Colors.greenAccent)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (provider.message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: provider.state == AppState.error ? Colors.red.shade900 : Colors.green.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(provider.message, style: const TextStyle(color: Colors.white)),
                ),

              const SizedBox(height: 16),

              // Collect Button
              if (!_collected)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: provider.state == AppState.loading ? null : () async {
                      await provider.collectAchievements();
                      setState(() => _collected = true);
                    },
                    icon: const Icon(Icons.stars),
                    label: provider.state == AppState.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('تجميع الكوينز', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Redeem Options
              if (_collected && provider.redeemOptions.isNotEmpty) ...[
                const Text('اختر باقة السحب', style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.redeemOptions.length,
                    itemBuilder: (context, i) {
                      final opt = provider.redeemOptions[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          onPressed: provider.state == AppState.loading ? null : () async {
                            await provider.redeem(opt['code'], opt['units']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${opt['units']} وحدة',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('${opt['cost']} كوينز',
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              if (_collected && provider.redeemOptions.isEmpty && provider.state != AppState.loading)
                const Text('رصيد غير كافٍ للسحب', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
      ),
    );
  }
}
