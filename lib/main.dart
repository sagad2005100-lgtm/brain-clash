import 'package:flutter/material.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101522),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFC107),
          secondary: Color(0xFF1769FF),
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology,
                  size: 100, color: Color(0xFFFFC107)),
              const SizedBox(height: 20),
              const Text(
                'صراع العقول',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC107),
                ),
              ),
              const Text(
                'BRAIN CLASH',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 4,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {},
                child: const Text('ابدأ اللعب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
