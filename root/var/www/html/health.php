<?php

if (!defined('STDERR')) define('STDERR', fopen('php://stderr', 'w')); // see dokuwiki/docker#15
define('DOKU_UNITTEST', 1);
if (!defined('DOKU_INC')) define('DOKU_INC', __DIR__ . '/');

header('Content-Type: text/plain; charset=utf-8');
try {
    ob_start();
    require DOKU_INC . 'inc/init.php';
    ob_end_clean();
    # if init didn't fail, DokuWiki should be generally okay
    echo 'ok';
} catch (\Exception $e) {
    ob_end_clean();
    header($_SERVER['SERVER_PROTOCOL'] . ' 500 Internal Server Error', true, 500);

    // ensure we have a good status message on failure
    $msg = $e->getMessage();
    $msg = strip_tags($msg);
    $msg = preg_replace('/^nice_die:/', '', $msg);
    $msg = preg_replace('/\s+/', ' ', $msg);
    $msg = trim($msg);
    echo $msg;
}
