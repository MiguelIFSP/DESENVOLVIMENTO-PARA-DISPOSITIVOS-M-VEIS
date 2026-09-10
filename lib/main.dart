import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'FraseControle.dart';

void main() {
  runApp(const Janela());
}

class Janela extends StatelessWidget {
  const Janela({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Principal()),
    );
  }
}

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  final FraseControle controle = FraseControle();

  void proximaFrase() {
    setState(() {
      controle.proximaFrase();
    });
  }

  void alternarLike() {
    setState(() {
      controle.fraseAtual.like = !controle.fraseAtual.like;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(controle.fraseAtual.texto,
            style: GoogleFonts.montserrat(
              fontSize: 28,
            )),
        Text(controle.fraseAtual.autor,
            style: GoogleFonts.msMadi(fontSize: 18)),
        IconButton(
          onPressed: alternarLike,
          icon: Icon(
            controle.fraseAtual.like ? Icons.favorite : Icons.favorite_border,
          ),
        ),
        ElevatedButton(
          onPressed: proximaFrase,
          child: Text('Próxima'),
        ),
      ],
    );
  }
}
