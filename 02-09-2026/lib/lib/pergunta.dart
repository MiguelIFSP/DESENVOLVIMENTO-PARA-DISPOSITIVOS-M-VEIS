class Pergunta {
  const Pergunta(this.texto, this.respostas);

  final String texto;
  final List<String> respostas;

  List<String> embaralha() {
    final listaEmbaralhada = List<String>.from(respostas);
    listaEmbaralhada.shuffle();
    return listaEmbaralhada;
  }
}

//
