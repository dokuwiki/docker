<?php
/**
 * This script generates the matrix for the Docker image build job
 *
 * It checks if changes in the DokuWiki branch, the upstream PHP image or the docker repo have been made
 * since it ran last time (using the github action cache for persistence). This allows us to run this every
 * day to catch any updates to the upstream images, while avoiding unnecessary rebuilds.
 */


/**
 * Get the list of DokuWiki versions from the download server
 *
 * @return array
 */
function getVersions()
{
    $data = file_get_contents('https://download.dokuwiki.org/version');
    return json_decode($data, true);
}

/**
 * Get the last commit of a branch
 *
 * @param string $repo
 * @param string $branch
 * @return string
 */
function getLastCommit($repo, $branch)
{
    $opts = [
        'http' => [
            'method' => "GET",
            'header' => join("\r\n", [
                "Accept: application/vnd.github.v3+json",
                "User-Agent: PHP"
            ])
        ]
    ];
    $context = stream_context_create($opts);

    $data = file_get_contents("https://api.github.com/repos/dokuwiki/$repo/commits/$branch", false, $context);
    $json = json_decode($data, true);
    return $json['sha'];
}

/**
 * Get the image id of a given PHP image tag
 *
 * @param string $tag
 * @return string
 */
function getImageId($tag)
{
    $repo = 'library/php';
    $data = file_get_contents('https://auth.docker.io/token?service=registry.docker.io&scope=repository:' . $repo . ':pull');
    $token = json_decode($data, true)['token'];


    $opts = [
        'http' => [
            'method' => "GET",
            'header' => join("\r\n", [
                "Authorization: Bearer $token",
                "Accept: application/vnd.docker.distribution.manifest.v2+json",
            ])
        ]
    ];
    $context = stream_context_create($opts);

    $data = file_get_contents('https://index.docker.io/v2/' . $repo . '/manifests/' . $tag, false, $context);
    $json = json_decode($data, true);
    return $json['config']['digest'];
}

/**
 * Get the image tag used in the current Dockerfile
 *
 * @return string
 */
function getImageTag()
{
    $df = file_get_contents('Dockerfile');
    preg_match('/FROM php:(?<tag>\S*)/', $df, $matches);
    return $matches['tag'];
}


$result = [];
$self = getLastCommit('docker', 'main');
$upstreamTag = getImageTag();
$image = getImageId($upstreamTag);

foreach (getVersions() as $release => $info) {
    $branch = $release === 'oldstable' ? 'old-stable' : $release;
    $commit = getLastCommit('dokuwiki', $branch);
    $ident = join('-', [$release, $commit, $image, $self]);
    $cache = '.github/matrix.cache/' . $release;

    $last = @file_get_contents($cache);
    fwrite(STDERR, "Old: $last\n");
    fwrite(STDERR, "New: $ident\n");
    if ($last === $ident) {
        // this combination has been built before
        fwrite(STDERR, "No change. Skipping $release\n");
        continue;
    }

    // this branch needs to be built
    $result[] = [
        'version' => $info['version'],
        'date' => $info['date'],
        'name' => $info['name'],
        'type' => $release,
    ];
    // update the cache
    if (!is_dir('.github/matrix.cache')) {
        mkdir('.github/matrix.cache');
    }
    file_put_contents($cache, $ident);
}

// output the result
if ($result) {
    echo "matrix=" . json_encode(['release' => $result]);
} else {
    echo "matrix=[]";
}
