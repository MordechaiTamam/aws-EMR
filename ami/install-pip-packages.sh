#!/usr/bin/env bash
start=`date +%s`

set -e
WORK_DIR=/tmp/$(date +%Y%m%d_%H%M%S)
mkdir ${WORK_DIR}
cd ${WORK_DIR}
aws s3 cp s3://remdevme.packages/post-install/constraints.txt .
aws s3 cp s3://remdevme.packages/post-install/requirements.txt .
aws s3 cp s3://remdevme.packages/post-install/requirements-base.txt .

sed -i '/remdev/d' ./requirements.txt
sed -i '/gtsam/d' ./requirements.txt

sudo pip install -r ./requirements-base.txt
sudo pip install -r ./requirements.txt

sudo rm -f /usr/local/lib64/python2.7/site-packages/gtsam/libstdc++.so.6
sudo sed -i '/^backend /s/:.*$/: agg/' /usr/local/lib64/python2.7/site-packages/matplotlib/mpl-data/matplotlibrc
# Replace the above line with this: MPLBACKEND=agg , just push it into one of the right files.


sudo pip install requests==2.22.0
sudo pip install numba==0.43.0

runtime=$((end-start))
echo $runtime > /mnt/var/log/install-py-packages.log
