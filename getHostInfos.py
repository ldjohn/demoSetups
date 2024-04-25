#!/usr/bin/python3

import boto3
import requests
import json

def get_metadata(url):
    """Helper function to query EC2 instance metadata."""
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()  # Raises a HTTPError for bad responses
        return response.text
    except requests.RequestException as e:
        print(f"Error fetching metadata: {e}")
        return None

def get_instance_identity():
    """Retrieve the instance's ID and region using Metadata service."""
    identity_url = "http://169.254.169.254/latest/dynamic/instance-identity/document"
    identity_doc = get_metadata(identity_url)
    if identity_doc:
        identity = json.loads(identity_doc)
        return identity['instanceId'], identity['region']
    return None, None

def fetch_instance_tags(instance_id, region):
    """Fetch tags for a given instance ID from EC2."""
    ec2 = boto3.resource('ec2', region_name=region)
    instance = ec2.Instance(instance_id)
    return {tag['Key']: tag['Value'] for tag in instance.tags}

def fetch_security_groups(instance_id, region):
    """Fetch security groups for a given instance ID from EC2."""
    ec2 = boto3.resource('ec2', region_name=region)
    instance = ec2.Instance(instance_id)
    return [sg['GroupId'] for sg in instance.security_groups]

def main():
    instance_id, region = get_instance_identity()
    if instance_id and region:
        print(f"Instance ID: {instance_id}")
        print(f"Region: {region}")

        tags = fetch_instance_tags(instance_id, region)
        print("Tags:")
        for key, value in tags.items():
            print(f"  {key}: {value}")

        security_groups = fetch_security_groups(instance_id, region)
        print("Security Groups:")
        for sg in security_groups:
            print(f"  {sg}")

    else:
        print("Could not determine instance identity. Exiting.")

if __name__ == "__main__":
    main()
