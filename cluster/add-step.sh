#!/usr/bin/env bash
#!/usr/bin/env bash
set -ex

while getopts c:p:s: option
do
case "${option}"
in
c) CLUSTER_ID=${OPTARG};;
p) LOCAL_PATH=${OPTARG};;
s) S3_PATH=${OPTARG};;
esac
done

# Extracting the file name:
filename="${LOCAL_PATH##*/}"

# Uploading script to S3
upload_response=$(aws s3 cp $LOCAL_PATH $S3_PATH)
echo "${upload_response}"
add_step_response=$(aws emr add-steps --cluster-id $CLUSTER_ID --steps "Type=CUSTOM_JAR,\
                        Name=CustomJAR,ActionOnFailure=CONTINUE,\
                        Jar=s3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar,Args=["${S3_PATH}"/"${filename}"]")
