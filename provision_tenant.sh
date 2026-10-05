#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if tenant name is provided
if [ -z "$1" ]; then
  echo "Error: No tenant name provided."
  echo "Usage: ./provision_tenant.sh <tenant-name> <tier>"
  echo "Example: ./provision_tenant.sh tenant-standard-c standard"
  exit 1
fi

TENANT_NAME=$1
TIER=${2:-standard} # Default to standard if tier is not provided

echo "=================================================="
echo "Starting Onboarding for Tenant: $TENANT_NAME (Tier: $TIER)"
echo "=================================================="

# 1. Create the Namespace with labels
echo "-> Creating namespace..."
kubectl create namespace "$TENANT_NAME" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "$TENANT_NAME" tier="$TIER" --overwrite

# 2. Apply Resource Quotas based on Tier
if [ "$TIER" == "enterprise" ]; then
  echo "-> Applying Enterprise-tier Resource Quota..."
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: enterprise-tier-quota
  namespace: $TENANT_NAME
spec:
  hard:
    requests.cpu: "500m"
    requests.memory: "512Mi"
    limits.cpu: "1000m"
    limits.memory: "1Gi"
    pods: "10"
EOF
else
  echo "-> Applying Standard-tier Resource Quota..."
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: standard-tier-quota
  namespace: $TENANT_NAME
spec:
  hard:
    requests.cpu: "200m"
    requests.memory: "256Mi"
    limits.cpu: "500m"
    limits.memory: "512Mi"
    pods: "5"
EOF
fi

# 3. Apply Network Isolation Policy (Deny Cross-Namespace Traffic)
echo "-> Applying Network Isolation Policies..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-cross-namespace
  namespace: $TENANT_NAME
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
EOF

echo "=================================================="
echo "Successfully provisioned tenant: $TENANT_NAME!"
echo "=================================================="