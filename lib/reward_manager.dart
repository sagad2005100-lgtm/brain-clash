
import 'package:shared_preferences/shared_preferences.dart';

class RewardManager {
  static const String coinKey = 'brain_coins';
  static const String xpKey = 'brain_xp';

  static Future<int> getCoins() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(coinKey) ?? 0;
  }

  static Future<int> getXP() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(xpKey) ?? 0;
  }

  static Future<int> getPlayerLevel() async =>
      (await getXP() ~/ 100) + 1;

  static Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    final p = await SharedPreferences.getInstance();
    await p.setInt(coinKey, (p.getInt(coinKey) ?? 0) + amount);
  }

  static Future<void> addXP(int amount) async {
    if (amount <= 0) return;
    final p = await SharedPreferences.getInstance();
    await p.setInt(xpKey, (p.getInt(xpKey) ?? 0) + amount);
  }

  static Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;
    final p = await SharedPreferences.getInstance();
    final coins = p.getInt(coinKey) ?? 0;
    if (coins < amount) return false;
    await p.setInt(coinKey, coins - amount);
    return true;
  }

  static Future<bool> isStageCompleted(int world, int stage) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('reward_w${world}_s$stage') ?? false;
  }

  static Future<int> getStageStars(int world, int stage) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('stars_w${world}_s$stage') ?? 0;
  }

  static Future<Map<String, int>> completeStage(
    int world,
    int stage,
    int score,
  ) async {
    final p = await SharedPreferences.getInstance();
    final key = 'reward_w${world}_s$stage';
    final starsKey = 'stars_w${world}_s$stage';

    final stars = score >= 9 ? 3 : score >= 7 ? 2 : score >= 5 ? 1 : 0;
    final oldStars = p.getInt(starsKey) ?? 0;
    final bestStars = stars > oldStars ? stars : oldStars;

    await p.setInt(starsKey, bestStars);

    if (p.getBool(key) ?? false) {
      return {'stars': bestStars, 'coins': 0, 'xp': 0};
    }

    final coins = score * 5 + stars * 10;
    final xp = score * 10 + stars * 20;

    await p.setBool(key, true);
    await p.setInt(coinKey, (p.getInt(coinKey) ?? 0) + coins);
    await p.setInt(xpKey, (p.getInt(xpKey) ?? 0) + xp);

    return {'stars': stars, 'coins': coins, 'xp': xp};
  }
}
