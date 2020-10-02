#!/bin/bash
echo "Current directory $(pwd)"

echo "Moving to france/ directory"
cd france

shopt -s extglob
# These folders can be entirely deleted after the import into elastic search
echo "Deleting /data/openaddresses"
rm -rf ./data/openaddresses #(~43GB)
echo "Deleting /data/tiger"
rm -rf ./data/tiger #(~13GB)
echo "Deleting /data/openstreetmap"
rm -rf ./data/openstreetmap #(~46GB)
echo "Deleting /data/polylines"
rm -rf ./data/polylines #(~2.7GB)

# Within the content of the "interpolation" folder (~176GB) we must
# preserve "street.db" (~7GB) and "address.db" (~25GB), the rest can be deleted
echo "Deleting /data/interpolation/* except street.db and address.db"
cd ./data/interpolation
# Within the content of the "placeholder" folder (~1.4GB), we must
# preserve the "store.sqlite3" (~0.9GB) file, the rest can be deleted
echo "Deleting /data/placeholder/* except store.sqlite3"
cd ../..
cd ./data/placeholder
rm -rf -- !("store.sqlite3")