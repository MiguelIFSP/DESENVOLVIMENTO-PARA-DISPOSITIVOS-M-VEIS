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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GaleriaPage(),
    );
  }
}

class Fruta {
  const Fruta({required this.nome, required this.asset});

  final String nome;
  final String asset;
}

const frutas = [
  Fruta(nome: 'Abobora', asset: 'assets/abobora.png'),
  Fruta(nome: 'Banana', asset: 'assets/banana.png'),
  Fruta(nome: 'Jaca', asset: 'assets/jaca.png'),
];

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  final aprovadas = <Fruta>[];

  Future<void> avaliar(Fruta fruta) async {
    final aprovada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AvaliacaoPage(fruta: fruta)),
    );

    if (aprovada == true && !aprovadas.contains(fruta)) {
      setState(() => aprovadas.add(fruta));
    }
  }

  void abrirAprovadas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AprovadasPage(frutas: aprovadas)),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha uma imagem para avaliar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: frutas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final fruta = frutas[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => avaliar(fruta),
                      child: Column(
                        children: [
                          Expanded(child: ImagemFruta(fruta: fruta)),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              fruta.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: abrirAprovadas,
                icon: const Icon(Icons.favorite),
                label: Text('Ver aprovadas (${aprovadas.length})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagemFruta extends StatelessWidget {
  const ImagemFruta({required this.fruta, super.key});

  final Fruta fruta;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      fruta.asset,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_outlined, size: 48),
              const SizedBox(height: 8),
              Text(
                fruta.asset,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 260, child: ImagemFruta(fruta: fruta)),
            const SizedBox(height: 20),
            Text(
              'Voce aprova esta imagem?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.check),
                    label: const Text('Aprovar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Reprovar'),
                  ),
                ),
              ],
            ),
          ],
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
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: frutas.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final fruta = frutas[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(child: ImagemFruta(fruta: fruta)),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(fruta.nome),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
