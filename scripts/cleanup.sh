#!/bin/bash
# Cleanup script for EKS infrastructure
# This handles the proper order of deletion to avoid stuck resources

set -e  # Exit on error

REGION="eu-west-2"
CLUSTER_NAME="eks-proj"
VPC_ID=""

echo "🧹 Starting EKS infrastructure cleanup..."
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../terraform"

# Step 1: Get VPC ID before cluster is deleted
echo "Getting VPC ID..."
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "")

if [ -n "$VPC_ID" ]; then
  echo "   VPC ID: $VPC_ID"
else
  echo "    VPC ID not found in Terraform output, will try to discover later"
fi
echo ""

# Step 2: Try to connect to cluster and delete LoadBalancer services
echo "🔌 Attempting to delete Kubernetes LoadBalancer services..."
if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" &>/dev/null; then
  aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME" &>/dev/null || true
  
  if kubectl get svc -A &>/dev/null; then
    echo "   Deleting services with type LoadBalancer..."
    kubectl get svc -A -o json | \
      jq -r '.items[] | select(.spec.type=="LoadBalancer") | "\(.metadata.namespace) \(.metadata.name)"' | \
      while read namespace name; do
        echo "   - Deleting $namespace/$name"
        kubectl delete svc -n "$namespace" "$name" --timeout=60s || true
      done
    echo "   LoadBalancer services deleted"
  else
    echo "   Cannot connect to cluster (already deleted or no access)"
  fi
else
  echo "   Cluster not found (already deleted)"
fi
echo ""

# Step 3: Remove Helm releases from Terraform state
echo "Removing Helm releases from Terraform state..."
terraform state rm \
  helm_release.nginx_ingress \
  helm_release.cert_manager \
  helm_release.external_dns \
  helm_release.argocd \
  helm_release.kube_prom_stack \
  2>/dev/null || echo "   ℹ️  Helm releases already removed or not in state"
echo ""

# Step 4: Manually delete any remaining Load Balancers
echo " Checking for orphaned Load Balancers..."
if [ -n "$VPC_ID" ]; then
  LB_ARNS=$(aws elbv2 describe-load-balancers --region "$REGION" \
    --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" \
    --output text 2>/dev/null || echo "")
  
  if [ -n "$LB_ARNS" ]; then
    for arn in $LB_ARNS; do
      echo "   - Deleting Load Balancer: $arn"
      aws elbv2 delete-load-balancer --region "$REGION" --load-balancer-arn "$arn" || true
    done
    echo " Load Balancers deleted"
    echo "  Waiting 30s for ENIs to detach..."
    sleep 30
  else
    echo "   No Load Balancers found"
  fi
else
  echo "    Skipping (VPC ID unknown)"
fi
echo ""

# Step 5: Run Terraform destroy
echo "Running Terraform destroy..."
terraform destroy -auto-approve

echo ""
echo "Cleanup complete!"
echo ""

