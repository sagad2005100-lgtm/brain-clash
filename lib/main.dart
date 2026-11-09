
import 'package:flutter/material.dart';
import 'game_page.dart';

void main() {
  runApp(const BrainClash());
}

class BrainClash extends StatelessWidget {
  const BrainClash({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain Clash',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080D1B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6AE55),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF172442),
              Color(0xFF080D1B),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.psychology_alt,
                    size: 105,
                    color: Color(0xFFD6AE55),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Brain Clash',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD6AE55),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'صراع العقول',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 55),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6AE55),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GamePage(),
                          ),
                        );
                      },
                      child: const Text(
                        'ابدأ اللعب',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
