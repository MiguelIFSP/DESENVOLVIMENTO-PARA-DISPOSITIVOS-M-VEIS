import 'package:flutter/material.dart';

void main() {
  runApp(const RotasApp());
}

class RotasApp extends StatelessWidget {
  const RotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navegação e rotas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PrimeiraTela(),
    );
  }
}

class PrimeiraTela extends StatelessWidget {
  const PrimeiraTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primeira tela')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SegundaTela(),
              ),
            );
          },
          child: const Text('Ir para a segunda tela'),
        ),
      ),
    );
  }
}

class SegundaTela extends StatelessWidget {
  const SegundaTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segunda tela')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar'),
        ),
      ),
    );
  }
}
