<?php

// initialize the farm if the farmer plugin is available
if (file_exists(__DIR__ . '/../lib/plugins/farmer/DokuWikiFarmCore.php')) {
    $_ENV['DOKU_FARMDIR'] = '/storage/farm/';
    include(__DIR__ . '/../lib/plugins/farmer/DokuWikiFarmCore.php');
}

// load the standard cascade if the farmer hasn't already loaded it
if (!defined('DOKU_CONF')) {
    define('DOKU_CONF', __DIR__ . '/../conf/');
    include __DIR__ . '/config_cascade.php';
}

// adjust the previously set config_cascade
array_unshift($config_cascade['main']['default'], '/var/www/html/conf.core/dokuwiki.php');
array_push($config_cascade['main']['default'], '/var/www/html/conf.core/docker.php');
array_unshift($config_cascade['main']['protected'], '/var/www/html/conf.core/docker.protected.php');
array_unshift($config_cascade['acronyms']['default'], '/var/www/html/conf.core/acronyms.conf');
array_unshift($config_cascade['entities']['default'], '/var/www/html/conf.core/entities.conf');
array_unshift($config_cascade['interwiki']['default'], '/var/www/html/conf.core/interwiki.conf');
array_unshift($config_cascade['license']['default'], '/var/www/html/conf.core/license.php');
array_unshift($config_cascade['manifest']['default'], '/var/www/html/conf.core/manifest.json');
array_unshift($config_cascade['mediameta']['default'], '/var/www/html/conf.core/mediameta.php');
array_unshift($config_cascade['mime']['default'], '/var/www/html/conf.core/mime.conf');
array_unshift($config_cascade['scheme']['default'], '/var/www/html/conf.core/scheme.conf');
array_unshift($config_cascade['smileys']['default'], '/var/www/html/conf.core/smileys.conf');
array_unshift($config_cascade['wordblock']['default'], '/var/www/html/conf.core/wordblock.conf');
array_unshift($config_cascade['plugins']['default'], '/var/www/html/conf.core/plugins.php');
array_unshift(
    $config_cascade['plugins']['protected'],
    '/var/www/html/conf.core/plugins.required.php',
    '/var/www/html/conf.core/plugins.docker.php'
);

