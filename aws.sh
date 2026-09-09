#!/bin/bash
set -e
trap 'echo "There is an error in $LINENO, Command: $BASH_COMMAND"' ERR


SG_ID="sg-078da222b6b5e6e14"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z05434983MKHE7P63RH25"
DOMAIN_NAME="pydiraju.online"

for instance in $@
do 
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]"\
    --query 'Instances[0].InstanceId' \
    --output text )

    if [ $instance == "frontend" ]; then
        IP=$(
              aws ec2 describe-instances \
              --instance-ids $INSTANCE_ID \
              --query 'Reservations[].Instances[].PublicIpAddress' \
              --output text

        )
        RECORD_NAME="$DOMAIN_NAME"
    else 
        IP=$(
              aws ec2 describe-instances \
              --instance-ids $INSTANCE_ID \
              --query 'Reservations[].Instances[].PrivateIpAddress' \
              --output text
    )
        RECORD_NAME="$instance.$DOMAIN_NAME"

    fi
    echo "ip address $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating an record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
        }
        '
    echo "record updated $instance"
done

