#!/usr/bin/env bash
start=`date +%s`

set -e
WORK_DIR=/tmp/$(date +%Y%m%d_%H%M%S)
mkdir ${WORK_DIR}
cd ${WORK_DIR}
aws s3 cp s3://remdevme.packages/post-install/constraints.txt .
aws s3 cp s3://remdevme.packages/post-install/requirements.txt .
aws s3 cp s3://remdevme.packages/post-install/requirements-base.txt .

sudo pip install --extra-index-url https://pypi.system.remdevme.com -r ./requirements-base.txt
sudo pip install --extra-index-url https://pypi.system.remdevme.com -r ./requirements.txt

sudo pip install --extra-index-url https://pypi.system.remdevme.com gtsam==4.0.0.1.98+unknown.ed3f3c4
sudo rm -f /usr/local/lib64/python2.7/site-packages/gtsam/libstdc++.so.6
sudo sed -i '/^backend /s/:.*$/: agg/' /usr/local/lib64/python2.7/site-packages/matplotlib/mpl-data/matplotlibrc
sudo pip install requests==2.22.0
sudo pip install numba==0.43.0

runtime=$((end-start))
echo $runtime > /mnt/var/log/install-py-packages.log
