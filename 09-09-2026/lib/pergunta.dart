class Pergunta {
  const Pergunta({required this.texto, required this.respostas});

  final String texto;
  final List<String> respostas;

  List<String> embaralhaRespostas() {
    final embaralhadas = List<String>.of(respostas);
    embaralhadas.shuffle();
    return embaralhadas;
  }
}
