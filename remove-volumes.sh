#!/bin/bash -e

# num of persistent volumes
PV_COUNT=50

for i in $(seq 1 $PV_COUNT); do
  vol="vol\$i"
  sudo umount /mnt/local-storage/\$vol || true
  sudo rm -rf /mnt/local-storage/\$vol
done
