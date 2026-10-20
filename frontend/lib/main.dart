import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Override with: flutter run --dart-define=API_URL=http://10.0.2.2:3000
// (10.0.2.2 is the host machine from the Android emulator.)
const apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000',
);

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const HealthPage(),
    );
  }
}

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late Future<Map<String, dynamic>> _health;

  @override
  void initState() {
    super.initState();
    _health = _fetchHealth();
  }

  Future<Map<String, dynamic>> _fetchHealth() async {
    final res = await http.get(Uri.parse('$apiUrl/api/health'));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backend status')),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _health,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Backend unreachable at $apiUrl\n${snapshot.error}',
                  textAlign: TextAlign.center);
            }
            final data = snapshot.data!;
            return Text('status: ${data['status']}\ntime: ${data['time']}',
                textAlign: TextAlign.center);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _health = _fetchHealth()),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
