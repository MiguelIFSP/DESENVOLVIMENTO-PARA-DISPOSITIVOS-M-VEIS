import 'package:flutter/material.dart';
import 'package:flutter_application_2/pergunta.dart';
import 'package:flutter_application_2/questoes.dart';

class Janela2 extends StatelessWidget {
  const Janela2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Pergunta teste1 = questoes[2];
    final respostas = teste1.respostas;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/imagens/palhaco_ouve.png',
              ),
            ),
          ),
          Text(teste1.texto),
          const SizedBox(
            height: 10,
          ),
          ...respostas.map((resposta) {
            return ElevatedButton(
              onPressed: () {},
              child: Text(resposta),
            );
          }),
        ],
      ),
    );
  }
}
