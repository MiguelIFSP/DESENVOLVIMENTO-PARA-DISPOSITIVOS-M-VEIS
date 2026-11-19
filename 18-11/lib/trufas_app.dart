import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SistemaTrufasApp extends StatelessWidget {
  const SistemaTrufasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produção de Trufas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const TelaInicial(),
    );
  }
}

String get apiUrl {
  if (Platform.isAndroid) return 'http://10.0.2.2/trufa/site_trufa.php';
  return 'http://127.0.0.1/trufa/site_trufa.php';
}

Future<Map<String, dynamic>> chamadaApi(Map<String, String> dados) async {
  final resposta = await http.post(
    Uri.parse(apiUrl),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: dados,
  );

  if (resposta.statusCode != 200) {
    return {'erro': 'Falha ao conectar ao servidor'};
  }
  return jsonDecode(resposta.body) as Map<String, dynamic>;
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  @override
  void initState() {
    super.initState();
    verificarLogin();
  }

  Future<void> verificarLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final perfil = prefs.getString('perfil');

    if (!mounted) return;
    if (perfil == 'produtor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaProdutor()),
      );
    } else if (perfil == 'vendedor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaVendedor()),
      );
    } else if (perfil == 'gerente') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaBasica(perfil: 'Gerente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sistema de Trufas')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaLogin()),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaCadastro()),
              ),
              child: const Text('Cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  String perfil = 'produtor';
  String mensagem = '';

  Future<void> cadastrar() async {
    if (nome.text.isEmpty || email.text.isEmpty || senha.text.isEmpty) {
      setState(() => mensagem = 'Preencha todos os dados');
      return;
    }

    final resposta = await chamadaApi({
      'acao': 'cadastrar',
      'nome': nome.text,
      'email': email.text,
      'senha': senha.text,
      'perfil': perfil,
    });

    if (resposta['sucesso'] == null) {
      setState(() => mensagem = resposta['erro'] ?? 'Erro ao cadastrar');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usuario_id', resposta['usuario']['id']);
    await prefs.setString('usuario_nome', resposta['usuario']['nome']);
    await prefs.setString('perfil', resposta['usuario']['perfil']);

    if (!mounted) return;
    if (perfil == 'produtor') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaProdutor()),
        (_) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaVendedor()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nome,
                decoration: const InputDecoration(labelText: 'Nome')),
            TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'E-mail')),
            TextField(
                controller: senha,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha')),
            DropdownButtonFormField<String>(
              value: perfil,
              items: const [
                DropdownMenuItem(value: 'produtor', child: Text('Produtor')),
                DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
              ],
              onChanged: (valor) => setState(() => perfil = valor!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: cadastrar, child: const Text('Cadastrar')),
            const SizedBox(height: 10),
            Text(mensagem),
          ],
        ),
      ),
    );
  }
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final email = TextEditingController();
  final senha = TextEditingController();
  String mensagem = '';

  Future<void> entrar() async {
    final resposta = await chamadaApi({
      'acao': 'login',
      'email': email.text,
      'senha': senha.text,
    });

    if (resposta['sucesso'] == null) {
      setState(() => mensagem = resposta['erro'] ?? 'Erro ao entrar');
      return;
    }

    final usuario = resposta['usuario'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usuario_id', usuario['id']);
    await prefs.setString('usuario_nome', usuario['nome']);
    await prefs.setString('perfil', usuario['perfil']);

    if (!mounted) return;
    final perfil = usuario['perfil'];
    if (perfil == 'produtor') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaProdutor()),
        (_) => false,
      );
    } else if (perfil == 'vendedor') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaVendedor()),
        (_) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TelaBasica(perfil: 'Gerente')),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'E-mail')),
            TextField(
                controller: senha,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: entrar, child: const Text('Entrar')),
            const SizedBox(height: 10),
            Text(mensagem),
          ],
        ),
      ),
    );
  }
}

class TelaProdutor extends StatefulWidget {
  const TelaProdutor({super.key});

  @override
  State<TelaProdutor> createState() => _TelaProdutorState();
}

class _TelaProdutorState extends State<TelaProdutor> {
  final quantidade = TextEditingController();
  final valorUnitario = TextEditingController();
  double total = 0;
  double comissao = 0;
  double totalComDesconto = 0;
  List<Map<String, dynamic>> producoes = [];
  final double percentualComissao = 0.10;

  @override
  void initState() {
    super.initState();
    carregarProducoes();
  }

  Future<void> carregarProducoes() async {
    final prefs = await SharedPreferences.getInstance();
    final resposta = await chamadaApi({
      'acao': 'listar_producoes',
      'produtor_id': (prefs.getInt('usuario_id') ?? 0).toString(),
    });

    if (resposta['sucesso'] == null || !mounted) return;
    setState(() {
      producoes = List<Map<String, dynamic>>.from(resposta['producoes']);
    });
  }

  Future<void> registrar() async {
    final qtd = int.tryParse(quantidade.text) ?? 0;
    final valor = double.tryParse(valorUnitario.text.replaceAll(',', '.')) ?? 0;

    if (qtd <= 0 || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe quantidade e valor válidos')),
      );
      return;
    }

    setState(() {
      total = qtd * valor;
      comissao = total * percentualComissao;
      totalComDesconto = total - comissao;
    });

    final prefs = await SharedPreferences.getInstance();
    final resposta = await chamadaApi({
      'acao': 'registrar_producao',
      'produtor_id': (prefs.getInt('usuario_id') ?? 0).toString(),
      'quantidade': qtd.toString(),
      'valor_unitario': valor.toString(),
    });

    if (!mounted) return;
    final mensagem = resposta['sucesso'] ?? resposta['erro'] ?? 'Erro';

    if (resposta['sucesso'] != null) {
      quantidade.clear();
      valorUnitario.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> editar(Map<String, dynamic> producao) async {
    final qtd = TextEditingController(text: producao['quantidade'].toString());
    final valor =
        TextEditingController(text: producao['valor_unitario'].toString());

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar produção'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: qtd,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade')),
            TextField(
                controller: valor,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor unitário')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final resposta = await chamadaApi({
                'acao': 'editar_producao',
                'id': producao['id'].toString(),
                'quantidade': qtd.text,
                'valor_unitario': valor.text.replaceAll(',', '.'),
              });
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              if (resposta['sucesso'] != null) await carregarProducoes();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TelaInicial()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produção do Produtor'),
        actions: [IconButton(onPressed: sair, icon: const Icon(Icons.logout))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: quantidade,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Quantidade de trufas')),
            TextField(
                controller: valorUnitario,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor unitário')),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: registrar, child: const Text('Registrar produção')),
            const SizedBox(height: 16),
            Text(
                'Comissão atual: ${(percentualComissao * 100).toStringAsFixed(0)}%'),
            Text('Valor total: R\$ ${total.toStringAsFixed(2)}'),
            Text('Desconto da comissão: R\$ ${comissao.toStringAsFixed(2)}'),
            Text(
                'Valor após comissão: R\$ ${totalComDesconto.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            const Text('Minhas produções',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...producoes.map((p) => Card(
                  child: ListTile(
                    title: Text('${p['quantidade']} trufas'),
                    subtitle: Text(
                      'Valor unitário: R\$ ${p['valor_unitario']}\n'
                      'Comissão: R\$ ${p['valor_comissao']}\n'
                      'Valor líquido: R\$ ${p['valor_liquido']}\n'
                      'Horário: ${p['data_hora']}',
                    ),
                    trailing: TextButton(
                      onPressed: () => editar(p),
                      child: const Text('Editar'),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class TelaBasica extends StatelessWidget {
  const TelaBasica({super.key, required this.perfil});

  final String perfil;

  Future<void> sair(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TelaInicial()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Área do $perfil'),
        actions: [
          IconButton(
              onPressed: () => sair(context), icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(child: Text('Bem-vindo, $perfil')),
    );
  }
}

class TelaVendedor extends StatefulWidget {
  const TelaVendedor({super.key});

  @override
  State<TelaVendedor> createState() => _TelaVendedorState();
}

class _TelaVendedorState extends State<TelaVendedor> {
  List<Map<String, dynamic>> producoes = [];
  final Map<int, TextEditingController> quantidades = {};

  @override
  void initState() {
    super.initState();
    carregarProducoes();
  }

  @override
  void dispose() {
    for (final controlador in quantidades.values) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> carregarProducoes() async {
    final resposta = await chamadaApi({'acao': 'listar_todas_producoes'});
    if (!mounted) return;

    if (resposta['sucesso'] != null) {
      setState(() {
        producoes = List<Map<String, dynamic>>.from(resposta['producoes']);
        for (final producao in producoes) {
          final id = int.parse(producao['id'].toString());
          quantidades.putIfAbsent(id, TextEditingController.new);
        }
      });
    }
  }

  Future<void> comprar(Map<String, dynamic> producao) async {
    final id = int.parse(producao['id'].toString());
    final quantidade = int.tryParse(quantidades[id]!.text) ?? 0;

    if (quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida')),
      );
      return;
    }

    final estoque = int.parse(producao['estoque'].toString());
    if (quantidade > estoque) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade maior que o estoque')),
      );
      return;
    }

    final resposta = await chamadaApi({
      'acao': 'comprar_producao',
      'id': id.toString(),
      'quantidade': quantidade.toString(),
    });

    if (!mounted) return;
    if (resposta['sucesso'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resposta['erro'] ?? 'Erro na compra')),
      );
      return;
    }

    final dados = resposta['dados'];
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dados da compra'),
        content: Text(
          'Produtor: ${producao['produtor']}\n'
          'Quantidade: ${dados['quantidade']} trufas\n'
          'Subtotal: R\$ ${double.parse(dados['subtotal'].toString()).toStringAsFixed(2)}\n'
          'Comissão: R\$ ${double.parse(dados['comissao'].toString()).toStringAsFixed(2)}\n'
          'Total: R\$ ${double.parse(dados['total'].toString()).toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );

    await carregarProducoes();
  }

  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TelaInicial()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Vendedor'),
        actions: [IconButton(onPressed: sair, icon: const Icon(Icons.logout))],
      ),
      body: producoes.isEmpty
          ? const Center(child: Text('Nenhuma produção disponível'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: producoes.length,
              itemBuilder: (context, indice) {
                final producao = producoes[indice];
                final id = int.parse(producao['id'].toString());

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Produtor: ${producao['produtor']}'),
                        Text('Estoque: ${producao['estoque']} trufas'),
                        Text(
                            'Valor unitário: R\$ ${producao['valor_unitario']}'),
                        const SizedBox(height: 10),
                        TextField(
                          controller: quantidades[id],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade desejada',
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => comprar(producao),
                          child: const Text('Comprar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
