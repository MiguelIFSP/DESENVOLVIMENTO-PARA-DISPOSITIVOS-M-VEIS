import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MultiplicacaoPage(),
    );
  }
}

class MultiplicacaoPage extends StatefulWidget {
  const MultiplicacaoPage({super.key});

  @override
  State<MultiplicacaoPage> createState() => _MultiplicacaoPageState();
}

class _MultiplicacaoPageState extends State<MultiplicacaoPage> {
  int fator = 1;
  int multiplicador = 1;
  String resposta = '';
  int fatorErro = 1;
  int multiplicadorErro = 1;

  void adicionarNumero(String valor) {
    setState(() {
      resposta += valor;
    });
  }

  void limpar() {
    setState(() {
      resposta = '';
    });
  }

  void avancarCorreto() {
    setState(() {
      if (multiplicador >= 10) {
        fator++;
        multiplicador = 1;
      } else {
        multiplicador++;
      }
      resposta = '';
    });
  }

  void avancarErro() {
    setState(() {
      fator++;
      multiplicador = 1;
      resposta = '';
    });
  }

  void continuarDaErro() {
    setState(() {
      fator = fatorErro;
      multiplicador = multiplicadorErro;
      resposta = '';
    });
  }

  void verificar() {
    final valor = int.tryParse(resposta);
    final correto = fator * multiplicador;

    if (valor == correto) {
      avancarCorreto();
    } else {
      fatorErro = fator;
      multiplicadorErro = multiplicador;
      avancarErro();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Errou, clique aqui para continuar'),
          action: SnackBarAction(
            label: 'Continuar',
            onPressed: continuarDaErro,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$fator x $multiplicador = ?'),
            const SizedBox(height: 20),
            Text(
              resposta.isEmpty ? '0' : resposta,
              key: const ValueKey('resultado_display'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                botao('1'),
                botao('2'),
                botao('3'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                botao('4'),
                botao('5'),
                botao('6'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                botao('7'),
                botao('8'),
                botao('9'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [botao('0')],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: limpar, child: const Text('Limpar')),
                ElevatedButton(
                    onPressed: verificar, child: const Text('Verificar')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget botao(String numero) {
    return ElevatedButton(
      key: ValueKey('btn_$numero'),
      onPressed: () => adicionarNumero(numero),
      child: Text(numero),
    );
  }
}
