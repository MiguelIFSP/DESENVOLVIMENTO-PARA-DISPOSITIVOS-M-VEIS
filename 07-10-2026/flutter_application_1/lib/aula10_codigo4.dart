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
  TextEditingController controlador = TextEditingController();
  int x = 0;

  @override
  void initState() {
    super.initState();
    buscaX();
  }

  void buscaX() async {
    final prefs = await SharedPreferences.getInstance();
    int valor = await prefs.getInt('x') ?? 0;
    setState(() {
      x = valor;
    });
    print('Mostrando x: $x');
  }

  void salvar() async {
    final prefs = await SharedPreferences.getInstance();
    int x = int.parse(controlador.text);
    await prefs.setInt('x', x);

    print('Salvando x:' + controlador.text);
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
              ElevatedButton(onPressed: salvar, child: Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
