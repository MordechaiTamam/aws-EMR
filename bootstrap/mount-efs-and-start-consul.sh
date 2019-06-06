#!/usr/bin/env bash
# exit when any command fails
set -xe

mkdir /mnt/efs -p
sudo mount -t efs fs-9c078c7c: /mnt/efs
sudo service consul start
