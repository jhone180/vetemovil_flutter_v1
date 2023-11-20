import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Scaffold(
        body: Center(
          child: LoadTest(),
        ),
      ),
    );
  }
}

class LoadTest extends StatefulWidget {
  const LoadTest({Key? key}) : super(key: key);

  @override
  _LoadTestState createState() => _LoadTestState();
}

class _LoadTestState extends State<LoadTest> {
  final String apiUrl =
      'https://vetemovil.000webhostapp.com/usuario/consultarUsuario/username';

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _runLoadTest();
      },
      child: const Text('Run Load Test'),
    );
  }

  void _runLoadTest() async {
    final int numberOfRequests = 100; // Number of concurrent requests

    for (int i = 0; i < numberOfRequests; i++) {
      _makeRequest(i);
    }
  }

  void _makeRequest(int requestNumber) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Request $requestNumber - Status: ${response.statusCode}');
    } catch (e) {
      print('Request $requestNumber - Error: $e');
    }
  }
}
