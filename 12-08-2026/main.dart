import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const NovaApp());
}

class NovaApp extends StatefulWidget {
  const NovaApp({super.key});

  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> {
  String mensagem = 'Adivinha o numero de 1 a 5';

  void verificar(int palpite) {
    setState(() {
      int sorteado = Random().nextInt(5) + 1;
      
      if (palpite == sorteado) {
        mensagem = 'correto';
      }
      if (palpite != sorteado) {
        mensagem = 'errado';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mensagem),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () { verificar(1); },
                    child: const Text('1'),
                  ),
                  TextButton(
                    onPressed: () { verificar(2); },
                    child: const Text('2'),
                  ),
                  TextButton(
                    onPressed: () { verificar(3); },
                    child: const Text('3'),
                  ),
                  TextButton(
                    onPressed: () { verificar(4); },
                    child: const Text('4'),
                  ),
                  TextButton(
                    onPressed: () { verificar(5); },
                    child: const Text('5'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
