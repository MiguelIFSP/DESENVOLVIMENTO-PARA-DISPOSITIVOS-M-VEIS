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
  final TextEditingController controladorNome = TextEditingController();
  bool temaEscuro = false;

  @override
  void initState() {
    super.initState();
    carregarConfiguracoes();
  }

  @override
  void dispose() {
    controladorNome.dispose();
    super.dispose();
  }

  Future<void> carregarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome_usuario') ?? '';
    final temaSalvo = prefs.getBool('tema_escuro') ?? false;
    setState(() {
      controladorNome.text = nome;
      temaEscuro = temaSalvo;
    });
  }

  Future<void> salvarNome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome_usuario', controladorNome.text.trim());
  }

  Future<void> mudarTema(bool valor) async {
    setState(() {
      temaEscuro = valor;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro', valor);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: temaEscuro ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(title: const Text('Configurações')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: controladorNome,
                decoration: const InputDecoration(
                  labelText: 'Nome do usuário',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: salvarNome,
                child: const Text('Salvar nome'),
              ),
              SwitchListTile(
                title: const Text('Tema escuro'),
                value: temaEscuro,
                onChanged: mudarTema,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
