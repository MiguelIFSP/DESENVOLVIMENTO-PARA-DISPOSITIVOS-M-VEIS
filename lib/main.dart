import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_14_10/helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController idAtualizarController = TextEditingController();
  final TextEditingController nomeAtualizarController = TextEditingController();
  final TextEditingController idadeAtualizarController =
      TextEditingController();
  final TextEditingController idApagarController = TextEditingController();

  Future<void> salvarPet() async {
    final nome = nomeController.text;
    final idade = int.tryParse(idadeController.text) ?? 0;

    if (nome.isEmpty) return;

    await DatabaseHelper.inserirPet({
      'nome': nome,
      'idade': idade,
    });

    nomeController.clear();
    idadeController.clear();
    setState(() {});
  }

  Future<void> atualizarPet() async {
    final id = int.tryParse(idAtualizarController.text) ?? 0;
    final nome = nomeAtualizarController.text;
    final idade = int.tryParse(idadeAtualizarController.text) ?? 0;

    if (id == 0 || nome.isEmpty) return;

    await DatabaseHelper.atualizarPet(id, {
      'nome': nome,
      'idade': idade,
    });

    idAtualizarController.clear();
    nomeAtualizarController.clear();
    idadeAtualizarController.clear();
    setState(() {});
  }

  Future<void> apagarPet() async {
    final id = int.tryParse(idApagarController.text) ?? 0;

    if (id == 0) return;

    await DatabaseHelper.apagarPet(id);
    idApagarController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Pets SQLite'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Salvar'),
                Tab(text: 'Listar'),
                Tab(text: 'Atualizar'),
                Tab(text: 'Apagar'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildSalvarTab(),
              _buildListarTab(),
              _buildAtualizarTab(),
              _buildApagarTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalvarTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do pet',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: idadeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Idade do pet',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: salvarPet,
            child: const Text('Salvar pet'),
          ),
        ],
      ),
    );
  }

  Widget _buildListarTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.listarPets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final pets = snapshot.data ?? [];

        if (pets.isEmpty) {
          return const Center(child: Text('Nenhum pet cadastrado.'));
        }

        return ListView.builder(
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return ListTile(
              title: Text('${pet['nome']}'),
              subtitle: Text('Idade: ${pet['idade']}'),
              trailing: Text('ID: ${pet['id']}'),
            );
          },
        );
      },
    );
  }

  Widget _buildAtualizarTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: idAtualizarController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ID do pet',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nomeAtualizarController,
            decoration: const InputDecoration(
              labelText: 'Novo nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: idadeAtualizarController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nova idade',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: atualizarPet,
            child: const Text('Atualizar pet'),
          ),
        ],
      ),
    );
  }

  Widget _buildApagarTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: idApagarController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ID do pet para apagar',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: apagarPet,
            child: const Text('Apagar pet'),
          ),
        ],
      ),
    );
  }
}
