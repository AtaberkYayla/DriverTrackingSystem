<?php
require_once __DIR__ . '/lib_bootstrap.php';

// Eski admin_list_accounts() RPC'sinin karsiligi.
requireRole($pdo, ['manager', 'admin']);

$stmt = $pdo->query(
    'SELECT id, full_name, role, aktif, username, created_at FROM users ORDER BY role, full_name'
);
json_success(boolifyAll($stmt->fetchAll(), ['aktif']));
