
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'reward_manager.dart';

const shopGold = Color(0xFFFFC857);
const shopBackground = Color(0xFF10121C);
const shopPanel = Color(0xFF1D2233);

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int coins = 0;
  int hints = 0;
  int extraLives = 0;

  @override
  void initState() {
    super.initState();
    loadShop();
  }

  Future<void> loadShop() async {
    final prefs = await SharedPreferences.getInstance();

    final c = await RewardManager.getCoins();
    final h = prefs.getInt('inventory_hints') ?? 0;
    final l = prefs.getInt('inventory_extra_lives') ?? 0;

    if (!mounted) return;

    setState(() {
      coins = c;
      hints = h;
      extraLives = l;
    });
  }

  Future<void> buyItem({
    required int price,
    required String inventoryKey,
    required String itemName,
  }) async {
    final success = await RewardManager.spendCoins(price);

    if (!mounted) return;

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(inventoryKey) ?? 0;

      await prefs.setInt(inventoryKey, count + 1);

      await loadShop();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم شراء $itemName بنجاح! 🎉')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رصيدك غير كافي! اجمع المزيد من العملات 🪙'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shopBackground,
      appBar: AppBar(
        title: const Text('المتجر'),
        backgroundColor: shopBackground,
      ),
      body: RefreshIndicator(
        onRefresh: loadShop,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: shopPanel,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on,
                      color: shopGold, size: 35),
                  const SizedBox(width: 12),
                  const Text('رصيدك', style: TextStyle(fontSize: 18)),
                  const Spacer(),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      color: shopGold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'العناصر المتاحة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            itemCard(
              emoji: '💡',
              title: 'تلميح ذكي',
              description: 'مساعدات أثناء التحديات • لديك $hints',
              price: 50,
              onBuy: () => buyItem(
                price: 50,
                inventoryKey: 'inventory_hints',
                itemName: 'التلميح',
              ),
            ),

            itemCard(
              emoji: '❤️',
              title: 'محاولة إضافية',
              description: 'محاولات إضافية • لديك $extraLives',
              price: 100,
              onBuy: () => buyItem(
                price: 100,
                inventoryKey: 'inventory_extra_lives',
                itemName: 'المحاولة الإضافية',
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'BRAIN CLASH SHOP',
                style: TextStyle(color: Colors.white30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemCard({
    required String emoji,
    required String title,
    required String description,
    required int price,
    required VoidCallback onBuy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: shopPanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 35)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 5),
                Text(description,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  '$price 🪙',
                  style: const TextStyle(
                      color: shopGold, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: shopGold,
              foregroundColor: Colors.black,
            ),
            child: const Text('شراء'),
          ),
        ],
      ),
    );
  }
}
