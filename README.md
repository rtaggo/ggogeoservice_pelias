<p align="center">
</p>

<h3 align="center">Service de géocodage</h3>
<p align="center">Migration du service de géocodage en utilisant Pelias.</p>

<details open>
<summary>Information</summary>
<br />
Ce document présentation la mise en place du géocodeur <a href="https://github.com/pelias/pelias">Pelias</a> sur un environnement Centos 7.
</details>

# Pelias pour la France et DOM/TOM

Ce dépôt est configuré pour télécharger/preparer/construire une solution complète de Pelias pour la France et les DOM/TOM.

# Pré-requis

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

### Scripts de démarrage rapide

Les trois scripts shell de ce dépôt sont à exécuter dans l'ordre suivant

1. `01_setup_env.sh` : configurer l'envrionnement
1. `02_run_pelias.sh` : construire la solution Pelias
1. `03_cleanup.sh` : nettoyer les fichiers temporaires

Pensez à rendre ces scripts exécutables:

```bash
chmod 755 *.sh
```

### Tester votre installation

You can now make queries against your new Pelias build:

```bash
curl http://localhost:4000/v1/search?text=Paris
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

Si vous avez utilisé la commande `ln -s` ci-dessus, alors le répertoire `/usr/local/bin` devrait être listé dans la sortie.

Si le chemin cible du lien symbolique n'est pas répertorié, alors vous devrez soit ajouter son emplacement à votre \$PATH, soit créer un nouveau lien symbolique qui pointe vers un emplacement qui est déjà sur votre \$PATH.

## en détails

Le script shell suivant permet de rapidement mettre en place Pelias (les commandes peuvent être exécutée une par une dans le terminal).

```bash
#!/bin/bash
set -x

cd ../france

# create a directory to store Pelias data files
# see: https://github.com/pelias/docker#variable-data_dir
mkdir ./data
sed -i '/DATA_DIR/d' .env
echo 'DATA_DIR=./data' >> .env

# configure docker to write files as your local user
# see: https://github.com/pelias/docker#variable-docker_user
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

## Configurer l'environment

La commande `pelias` nécessite un fichier `.env` dans le **répertoire courant**. Ce fichier contient les informations spécifiques à votre environnement local.

Se déplacer dans le répertoire `france/` avant de continuer:

```bash
cd france
```

Assurez-vous que le répertoire courrant contient les fichiers : `.env`, `docker-compose.yml` et `pelias.json` avant de continuer.

### Variable: DATA_DIR

La seule variable obligatoire dans le fichier `.env` est `DATA_DIR`.

Ce chemin reflète le répertoire que Pelias utilisera pour stocker les données téléchargées et l'utilisera pour créer ses autres microservices.

Vous **devez** créer un nouveau répertoire que vous utiliserez pour ce projet si vous ne voulez pas utiliser le répertoire `./data` du répertoire `./france`, par exemple:

```bash
mkdir /tmp/pelias
```

Pensez à modifier la variable `DATA_DIR` dans le fichier `.env`, ce qui donnerait ceci:

```bash
COMPOSE_PROJECT_NAME=pelias
DATA_DIR=/tmp/pelias
DOCKER_USER=1000
```

Vous pouvez ensuite lister les variables d'environnement pour vous assurer qu'elles ont été correctement définies:

```bash
pelias system env
```

### Variables: COMPOSE\_\*

Les variables compose sont optionnelles et documentées ici: https://docs.docker.com/compose/env-file/

### Variable: DOCKER_USER

Tous les processus dans les conteneurs Pelias sont exécutés en tant qu'utilisateurs non root. Par défaut, l'UID des processus sera `1000`, qui est le premier ID utilisateur sur la plupart des systèmes Linux et est probablement une bonne option. Cependant, s'il est important de restreindre les droits d'accès aux fichiers dans votre répertoire de données à un autre utilisateur ou groupe, cela peut être remplacé en définissant la variable `DOCKER_USER`.

Cette variable peut être un UID ou une combinaison UID:GID telle que `1000:1000`. Pour plus d'informations, voir les documentations [docker-compose](https://docs.docker.com/compose/compose-file/#domainname-hostname-ipc-mac_address-privileged-read_only-shm_size-stdin_open-tty-user-working_dir) et [docker run](https://docs.docker.com/engine/reference/run/#user) sur le contrôle des utilisateurs des conteneurs Docker.

Le fichier `.env` fournit est configuré avec la variable `DOCKER_USER` mise à `0` (donc root), il est préférable de la changer avec un autre utilisateur.

## Pelias CLI Commands

Voici la liste des commandes du CLI Pelias disponibles.

```bash
$ pelias

Usage: pelias [command] [action] [options]

  compose   pull                     update all docker images
  compose   logs                     display container logs
  compose   ps                       list containers
  compose   top                      display the running processes of a container
  compose   exec                     execute an arbitrary docker-compose command
  compose   run                      execute a docker-compose run command
  compose   up                       start one or more docker-compose service(s)
  compose   kill                     kill one or more docker-compose service(s)
  compose   down                     stop all docker-compose service(s)
  download  wof                      (re)download whosonfirst data
  download  oa                       (re)download openaddresses data
  download  osm                      (re)download openstreetmap data
  download  tiger                    (re)download TIGER data
  download  transit                  (re)download transit data
  download  all                      (re)download all data
  elastic   drop                     delete elasticsearch index & all data
  elastic   create                   create elasticsearch index with pelias mapping
  elastic   start                    start elasticsearch server
  elastic   stop                     stop elasticsearch server
  elastic   status                   HTTP status code of the elasticsearch service
  elastic   wait                     wait for elasticsearch to start up
  elastic   info                     display elasticsearch version and build info
  elastic   stats                    display a summary of doc counts per source/layer
  import    wof                      (re)import whosonfirst data
  import    oa                       (re)import openaddresses data
  import    osm                      (re)import openstreetmap data
  import    polylines                (re)import polylines data
  import    transit                  (re)import transit data
  import    all                      (re)import all data
  prepare   polylines                export road network from openstreetmap into polylines format
  prepare   interpolation            build interpolation sqlite databases
  prepare   placeholder              build placeholder sqlite databases
  prepare   all                      build all services which have a prepare step
  system    check                    ensure the system is correctly configured
  system    env                      display environment variables
  system    update                   update the pelias command by pulling the latest version
```

Pour plus de détails, se référer à la documentation [Pelias CLI Commands](https://github.com/pelias/docker#cli-commands).
