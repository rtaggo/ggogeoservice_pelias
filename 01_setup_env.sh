#!/bin/bash
echo "Cloning Pelias Docker repository"
# clone this repository
rm -rf docker
git clone https://github.com/pelias/docker.git && cd docker

# install pelias script
echo "Installing Pelias Script"
rm -rf /usr/local/bin/pelias
ln -s "$(pwd)/pelias" /usr/local/bin/pelias

echo "Moving to france/ directory"
echo "current directory $(pwd)"
cd  ../france
echo "current directory $(pwd)"

# create a directory to store Pelias data files
# see: https://github.com/pelias/docker#variable-data_dir
echo "Creating ./data directory"
mkdir ./data

echo "Setting DATA_DIR variable to ./data directory to path in to .env file"
sed -i '/DATA_DIR/d' .env
echo 'DATA_DIR=./data' >> .env

# configure docker to write files as your local user
# see: https://github.com/pelias/docker#variable-docker_user
echo "Setting DOCKER_USER variable as the local user in to .env file"
sed -i '/DOCKER_USER/d' .env
echo "DOCKER_USER=$(id -u)" >> .env