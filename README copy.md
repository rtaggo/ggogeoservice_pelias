<p align="center">
</p>

<h3 align="center">Service de géocodage</h3>
<p align="center">Migration du service de géocodage en utilisant Pelias.</p>

<details open>
<summary>Information</summary>
<br />
Ce document présentation la mise en place du géocodeur <a href="https://github.com/pelias/pelias">Pelias</a> sur un environnement Centos 7.
</details>

##

## Pré-requis

Avant de continuer, il est nécessaire d'avoir installé sur le système:

- une [version moderne de `docker`](https://docs.docker.com/engine/release-notes/)
- une [version moderne de `docker-compose`](https://github.com/docker/compose/blob/master/CHANGELOG.md)

Suivre les étapes d'installations disponible sur la documentation de docker [Install Docker Engine on CentOS](https://docs.docker.com/engine/install/centos/).

## Pré-requis pour Linux

Installer `util-linux`

- Centos 7: `sudo yum install util-linux`

## Pré-requis Système

Les Scripts peuvent facilement téléchargement des dizaines de Go de données géographiques, assurez-vous d'avoir suffisamment d'espace disque de libre!

Au moins 8Go de RAM sont nécessaires.

## Téléchargment de ce projet

```bash
# clone this repository
git clone https://github.com/rtaggo/ggogeoservice_pelias.git && cd ggogeoservice_pelias

```

## Script de démarrage rapide

Le script shell suivant permet de rapidement mettre en place Pelias.

```bash
#!/bin/bash
set -x

# change directory to the where you would like to install Pelias
# cd /path/to/install

# clone this repository
git clone https://github.com/pelias/docker.git && cd docker

# install pelias script if not already done
ln -s "$(pwd)/pelias" /usr/local/bin/pelias

# cd into the project directory
cd projects/france

# backup the original configuration files
mkdir configuration_backup
cp docker-compose.yml configuration_backup/docker-compose.yml
cp elasticsearch.yml configuration_backup/elasticsearch.yml
cp pelias.json configuration_backup/pelias

# copy the given pelias.json

# create a directory to store Pelias data files
# see: https://github.com/pelias/docker#variable-data_dir
# note: use 'gsed' instead of 'sed' on a Mac
mkdir ./data
sed -i '/DATA_DIR/d' .env
echo 'DATA_DIR=./data' >> .env

# configure docker to write files as your local user
# see: https://github.com/pelias/docker#variable-docker_user
# note: use 'gsed' instead of 'sed' on a Mac
sed -i '/DOCKER_USER/d' .env
echo "DOCKER_USER=$(id -u)" >> .env

# run build
pelias compose pull
pelias elastic start
pelias elastic wait
pelias elastic create
pelias download all
pelias prepare all
pelias import all
pelias compose up
```

## Installation du script utilitaire Pelias

Le dépôt du projet Pelias utilise un script utilitaire afin de gérer plus facilement les différentes images Docker.

Si ceci n'a pas déjà été fait, il faut s'assurer que la commande `pelias` est disponible dans votre \$PATH.

Vous trouverez le fichier `pelias` à la racine du dépôt du projet Pelias.

Les utilisateurs avancés peuvent avoir une préférence sur la façon dont cela est fait sur leur système, mais un exemple de base serait de faire quelque chose comme suit:

```bash
# change directory to the where you would like to install Pelias
# cd /path/to/install

# clone this repository
git clone https://github.com/pelias/docker.git && cd docker

# install pelias script
ln -s "$(pwd)/pelias" /usr/local/bin/pelias
```

Une fois la commande correctement installée, vous devriez pouvoir exécuter la commande suivante pour confirmer que la commande pelias est disponible sur votre chemin:

```bash
which pelias
```

### Résoudre les problème liés au \$PATH

Si vous ne parvenez pas à faire fonctionner cela, vérifiez rapidement que la cible du lien symbolique est répertoriée sur votre \$PATH:

```bash
tr ':' '\n' <<< "$PATH"
```

Si vous avez utilisé la commande `ln -s` ci-dessus, alors le répertoi `/usr/local/bin` devrait être listé dans la sortie.

Si le chemin cible du lien symbolique n'est pas répertorié, alors vous devrez soit ajouter son emplacement à votre \$PATH, soit créer un nouveau lien symbolique qui pointe vers un emplacement qui est déjà sur votre \$PATH.

## Configurer l'environment

The `pelias` command looks for an `.env` file in your **current working directory**, this file contains information specific to your local environment.

If this is your first time, you should change directories to an example project before continuing:

```bash
cd projects/portland-metro
```

Ensure that your current working directory contains the files: `.env`, `docker-compose.yml` and `pelias.json` before continuing.

### Variable: DATA_DIR

The only mandatory variable in `.env` is `DATA_DIR`.

This path reflects the directory Pelias will use to store downloaded data and use to build it's other microservices.

You **must** create a new directory which you will use for this project, for example:

```bash
mkdir /tmp/pelias
```

Then use your text editor to modify the `.env` file to reflect your new path, it should look like this:

```bash
COMPOSE_PROJECT_NAME=pelias
DATA_DIR=/tmp/pelias
DOCKER_USER=1000
```

You can then list the environment variables to ensure they have been correctly set:

```bash
pelias system env
```

### Variables: COMPOSE\_\*

The compose variables are optional and are documented here: https://docs.docker.com/compose/env-file/

Note: changing the `COMPOSE_PROJECT_NAME` variable is not advisable unless you know what you are doing. If you are migrating from the deprecated `pelias/dockerfiles` repository then you can set `COMPOSE_PROJECT_NAME=dockerfiles` to enable backwards compatibility with containers created using that repository.

### Variable: DOCKER_USER

All processes in Pelias containers are run as non-root users. By default, the UID of the processes will be `1000`, which is the first user ID on _most_ Linux systems and is likely to be a good option. However, if restricting file permissions in your data directory to a different user or group is important, this can be overridden by setting the `DOCKER_USER` variable.

This variable can take just a UID or a UID:GID combination such as `1000:1000`. See the [docker-compose](https://docs.docker.com/compose/compose-file/#domainname-hostname-ipc-mac_address-privileged-read_only-shm_size-stdin_open-tty-user-working_dir) and [docker run](https://docs.docker.com/engine/reference/run/#user) documentation on controlling Docker container users for more information.
