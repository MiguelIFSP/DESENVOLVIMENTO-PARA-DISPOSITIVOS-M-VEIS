import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<File> arquivoOrganiza() async {
  final pasta = await getApplicationDocumentsDirectory();
  return File('${pasta.path}/organiza.md');
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
      home: EditorMarkdown(),
    );
  }
}

class EditorMarkdown extends StatefulWidget {
  const EditorMarkdown({super.key});

  @override
  State<EditorMarkdown> createState() => _EditorMarkdownState();
}

class _EditorMarkdownState extends State<EditorMarkdown> {
  final TextEditingController controlador = TextEditingController();
  String mensagem = '';
  bool processando = false;

  @override
  void initState() {
    super.initState();
    carregarArquivo();
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  Future<void> carregarArquivo() async {
    try {
      final arquivo = await arquivoOrganiza();
      final texto = await arquivo.exists()
          ? await arquivo.readAsString(encoding: utf8)
          : '';
      if (!mounted) return;
      setState(() {
        controlador.text = texto;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        mensagem = 'Não foi possível abrir organiza.md.';
      });
    }
  }

  Future<void> salvar() async {
    setState(() {
      processando = true;
      mensagem = '';
    });

    try {
      final arquivo = await arquivoOrganiza();
      await arquivo.writeAsString(controlador.text, encoding: utf8);
      if (!mounted) return;
      setState(() {
        mensagem = 'Arquivo salvo.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        mensagem = 'Não foi possível salvar organiza.md.';
      });
    } finally {
      if (mounted) {
        setState(() {
          processando = false;
        });
      }
    }
  }

  Future<void> apagar() async {
    setState(() {
      processando = true;
      mensagem = '';
    });

    try {
      final arquivo = await arquivoOrganiza();
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
      controlador.clear();
      if (!mounted) return;
      setState(() {
        mensagem = 'Arquivo apagado.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        mensagem = 'Não foi possível apagar organiza.md.';
      });
    } finally {
      if (mounted) {
        setState(() {
          processando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor Markdown')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: controlador,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'organiza.md',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: processando ? null : salvar,
                    child: const Text('Salvar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: processando ? null : apagar,
                    child: const Text('Apagar'),
                  ),
                ),
              ],
            ),
            if (mensagem.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(mensagem),
            ],
          ],
        ),
      ),
    );
  }
}
