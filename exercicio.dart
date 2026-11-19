//Miguel
void main() {
  String nome = 'Camiseta ADS';
  int quantidade = 3;
  var preco = 49.90;
  bool disponivel = true;
  var imposto = 5.0;

  var total = (quantidade * preco) * (1 + imposto / 100);

  print('Produto: ' + nome.toString());
  print('Disponivel em estoque: ' + disponivel.toString());
  print('Quantidade: ' + quantidade.toString());
  print('Preco unitário: ' + preco.toString());
  print('Valor total: R\$ ' + total.toString());
}
