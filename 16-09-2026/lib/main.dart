import 'package:flutter/material.dart';

void main() {
  runApp(const EnvioDadosApp());
}

class EnvioDadosApp extends StatelessWidget {
  const EnvioDadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enviando dados',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const EscolhaPage(),
    );
  }
}

class EscolhaPage extends StatelessWidget {
  const EscolhaPage({super.key});

  final List<String> frutas = const ['Abóbora', 'Banana', 'Jaca'];

  void abrirDetalhe(BuildContext context, String fruta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhePage(fruta: fruta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha uma fruta')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Toque em uma fruta para enviá-la à próxima tela:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ...frutas.map(
              (fruta) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => abrirDetalhe(context, fruta),
                  child: Text(fruta),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetalhePage extends StatelessWidget {
  const DetalhePage({required this.fruta, super.key});

  final String fruta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fruta recebida')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A fruta recebida foi: $fruta',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
