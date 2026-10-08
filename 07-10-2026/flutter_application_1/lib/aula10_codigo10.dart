import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Vc não passou esse código, eu criei ele. É esse exercicio:
//                  - =  Exercício  = -
// Receba o CEP do usuário e o número da casa, use a API viacep
// para carregar rua, bairro, cidade, estado. Salve os dados
// usando shared_preferences. Carregue os dados na próxima
// inicialização da APP. Permita que o usuário apague os dados
// salvos.

Future<File> arquivoDiario() async {
  final pasta = await getApplicationDocumentsDirectory();
  return File('${pasta.path}/diário.txt');
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiarioHome(),
    );
  }
}

class DiarioHome extends StatefulWidget {
  const DiarioHome({super.key});

  @override
  State<DiarioHome> createState() => _DiarioHomeState();
}

class _DiarioHomeState extends State<DiarioHome> {
  final TextEditingController controlador = TextEditingController();
  bool salvando = false;

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  Future<void> salvarEntrada() async {
    final texto = controlador.text.trim().replaceAll(RegExp(r'[\r\n]+'), ' ');
    if (texto.isEmpty) return;

    setState(() {
      salvando = true;
    });

    try {
      final agora = DateTime.now();
      final data = '${agora.day.toString().padLeft(2, '0')}/'
          '${agora.month.toString().padLeft(2, '0')}/${agora.year}';
      final arquivo = await arquivoDiario();
      await arquivo.writeAsString(
        '$data - $texto\n',
        mode: FileMode.append,
        encoding: utf8,
        flush: true,
      );

      controlador.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada salva.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar a entrada.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  void abrirDiario() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const DiarioPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diário')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controlador,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Escreva no diário',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: salvando ? null : salvarEntrada,
              child: Text(salvando ? 'Salvando...' : 'Salvar entrada'),
            ),
            OutlinedButton(
              onPressed: abrirDiario,
              child: const Text('Visualizar diário'),
            ),
          ],
        ),
      ),
    );
  }
}

class DiarioPage extends StatefulWidget {
  const DiarioPage({super.key});

  @override
  State<DiarioPage> createState() => _DiarioPageState();
}

class _DiarioPageState extends State<DiarioPage> {
  String conteudo = '';
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregarDiario();
  }

  Future<void> carregarDiario() async {
    try {
      final arquivo = await arquivoDiario();
      final texto = await arquivo.exists()
          ? await arquivo.readAsString(encoding: utf8)
          : '';
      if (!mounted) return;
      setState(() {
        conteudo = texto;
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        erro = 'Não foi possível abrir o diário.';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu diário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : erro != null
                ? Text(erro!)
                : SingleChildScrollView(
                    child: SelectableText(
                      conteudo.isEmpty
                          ? 'O diário ainda está vazio.'
                          : conteudo,
                    ),
                  ),
      ),
    );
  }
}
