
<?php

header('Content-Type: application/json; charset=utf-8');

$dsn = 'mysql:dbname=banco;host=127.0.0.1';
$user = 'root';
$password = '';

try {

    $dbh = new PDO(
        $dsn,
        $user,
        $password,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    $comando = $dbh->query(
        "SELECT id, arquivo, descricao, data_criacao
         FROM fotos
         ORDER BY id DESC"
    );

    $resultado = $comando->fetchAll(PDO::FETCH_ASSOC);

    $protocolo = (
        !empty($_SERVER['HTTPS']) &&
        $_SERVER['HTTPS'] !== 'off'
    ) ? 'https' : 'http';

    $host = $_SERVER['HTTP_HOST'];

    $pasta = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/\\');

    $fotos = [];

    foreach ($resultado as $foto) {

        $fotos[] = [
            'id' => $foto['id'],
            'descricao' => $foto['descricao'],
            'url' => $protocolo . '://' . $host .
                     $pasta . '/fotos/' .
                     rawurlencode($foto['arquivo']),
            'data_criacao' => $foto['data_criacao']
        ];

    }

    echo json_encode($fotos, JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {

    http_response_code(500);

    echo json_encode([
        'erro' => 'Erro ao consultar as fotos no banco de dados'
    ]);

}

?>
