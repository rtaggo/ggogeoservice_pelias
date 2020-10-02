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

# :warning: Photon préalablement installé

Avant de continuer il est nécessaire d'arrêter le géocodeur Photon.

```bash
${PHOTON_INSTALL_DIR}/run_photon.sh stop
```

ou

```bash
${PHOTON_INSTALL_DIR}/run_photon_path.sh stop
```

# Pré-requis

Avant de continuer, il est nécessaire d'avoir installé sur le système:

- une [version moderne de `docker`](https://docs.docker.com/engine/release-notes/)
- une [version moderne de `docker-compose`](https://github.com/docker/compose/blob/master/CHANGELOG.md)

Suivre les étapes d'installations disponible sur la documentation de docker [Install Docker Engine on CentOS](https://docs.docker.com/engine/install/centos/).

## Pré-requis pour Linux

Installer `git`

```bash
sudo yum install git
```

Installer `util-linux`

```bash
sudo yum install util-linux
```

## Pré-requis Système

Les Scripts peuvent facilement téléchargement des dizaines de Go de données géographiques, assurez-vous d'avoir suffisamment d'espace disque de libre!

Au moins 8Go de RAM sont nécessaires.

## Téléchargment de ce projet

```bash
# clone this repository
git clone https://github.com/rtaggo/ggogeoservice_pelias.git && cd ggogeoservice_pelias

```

## Scripts de démarrage rapide

Les trois scripts shell de ce dépôt sont à exécuter dans l'ordre suivant:

1. `01_setup_env.sh` : configurer l'envrionnement
1. `02_run_pelias.sh` : construire la solution Pelias
1. `03_cleanup.sh` : nettoyer les fichiers temporaires (optionnel)

Pensez à rendre ces scripts exécutables:

```bash
chmod 755 *.sh
```

### Configuration de l'environnement

Le script `01_setup_env.sh` télécharge le dépôt Pelias Docker et installe le script utilitaire `pelias`.

```bash
./01_setup_env.sh
```

Ce qui est exécuté en détails

```bash
# change directory to the where you would like to install Pelias
# cd /path/to/install

# clone this repository
git clone https://github.com/pelias/docker.git && cd docker

# install pelias script
ln -s "$(pwd)/pelias" /usr/local/bin/pelias
```

### Lancement de la solution Pelias

Le script `02_run_pelias.sh` télécharge/prepare/construire la solution Pelias pour la France et les DOM/TOM.
Cette opération peut prendre du temps (patience ....)

```bash
./02_run_pelias.sh
```

### Optionnel: Nettoyage des fichiers temporaires

Le script `03_cleanup.sh` permet de nettoyer l'ensemble des fichiers temporaires et volumineux qui ne sont plus utilisés.

```bash
./03_cleanup.sh
```

## Tester votre installation

You can now make queries against your new Pelias build:

```bash
curl http://localhost:4000/v1/search?text=Paris
```

# Mise à jour du proxy ggogeoservice

Arrêter le proxy

```bash
${GGOSERVICEPROXY_INSTALL_DIR}/run_ggogeoservice_proxy.sh stop
```

Copier le fichier `ggogeoservice-1.0.0.jar` dans le répertoire d'installation du proxy ggogeoservice

```bash
cp ./jar/ggogeoservice-1.0.0.jar ${GGOSERVICEPROXY_INSTALL_DIR}
```

Relancer le proxy

```bash
${GGOSERVICEPROXY_INSTALL_DIR}/run_ggogeoservice_proxy.sh start
```

Tester le fonctionnement du proxy

```bash
${GGOSERVICEPROXY_INSTALL_DIR}/test_ggogeoservice_proxy.sh
```

# Pour aller plus loin

Pour plus de détails, sur l'installation de Palias documentation [Pelias](Pelias.md).
