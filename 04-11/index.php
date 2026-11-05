
<?php

$dsn = 'mysql:dbname=banco;host=127.0.0.1';
$user = 'root';
$password = '';

$erro = '';
$fotos = [];

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

    $fotos = $comando->fetchAll(PDO::FETCH_ASSOC);

} catch (PDOException $e) {
    $erro = 'Não foi possível carregar as fotos.';
}

function escapar($valor) {
    return htmlspecialchars(
        (string) $valor,
        ENT_QUOTES,
        'UTF-8'
    );
}

?>

<!DOCTYPE html>
<html lang="pt-BR">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Galeria de Fotos</title>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background-color: #f1f3f5;
            margin: 0;
            padding: 25px;
        }

        header {
            text-align: center;
            margin-bottom: 30px;
        }

        header h1 {
            color: #222;
            font-size: 30px;
        }

        header p {
            color: #666;
        }

        .galeria {
            max-width: 1100px;
            margin: auto;
            display: grid;
            grid-template-columns: repeat(
                auto-fit,
                minmax(250px, 1fr)
            );
            gap: 22px;
        }

        .card {
            background-color: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 3px 12px rgba(0,0,0,0.10);
        }

        .card img {
            width: 100%;
            height: 230px;
            object-fit: cover;
            display: block;
        }

        .conteudo {
            padding: 18px;
        }

        .conteudo h2 {
            font-size: 18px;
            color: #222;
            margin-top: 0;
        }

        .descricao {
            color: #555;
            font-size: 15px;
            line-height: 1.5;
            overflow-wrap: anywhere;
        }

        .data {
            color: #999;
            font-size: 12px;
            margin-top: 15px;
        }

        .mensagem {
            text-align: center;
            background: white;
            padding: 30px;
            border-radius: 10px;
            max-width: 500px;
            margin: auto;
            color: #555;
        }

        .atualizar {
            display: block;
            width: fit-content;
            margin: 0 auto 30px;
            padding: 12px 22px;
            background: #1976d2;
            color: white;
            text-decoration: none;
            border-radius: 7px;
        }

        .atualizar:hover {
            background: #125ca1;
        }

    </style>

</head>

<body>

    <header>

        <h1>Galeria de Fotos</h1>

        <p>Fotos e descrições enviadas pelo aplicativo</p>

    </header>

    <a class="atualizar" href="index.php">
        Atualizar Galeria
    </a>

    <?php if ($erro !== ''): ?>

        <div class="mensagem">
            <?= escapar($erro) ?>
        </div>

    <?php elseif (count($fotos) === 0): ?>

        <div class="mensagem">
            <h2>Nenhuma foto cadastrada</h2>
            <p>Envie uma foto pelo aplicativo para ela aparecer aqui.</p>
        </div>

    <?php else: ?>

        <main class="galeria">

            <?php foreach ($fotos as $foto): ?>

                <?php
                    $nomeArquivo = basename($foto['arquivo']);
                    $caminhoImagem = 'fotos/' . rawurlencode($nomeArquivo);
                ?>

                <article class="card">

                    <img
                        src="<?= escapar($caminhoImagem) ?>"
                        alt="Foto <?= escapar($foto['id']) ?>"
                    >

                    <div class="conteudo">

                        <h2>
                            Foto <?= escapar($foto['id']) ?>
                        </h2>

                        <p class="descricao">
                            <?= nl2br(escapar(
                                $foto['descricao'] ?? 'Sem descrição cadastrada'
                            )) ?>
                        </p>

                        <p class="data">
                            Enviada em:
                            <?= escapar($foto['data_criacao']) ?>
                        </p>

                    </div>

                </article>

            <?php endforeach; ?>

        </main>

    <?php endif; ?>

</body>
</html>
