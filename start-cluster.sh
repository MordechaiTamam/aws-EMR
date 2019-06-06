#!/usr/bin/env bash
set -uex
ami_installed_without_consul="ami-0bb0f77547ebf6bab"
ami_full_with_consul="ami-099c6da14d350e86f"
salve_sg="sg-05b869574e18e9a87"
master_sg="sg-0ff4a1a73f5327efc"
service_access_sg="sg-023edac99a59a4235"
additional_sg="sg-00e71ca66b2415df7"
subnet_id="subnet-0aa439b2753e0b62d"
cluster_name="deploy consul with append Modi "$(date +"%D %T")
core_instance_count=2
master_instance_count=1
create_cluster_response=$(aws emr create-cluster \
    --auto-scaling-role EMR_AutoScaling_DefaultRole \
    --applications Name=Hadoop Name=Hive Name=Hue Name=Spark Name=Livy \
    --ebs-root-volume-size 80 \
    --ec2-attributes '{"KeyName":"modi","InstanceProfile":"EMR_EC2_DefaultRole","SubnetId":"'${subnet_id}'","EmrManagedSlaveSecurityGroup":"'${salve_sg}'","EmrManagedMasterSecurityGroup":"'${master_sg}'","AdditionalMasterSecurityGroups":["'${additional_sg}'"],"AdditionalSlaveSecurityGroups":["'${additional_sg}'"]'} \
    --service-role EMR_DefaultRole \
    --enable-debugging \
    --release-label emr-5.22.0 \
    --log-uri 's3n://aws-logs-720146705806-us-east-1/elasticmapreduce/' \
    --name "$cluster_name" \
    --custom-ami-id "$ami_installed_without_consul" \
    --instance-groups '[{"InstanceCount":'${master_instance_count}',"BidPrice":"OnDemandPrice","InstanceGroupType":"MASTER","InstanceType":"m4.large","Name":"Master - 1"},{"InstanceCount":'${core_instance_count}',"BidPrice":"OnDemandPrice","InstanceGroupType":"CORE","InstanceType":"m4.large","Name":"Core - 2"}]' \
    --bootstrap-actions '[{"Path":"s3://rem-spark-staging/users/modit/emr-setup/bootstrap/mount-efs.sh","Name":"mount EFS"}]' \
    --configuration file:///localhomes/modit/dev/dev/aws-EMR/configuration.json \
    --region us-east-1)

cluster_id=$(echo "${create_cluster_response}" | jq -r '.ClusterId')
echo "ClusterId=${cluster_id}"
echo "AWS Management Console URL: https://console.aws.amazon.com/elasticmapreduce/home?region=us-east-1#cluster-details:${cluster_id}"

# block until the EMR cluster terminates
aws emr wait cluster-running --cluster-id $cluster_id