import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeria de frutas',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const GaleriaPage(),
    );
  }
}

class Fruta {
  const Fruta({required this.nome, required this.arquivo});

  final String nome;
  final String arquivo;
}

const frutas = [
  Fruta(nome: 'Abóbora', arquivo: 'abobora.jpg'),
  Fruta(nome: 'Banana', arquivo: 'Banana.jpg'),
  Fruta(nome: 'Jaca', arquivo: 'jaca.jpg'),
];

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  final List<Fruta> aprovadas = [];

  Future<void> avaliar(Fruta fruta) async {
    final bool? aprovada = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => AvaliacaoPage(fruta: fruta),
      ),
    );

    if (aprovada == true && !aprovadas.contains(fruta)) {
      setState(() => aprovadas.add(fruta));
    }
  }

  void abrirAprovadas() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AprovadasPage(frutas: aprovadas),
      ),
    );
  }

  Widget linhaDaFruta(Fruta fruta) {
    return GestureDetector(
      onTap: () => avaliar(fruta),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Image.asset(
              fruta.arquivo,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(fruta.nome, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria de frutas'),
        actions: [
          IconButton(
            tooltip: 'Ver imagens aprovadas',
            icon: const Icon(Icons.favorite),
            onPressed: abrirAprovadas,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Toque em uma imagem para avaliar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              ...frutas.map(linhaDaFruta),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: abrirAprovadas,
                icon: const Icon(Icons.favorite),
                label: Text('Ver aprovadas (${aprovadas.length})'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AvaliacaoPage extends StatelessWidget {
  const AvaliacaoPage({required this.fruta, super.key});

  final Fruta fruta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Avaliar ${fruta.nome}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(fruta.arquivo, height: 260, fit: BoxFit.contain),
              const SizedBox(height: 20),
              Text(
                'Você aprova esta imagem?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Aprovar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Reprovar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AprovadasPage extends StatelessWidget {
  const AprovadasPage({required this.frutas, super.key});

  final List<Fruta> frutas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imagens aprovadas')),
      body: frutas.isEmpty
          ? const Center(child: Text('Nenhuma imagem aprovada ainda.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...frutas.map(
                    (fruta) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Image.asset(
                            fruta.arquivo,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 16),
                          Text(fruta.nome),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
