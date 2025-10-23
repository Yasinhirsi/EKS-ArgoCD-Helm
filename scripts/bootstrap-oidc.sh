#!/bin/bash
# Bootstrap OIDC Provider and IAM Role for GitHub Actions

set -e  # Exit on error

echo "Bootstrapping OIDC"
echo ""

# Get script directory and navigate to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../terraform"

terraform apply \
  -target=aws_iam_openid_connect_provider.github_actions \
  -target=aws_iam_role.github_actions_role \
  -target=aws_iam_role_policy.ecr_push_policy \
  -target=aws_iam_role_policy.eks_access_policy \
  -auto-approve

echo ""
echo "OIDC bootstrap complete!"
echo ""
echo "Role ARN:"
terraform output github_actions_role_arn

echo ""
echo " Next steps:"
echo "  1. Use this role ARN in your GitHub Actions workflows"
echo "  2. Push to GitHub to trigger automated deployments"

