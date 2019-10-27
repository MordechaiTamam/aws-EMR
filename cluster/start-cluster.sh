#!/usr/bin/env bash
set -uex
ami_installed_without_consul="ami-0bb0f77547ebf6bab"

config_file=$(<$1)
salve_sg=$(echo $config_file | jq -r '.salve_sg')
master_sg=$(echo $config_file  | jq -r '.master_sg')
service_access_sg=$(echo $config_file | jq -r '.service_access_sg')
additional_sg=$(echo $config_file | jq -r '.additional_sg')
subnet_id=$(echo $config_file | jq -r '.subnet_id')
efs_id=$(echo $config_file | jq -r '.efs_id')
cluster_name="REM "$(date +"%D %T")"-"$(echo $config_file | jq -r '.cluster_name')
core_instance_count=$(echo $config_file | jq -r '.instance.core.count')
master_instance_count=$(echo $config_file | jq -r '.instance.master.count')
core_instance_type=$(echo $config_file | jq -r '.instance.core.type')
master_instance_type=$(echo $config_file | jq -r '.instance.master.type')
executor_cores=$(echo $config_file | jq -r '.instance.core.executor_cores')
create_cluster_response=$(aws emr create-cluster \
    --auto-scaling-role EMR_AutoScaling_DefaultRole \
    --applications Name=Hadoop Name=Spark Name=Livy Name=Ganglia Name=Hue Name=JupyterHub Name=Zeppelin \
    --ebs-root-volume-size 80 \
    --ec2-attributes '{"KeyName":"modi","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"'${subnet_id}'","EmrManagedSlaveSecurityGroup":"'${salve_sg}'","EmrManagedMasterSecurityGroup":"'${master_sg}'","AdditionalMasterSecurityGroups":["'${additional_sg}'"],"AdditionalSlaveSecurityGroups":["'${additional_sg}'"]'} \
    --service-role EMR_DefaultRole \
    --enable-debugging \
    --release-label emr-5.24.0 \
    --log-uri 's3n://aws-logs-720146705806-us-east-1/elasticmapreduce/' \
    --name "$cluster_name" \
    --custom-ami-id "$ami_installed_without_consul" \
    --instance-groups '[{"InstanceCount":'${master_instance_count}',"BidPrice":"OnDemandPrice","InstanceGroupType":"MASTER","InstanceType":"'${master_instance_type}'","Name":"Master - 1"},{"InstanceCount":'${core_instance_count}',"BidPrice":"OnDemandPrice","InstanceGroupType":"CORE","InstanceType":"'${core_instance_type}'","Name":"Core - 2"}]' \
    --bootstrap-actions '[{"Path":"s3://rem-spark-staging/users/modit/emr-setup/ami/install.sh"},{"Path":"s3://rem-spark-staging/users/modit/emr-setup/bootstrap/mount-efs.sh","Args":["'${efs_id}'"],"Name":"mount EFS"},{"Path":"s3://rem-spark-staging/users/modit/emr-setup/ami/install-pip-packages.sh","Name":"install-pip-packages"},{"Path":"s3://rem-spark-staging/users/modit/emr-setup/bootstrap/consul/amz-linux-1/deploy-consul.sh"}]' \
    --configuration file:///localhomes/modit/dev/dev/aws-EMR/cluster/configuration.json \
    --region us-east-1)

cluster_id=$(echo "${create_cluster_response}" | jq -r '.ClusterId')
echo "ClusterId=${cluster_id}"
echo "AWS Management Console URL: https://console.aws.amazon.com/elasticmapreduce/home?region=us-east-1#cluster-details:${cluster_id}"

# block until the EMR cluster terminates
aws emr wait cluster-running --cluster-id $cluster_id