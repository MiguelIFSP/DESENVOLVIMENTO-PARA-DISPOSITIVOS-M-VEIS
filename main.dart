import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<Endereco> buscaEndereco(String cep) async {
  final resposta = await http.get(
    Uri.parse('https://viacep.com.br/ws/$cep/json/'),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode == 200) {
    final json = jsonDecode(resposta.body) as Map<String, dynamic>;
    if (json['erro'] == true) {
      throw const FormatException('CEP não encontrado.');
    }
    return Endereco.fromJson(json);
  }

  throw Exception('Falha ao consultar o CEP.');
}

class Endereco {
  final String rua;
  final String bairro;
  final String cidade;
  final String estado;

  const Endereco({
    required this.rua,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      rua: json['logradouro'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: json['localidade'] as String? ?? '',
      estado: json['uf'] as String? ?? '',
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _cepController = TextEditingController();
  Endereco? _endereco;
  String? _erro;
  bool _carregando = false;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _consultarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) {
      setState(() {
        _endereco = null;
        _erro = 'Digite um CEP com 8 números.';
      });
      return;
    }

    setState(() {
      _carregando = true;
      _endereco = null;
      _erro = null;
    });

    try {
      final endereco = await buscaEndereco(cep);
      if (mounted) {
        setState(() => _endereco = endereco);
      }
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _erro = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível consultar o CEP.');
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de CEP',
      home: Scaffold(
        appBar: AppBar(title: const Text('Consulta de CEP')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _cepController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: const InputDecoration(
                  labelText: 'CEP',
                  hintText: 'Digite os 8 números',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _consultarCep(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _carregando ? null : _consultarCep,
                child: const Text('Buscar endereço'),
              ),
              if (_carregando) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_erro != null) ...[
                const SizedBox(height: 16),
                Text(_erro!, style: TextStyle(color: Colors.red.shade700)),
              ],
              if (_endereco != null) ...[
                const SizedBox(height: 24),
                Text('Rua: ${_endereco!.rua}'),
                Text('Bairro: ${_endereco!.bairro}'),
                Text('Cidade: ${_endereco!.cidade}'),
                Text('Estado: ${_endereco!.estado}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
