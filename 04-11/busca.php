<?php
header('Content-Type: application/json; charset=utf-8');

$id = $_GET["id"];

$comando = "SELECT * FROM `textos` WHERE `id` > $id";

$dsn = 'mysql:dbname=banco;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare($comando);
$sth->execute();

$resultado = $sth->fetch(PDO::FETCH_ASSOC);

if($resultado) {
    echo json_encode($resultado);
} else {
    echo "Erro ao salvar!";
}
?>