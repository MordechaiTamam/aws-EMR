#!/usr/bin/env bash
start=`date +%s`
sudo yum update -y
sudo yum-config-manager --enable epel
sudo yum groupinstall -y 'Development Tools'
sudo yum -y install python-devel python-docs python-debug Cython hdf5-devel curl wget groff less htop net-tools sysstat python27 python27-dev python27.dev python27-devel gcc-c++ mlocate gcc72-c++ gdb jq debuginfo-install glibc python-debuginfo

sudo debuginfo-install python27-2.7.16-1.127.amzn1.x86_64 ncurses-libs-5.7-4.20090207.14.amzn1.x86_64 readline-6.2-9.14.amzn1.x86_64 -y

sudo updatedb
sudo pip install awscli==1.16.33
sudo pip install s3fs
sudo pip install attrs
sudo pip install sqlalchemy
sudo pip install geoalchemy2
sudo pip install geojson
sudo pip install shapely
sudo yum install -y lz4
sudo yum update -y aws-cli
sudo yum -y install amazon-efs-utils

runtime=$((end-start))
echo $runtime > /mnt/var/log/install-machine.log