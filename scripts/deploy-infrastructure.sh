#!/bin/bash
# Lab 3: Infrastructure Deployment Script
# Deploys OpenStack infrastructure via Heat

set -e  # Exit on error

echo "=== Lab 3 Infrastructure Deployment ==="
echo "Timestamp: $(date)"
echo "Directory: $(pwd)"

# Load OpenStack credentials
if [ -f ~/students-openrc.sh ]; then
    source ~/students-openrc.sh
    echo "✓ OpenStack credentials loaded"
else
    echo "✗ ERROR: OpenStack credentials not found at ~/students-openrc.sh"
    echo "Please create this file with your OpenStack credentials"
    exit 1
fi

# Parameters
STACK_NAME="lab3-infrastructure-stack"
TEMPLATE_FILE="templates/simple-server.yaml"

echo "Using template: $TEMPLATE_FILE"
echo "Stack name: $STACK_NAME"

# Check if stack already exists
if openstack stack show $STACK_NAME >/dev/null 2>&1; then
    echo "Updating existing stack: $STACK_NAME"
    openstack stack update -t $TEMPLATE_FILE $STACK_NAME \
        --parameter key_name=Ahmad \
        --parameter server_name="lab3-jenkins-deployed" \
        --wait
else
    echo "Creating new stack: $STACK_NAME"
    openstack stack create -t $TEMPLATE_FILE $STACK_NAME \
        --parameter key_name=Ahmad \
        --parameter server_name="lab3-jenkins-deployed" \
        --wait
fi

# Get and display outputs
echo "=== Deployment Complete ==="
echo "Stack outputs:"
openstack stack output show $STACK_NAME --all

# Extract server IP
SERVER_IP=$(openstack stack output show $STACK_NAME server_ip -f value -c output_value)
echo "Server IP: $SERVER_IP"

# Save IP to file for Jenkins artifacts
echo $SERVER_IP > deployed_server_ip.txt
echo "IP saved to: deployed_server_ip.txt"

echo "=== Infrastructure Ready ==="
echo "SSH command: ssh -i ~/hsai-lukashin/Ahmad ubuntu@$SERVER_IP"
echo "Deployment completed at: $(date)"
