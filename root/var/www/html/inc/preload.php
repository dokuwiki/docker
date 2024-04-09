<?php

/**
 * Read defaults from the core configuration directory
 *
 * @todo when #3760 is merged/addressed it should no longer be necessary to define
 *       DOKU_CONF and include config_cascade.php
 */
if (!defined('DOKU_CONF')) define('DOKU_CONF', __DIR__ . '/../conf/');
include __DIR__ . '/config_cascade.php';
$config_cascade['main']['default'] = ['/var/www/html/conf.core/dokuwiki.php'];
$config_cascade['acronyms']['default'] = ['/var/www/html/conf.core/acronyms.conf'];
$config_cascade['entities']['default'] = ['/var/www/html/conf.core/entities.conf'];
$config_cascade['interwiki']['default'] = ['/var/www/html/conf.core/interwiki.conf'];
$config_cascade['license']['default'] = ['/var/www/html/conf.core/license.php'];
$config_cascade['manifest']['default'] = ['/var/www/html/conf.core/manifest.json'];
$config_cascade['mediameta']['default'] = ['/var/www/html/conf.core/mediameta.php'];
$config_cascade['mime']['default'] = ['/var/www/html/conf.core/mime.conf'];
$config_cascade['scheme']['default'] = ['/var/www/html/conf.core/scheme.conf'];
$config_cascade['smileys']['default'] = ['/var/www/html/conf.core/smileys.conf'];
$config_cascade['wordblock']['default'] = ['/var/www/html/conf.core/wordblock.conf'];
$config_cascade['plugins']['default'] = ['/var/www/html/conf.core/plugins.php'];

