<?php

use Castor\Attribute\AsTask;

use function Castor\io;
use function Castor\capture;
use function Castor\run;

/**
 * Installation et Initialisation
 */
#[AsTask(description: 'Initialisation du projet Symfony')]
function project_init(bool $node = false, bool $migrate = false) {


    io()->title('Initialisation du projet Symfony');

    $nodePacketManager = io()->ask('Quel packet manager utilisez-vous ? (yarn/npm)');

    io()->info('Installation des vendors');
    run('composer install');

    if ($node) {
        io()->info('Installation node_modules');
        run($nodePacketManager . ' install');
    }

    io()->info('Copie du .env');
    run('cp .env .env.local');

    io()->info('Mise en place des variables environnement');
    $dbUser = io()->ask('DatabaseUser:');
    $dbPassword = io()->askHidden('DatabasePassword:');
    $dbName = io()->ask('DatabaseName:');
    $dbHost = io()->ask('DatabaseHost:');
    $dbPort = io()->ask('DatabasePort:');

    $dbUrl = "DATABASE_URL=\"postgresql://$dbUser:$dbPassword@$dbHost:$dbPort/$dbName\"";
    run("sed -i 's|^DATABASE_URL=.*|$dbUrl|' .env.local");

    $smtpHost = io()->ask('SMTP Host:');
    $smtpPort = io()->ask('SMTP Port:');

    $mailerDsn = "MAILER_DSN=\"$smtpHost:$smtpPort\"";
    run("sed -i 's|^MAILER_DSN=.*|$mailerDsn|' .env.local");

    io()->info('Création de la BDD');
    run('bin/console d:d:c --if-not-exists');

    if ($migrate) {
        io()->info('Migration de la BDD');
        run('bin/console d:m:m -n');
    }
}

#[AsTask(description: 'Installe les paquets')]
function install_packages(): void
{
    io()->title('Installation du projet');
    $nodePacketManager = io()->ask('Quel packet manager utilisez-vous ? (yarn/npm)');

    run('composer install');
    run($nodePacketManager . ' install');
}

/**
 * Base de données
 */
#[AsTask(description: 'Création de la BDD')]
function create_db(): void
{
    io()->title('Creation de la BDD');
    run('php bin/console d:d:c --if-not-exists');
}

#[AsTask(description: 'Création des migrations')]
function create_migration(): void
{
    io()->title('Creation des migrations');
    run('php bin/console make:migration');
}

#[AsTask(description: 'Migration de la base de données')]
function migrate(): void
{
    io()->title('Migration de la BDD');
    run('php bin/console d:m:m -n');
}

/**
 * Qualité de code
 */
#[AsTask(description: 'Applique la qualité au level max sur le projet')]
function phpstan(): void
{
    $projectPath = getcwd();
    io()->info('Analyse du projet avec PHPStan');
    run('docker run --rm -v ' . $projectPath . ':/app -w /app jakzal/phpqa:latest phpstan analyse -c ./quality/phpstan.neon');
}

#[AsTask(description: 'Check la validation en PSR12')]
function phpcsfixer(): void
{
    $projectPath = getcwd();
    io()->info('Analyse du projet avec PHPCsFixer');
    run('docker run --rm -v ' . $projectPath . ':/app -w /app jakzal/phpqa:latest php-cs-fixer --config=./quality/.php-cs-fixer.dist.php fix ./src');
}

#[AsTask(description: 'Fix les erreurs PSR12')]
function phpcbf(): void
{
    $projectPath = getcwd();
    io()->info('Analyse du projet avec PHPCbf');
    run('docker run --rm -v ' . $projectPath . ':/app -w /app jakzal/phpqa:latest phpcbf --standard=PSR12 --colors src tests || true');
}

/**
 * Gestion Git
 */
#[AsTask(description: 'Récupère la dernière version de la branche principale')]
function pull_main(bool $migrate = false): void
{
    run('git checkout main');
    run('git pull origin main');
    run('castor install-packages');
    if ($migrate) {
        run('castor migrate');
    }
    run('castor clean');
}

#[AsTask(description: 'Rebase la branche actuelle avec master')]
function rebase(string $branch): void
{
    run('castor pull-main');
    run(sprintf('git checkout %s', escapeshellarg($branch)));
    run('git rebase main');
}

/**
 * Maintenance
 */
#[AsTask(description: 'Nettoie le projet')]
function clean(string $env = 'dev'): void
{
    run(sprintf('bin/console c:c --env=%s', escapeshellarg($env)));
}

/**
 * Docker
 */

#[AsTask(description: 'Démarrage des containers Docker')]
function docker_up(): void
{
    io()->title('Démarrage des containers Docker');
    run('docker-compose up -d');
}

#[AsTask(description: 'Arrêt des containers Docker')]
function docker_down():void
{
    io()->title('Arrêt des containers Docker');
    run('docker-compose down');
}
