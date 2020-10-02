#!/bin/bash
set -x

echo "Moving to france/ directory"
cd france

# run build
echo "Updating all docker images"
pelias compose pull
pelias elastic start
pelias elastic wait
pelias elastic create
pelias download all
pelias prepare all
pelias import all
pelias compose up

