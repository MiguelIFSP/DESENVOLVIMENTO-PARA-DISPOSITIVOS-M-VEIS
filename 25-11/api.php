<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

try {
    $mysqli = new mysqli('127.0.0.1', 'root', '', 'atividades_db');
    $mysqli->set_charset('utf8mb4');

    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $year = isset($_GET['year']) ? filter_var($_GET['year'], FILTER_VALIDATE_INT) : false;
        $month = isset($_GET['month']) ? filter_var($_GET['month'], FILTER_VALIDATE_INT) : false;

        if ($year === false || $year < 1000 || $year > 9999 ||
            $month === false || $month < 1 || $month > 12) {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Informe ano e mês válidos']);
            exit;
        }

        $stmt = $mysqli->prepare(
            'SELECT id, activity_date, description
             FROM activities
             WHERE YEAR(activity_date) = ? AND MONTH(activity_date) = ?
             ORDER BY activity_date, id'
        );
        $stmt->bind_param('ii', $year, $month);
        $stmt->execute();
        $result = $stmt->get_result();

        $activities = [];
        while ($row = $result->fetch_assoc()) {
            $activities[] = [
                'id' => (string) $row['id'],
                'date' => $row['activity_date'],
                'description' => $row['description'],
            ];
        }

        echo json_encode(['success' => true, 'activities' => $activities]);
        exit;
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $body = json_decode(file_get_contents('php://input'), true);
        $date = is_array($body) ? ($body['date'] ?? '') : '';
        $description = is_array($body) && is_string($body['description'] ?? null)
            ? trim($body['description'])
            : '';

        $parsedDate = is_string($date) && preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)
            ? DateTimeImmutable::createFromFormat('!Y-m-d', $date)
            : false;
        $dateErrors = DateTimeImmutable::getLastErrors();
        $validDate = $parsedDate &&
            $parsedDate->format('Y-m-d') === $date &&
            (int) substr($date, 0, 4) >= 1000 &&
            ($dateErrors === false ||
                ($dateErrors['warning_count'] === 0 && $dateErrors['error_count'] === 0));

        if (!$validDate || $description === '') {
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Data ou atividade inválida']);
            exit;
        }

        $stmt = $mysqli->prepare(
            'INSERT INTO activities (activity_date, description) VALUES (?, ?)'
        );
        $stmt->bind_param('ss', $date, $description);
        $stmt->execute();

        echo json_encode([
            'success' => true,
            'activity' => [
                'id' => (string) $stmt->insert_id,
                'date' => $date,
                'description' => $description,
            ],
        ]);
        exit;
    }

    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Método não permitido']);
} catch (mysqli_sql_exception $error) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Erro ao acessar o banco de dados']);
}
