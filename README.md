<p align="center">
</p>

<h3 align="center">Service de géocodage</h3>
<p align="center">Migration du service de géocodage en utilisant Pelias.</p>

<details open>
<summary>Information</summary>
<br />
Ce document présentation la mise en place du géocodeur <a href="https://github.com/pelias/pelias">Pelias</a> sur un environnement Centos 7.
</details>

## Pré-requis

Avant de continuer, il est nécessaire d'avoir installé sur le système:

- une [version moderne de `docker`](https://docs.docker.com/engine/release-notes/)
- une [version moderne de `docker-compose`](https://github.com/docker/compose/blob/master/CHANGELOG.md) installed before continuing. If you are not using the latest version, please mention that in any bugs reports.

Suivre les étapes d'installations disponible sur la documentation de docker [Install Docker Engine on CentOS](https://docs.docker.com/engine/install/centos/).

## Pré-requis pour Linux

- Install `util-linux` using your distribution's package manager
  - Centos 7: `sudo yum install util-linux`

## Pré-requis Système

Les Scripts peuvent facilement téléchargement des dizaines de Go de données géographiques, assurez-vous d'avoir suffisamment d'espace disque de libre!

Au moins 8Go de RAM sont nécessaires.

## Script de démarrage rapide

The following shell script can be used to quickly get started with a Pelias build.

```bash
#!/bin/bash
set -x

# change directory to the where you would like to install Pelias
# cd /path/to/install

# clone this repository
git clone https://github.com/pelias/docker.git && cd docker

# install pelias script
ln -s "$(pwd)/pelias" /usr/local/bin/pelias

# cd into the project directory
cd projects/portland-metro

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

# optionally run tests
pelias test run
```

## Installation du script utilitairePelias

This repository makes use of a helper script to make basic management of the Pelias Docker images easy.

If you haven't done so already, you will need to ensure the `pelias` command is available on your path.

You can find the `pelias` file in the root of this repository.

Advanced users may have a preference how this is done on their system, but a basic example would be to do something like:

```bash
# change directory to the where you would like to install Pelias
# cd /path/to/install

# clone this repository
git clone https://github.com/pelias/docker.git && cd docker

# install pelias script
ln -s "$(pwd)/pelias" /usr/local/bin/pelias
```

Once the command is correctly installed you should be able to run the following command to confirm the pelias command is available on your path:

```bash
which pelias
```

### Resolving PATH issues

If you are having trouble getting this to work then quickly check that the target of the symlink is listed on your \$PATH:

```bash
tr ':' '\n' <<< "$PATH"
```

If you used the `ln -s` command above then the directory `/usr/local/bin` should be listed in the output.

If the symlink target path is _not_ listed, then you will either need to add its location to your $PATH or create a new symlink which points to a location which is already on your $PATH.

## Configure Environment

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
