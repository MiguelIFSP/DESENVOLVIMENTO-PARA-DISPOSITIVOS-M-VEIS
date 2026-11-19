import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Aula10Codigo2 extends StatefulWidget {
  const Aula10Codigo2({super.key});

  @override
  State<Aula10Codigo2> createState() => _Aula10Codigo2State();
}

class _Aula10Codigo2State extends State<Aula10Codigo2> {
  final TextEditingController _controlador = TextEditingController();
  String _numeroSalvo = '';

  @override
  void initState() {
    super.initState();
    _carregarNumero();
  }

  Future<void> _carregarNumero() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _numeroSalvo = prefs.getString('numero_digitado') ?? '';
      _controlador.text = _numeroSalvo;
    });
  }

  Future<void> _salvarNumero() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = _controlador.text.trim();

    await prefs.setString('numero_digitado', valor);

    setState(() {
      _numeroSalvo = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_numeroSalvo.isEmpty
                  ? 'Antes de salvar'
                  : 'Número salvo: $_numeroSalvo'),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controlador,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Digite um número!',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _salvarNumero,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
