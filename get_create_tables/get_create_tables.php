<?php

$host = 'localhost';
$dbname = 'your_db_name';
$username = 'your_db_user';
$password = 'your_db_password';

echo "Exporting table structures from DB...\n";
try {
    $pdo = new PDO(
        "mysql:host={$host};dbname={$dbname};charset=utf8mb4",
        $username,
        $password,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (Throwable $e) {
    fwrite(STDERR, "DB connection failed: " . $e->getMessage() . "\n");
    exit(1);
}

$outDir = __DIR__ . '/new_db_tables';
if (!is_dir($outDir)) mkdir($outDir, 0755, true);

$tables = [];
$stmt = $pdo->query('SHOW TABLES');
while ($row = $stmt->fetch(PDO::FETCH_NUM)) {
    $tables[] = $row[0];
}

if (empty($tables)) {
    echo "No tables found in DB.\n";
    exit(0);
}

$count = 0;
foreach ($tables as $table) {
    try {
        $sth = $pdo->prepare("SHOW CREATE TABLE `{$table}`");
        $sth->execute();
        $r = $sth->fetch(PDO::FETCH_ASSOC);
        $createSql = $r['Create Table'] ?? array_values($r)[1] ?? null;
        if (!$createSql) {
            echo "Skipping {$table}: cannot read CREATE TABLE\n";
            continue;
        }
        $filename = $outDir . '/' . $table . '.sql';
        $content = "-- Structure for table {$table}\n";
        $content .= "DROP TABLE IF EXISTS `{$table}`;\n";
        $content .= $createSql . ";\n";
        file_put_contents($filename, $content);
        echo "Written {$filename}\n";
        $count++;
    } catch (Throwable $e) {
        echo "Error exporting {$table}: " . $e->getMessage() . "\n";
    }
}

echo "Done. Exported {$count} tables into {$outDir}\n";
