<?php
  $texto = $_GET["txt"];

  $comando = "INSERT INTO `textos` (`id`, `texto`) VALUES (NULL, '$texto')";

$dsn = 'mysql:dbname=banco;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$resultado = $dbh->query($comando);

if($resultado) {
    echo "Texto salvo!";
} else {
    echo "Erro ao salvar!";
}
?>