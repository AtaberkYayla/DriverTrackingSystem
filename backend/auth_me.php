<?php
require_once __DIR__ . '/lib_bootstrap.php';

$user = requireAuth($pdo);
json_success($user);
