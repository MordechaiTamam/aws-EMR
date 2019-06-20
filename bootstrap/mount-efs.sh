#!/usr/bin/env bash
# exit when any command fails
start=`date +%s`
set -e

mkdir /mnt/efs -p
sudo mount -t efs fs-9c078c7c: /mnt/efs
sudo chmod 777 /mnt/efs
end=`date +%s`

runtime=$((end-start))
echo $runtime > /mnt/var/log/mount_efs_time.log