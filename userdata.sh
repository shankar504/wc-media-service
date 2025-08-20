#!/bin/bash
ec2-metadata > /tmp/userdata.txt
NEW_HOSTNAME_PREFIX='DevMediaClipperService-ASG'
SERVER_IP=$(grep "local-ipv4:" /tmp/userdata.txt | awk '{print $2}' | head -n1)
instance_id=$(grep "instance-id:" /tmp/userdata.txt | awk '{print $2}' | head -n1)
ServerName="$NEW_HOSTNAME_PREFIX-$SERVER_IP"
echo "aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$ServerName"
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value="$ServerName" --region us-west-2
sudo echo "$ServerName" > /etc/hostname
sudo hostnamectl set-hostname "$ServerName"
