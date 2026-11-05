
<?php

header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['erro' => 'Método não permitido']);
    exit;
}

$descricao = trim($_POST['descricao'] ?? '');

if ($descricao === '') {
    http_response_code(400);
    echo json_encode(['erro' => 'Informe a descrição da foto']);
    exit;
}

if (strlen($descricao) > 4000) {
    http_response_code(400);
    echo json_encode(['erro' => 'Descrição muito grande']);
    exit;
}

if (!isset($_FILES['foto'])) {
    http_response_code(400);
    echo json_encode(['erro' => 'Nenhuma foto recebida']);
    exit;
}

$foto = $_FILES['foto'];

if ($foto['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode(['erro' => 'Erro no recebimento da foto']);
    exit;
}

if ($foto['size'] > 5 * 1024 * 1024) {
    http_response_code(400);
    echo json_encode(['erro' => 'A foto ultrapassa 5 MB']);
    exit;
}

$finfo = new finfo(FILEINFO_MIME_TYPE);
$tipo = $finfo->file($foto['tmp_name']);

$tiposPermitidos = [
    'image/jpeg' => 'jpg',
    'image/png' => 'png',
    'image/webp' => 'webp'
];

$imagemValida = @getimagesize($foto['tmp_name']);

if (!isset($tiposPermitidos[$tipo]) || $imagemValida === false) {
    http_response_code(400);
    echo json_encode(['erro' => 'Formato de imagem inválido']);
    exit;
}

$diretorio = __DIR__ . '/fotos';

if (!is_dir($diretorio)) {
    if (!mkdir($diretorio, 0755, true) && !is_dir($diretorio)) {
        http_response_code(500);
        echo json_encode(['erro' => 'Não foi possível criar a pasta']);
        exit;
    }
}

$nomeArquivo = bin2hex(random_bytes(16)) . '.' . $tiposPermitidos[$tipo];

$caminho = $diretorio . '/' . $nomeArquivo;

if (!move_uploaded_file($foto['tmp_name'], $caminho)) {
    http_response_code(500);
    echo json_encode(['erro' => 'Não foi possível salvar a imagem']);
    exit;
}

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

    $comando = $dbh->prepare(
        "INSERT INTO fotos (arquivo, descricao)
         VALUES (:arquivo, :descricao)"
    );

    $comando->execute([
        ':arquivo' => $nomeArquivo,
        ':descricao' => $descricao
    ]);

    echo json_encode([
        'sucesso' => true,
        'mensagem' => 'Foto e descrição salvas com sucesso!',
        'id' => $dbh->lastInsertId()
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {

    if (file_exists($caminho)) {
        unlink($caminho);
    }

    http_response_code(500);

    echo json_encode([
        'erro' => 'Erro ao salvar foto e descrição no banco'
    ]);
}

?>
