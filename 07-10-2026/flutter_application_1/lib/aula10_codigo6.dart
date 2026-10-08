import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController controlador = TextEditingController();
  int x = 0;

  @override
  void initState() {
    super.initState();
    buscaX();
  }

  Future<void> buscaX() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      x = prefs.getInt('x') ?? 0;
    });
  }

  Future<void> salvar() async {
    final valor = int.tryParse(controlador.text);
    if (valor == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('x', valor);

    setState(() {
      x = valor;
    });
  }

  Future<void> apagar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('x');

    setState(() {
      x = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('X salvo: $x'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Digite um número!',
                    border: OutlineInputBorder(),
                  ),
                  controller: controlador,
                ),
              ),
              ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
              ElevatedButton(onPressed: apagar, child: const Text('Apagar')),
            ],
          ),
        ),
      ),
    );
  }
}
