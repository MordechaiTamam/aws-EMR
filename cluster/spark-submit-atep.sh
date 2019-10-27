#!/usr/bin/env bash
executor_cores=$2
aws emr add-steps --cluster-id $1 --steps "Name=App1,Jar=command-runner.jar,Args=[/bin/sh,-c,\"SPARK_ENV=EMR RB_DB_HOST=aurora.rem-dev3.remdevme.com RB_DB_PASS=sdfDNDfg12d spark-submit --driver-memory 200g --executor-cores ${executor_cores} --conf spark.driverEnv.RB_DB_PASS=sdfDNDfg12d --conf spark.executorEnv.RB_DB_PASS=sdfDNDfg12d --conf spark.driverEnv.RB_DB_HOST=aurora.rem-dev3.remdevme.com --conf spark.executorEnv.RB_DB_HOST=aurora.rem-dev3.remdevme.com --conf spark.driverEnv.MPLBACKEND=agg --conf spark.executorEnv.MPLBACKEND=agg --py-files s3a://rem-spark-staging/users/modit/run-on-emr/out.zip --name modi-job s3a://rem-spark-staging/users/modit/run-on-emr/map_creator.py --time_bomb_minutes 600 --created_by_user modi --conf /mnt/efs/rem/users/modit/emr/run/dummy_conf.py\"]"