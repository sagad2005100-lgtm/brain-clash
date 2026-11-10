import 'package:shared_preferences/shared_preferences.dart';

class RewardManager {
  static const String coinKey = 'brain_coins';
  static const String xpKey = 'brain_xp';

  // قراءة رصيد العملات
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(coinKey) ?? 0;
  }

  // إضافة العملات
  static Future<void> addCoins(int amount) async {
    if (amount <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt(coinKey) ?? 0;

    await prefs.setInt(coinKey, coins + amount);
  }

  // صرف العملات
  static Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;

    final prefs = await SharedPreferences.getInstance();
    final coins = prefs.getInt(coinKey) ?? 0;

    if (coins < amount) return false;

    await prefs.setInt(coinKey, coins - amount);
    return true;
  }

  // قراءة الخبرة
  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(xpKey) ?? 0;
  }

  // إضافة الخبرة
  static Future<void> addXP(int amount) async {
    if (amount <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(xpKey) ?? 0;

    await prefs.setInt(xpKey, xp + amount);
  }

  // مستوى اللاعب
  static Future<int> getPlayerLevel() async {
    final xp = await getXP();
    return (xp ~/ 100) + 1;
  }

  // مكافأة إنهاء المرحلة
  static Future<Map<String, int>> completeStage(
    int world,
    int stage,
    int score,
  ) async {
    final stars = score >= 8 ? 3 : score >= 5 ? 2 : score >= 3 ? 1 : 0;

    final coins = score * 5 + stars * 10;
    final xp = score * 10 + stars * 20;

    await addCoins(coins);
    await addXP(xp);

    final prefs = await SharedPreferences.getInstance();
    final key = 'reward_w${world}_s$stage';

    if (!(prefs.getBool(key) ?? false)) {
      await prefs.setBool(key, true);
    }

    return {
      'stars': stars,
      'coins': coins,
      'xp': xp,
    };
  }
}
